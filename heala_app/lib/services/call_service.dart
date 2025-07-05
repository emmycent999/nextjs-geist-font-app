import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum CallState {
  idle,
  connecting,
  connected,
  disconnected,
  failed,
}

enum CallType {
  audio,
  video,
}

class CallService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  CallState _callState = CallState.idle;
  CallType _callType = CallType.video;
  String? _currentCallId;
  String? _currentRoomId;
  
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = false;
  bool _isFrontCamera = true;
  
  String? _errorMessage;

  // Getters
  CallState get callState => _callState;
  CallType get callType => _callType;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isSpeakerEnabled => _isSpeakerEnabled;
  bool get isFrontCamera => _isFrontCamera;
  String? get errorMessage => _errorMessage;
  String? get currentCallId => _currentCallId;

  // WebRTC Configuration
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      // Add TURN servers for production
    ],
    'sdpSemantics': 'unified-plan',
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  CallService() {
    _initializeWebRTC();
  }

  Future<void> _initializeWebRTC() async {
    try {
      // Initialize WebRTC
      await WebRTC.initialize();
      debugPrint('WebRTC initialized successfully');
    } catch (e) {
      _setError('Failed to initialize WebRTC: $e');
    }
  }

  Future<bool> startCall({
    required String appointmentId,
    required String participantId,
    required CallType callType,
  }) async {
    try {
      _setCallState(CallState.connecting);
      _callType = callType;
      _currentCallId = appointmentId;
      _currentRoomId = 'room_$appointmentId';

      // Create peer connection
      _peerConnection = await createPeerConnection(_configuration, _constraints);
      _setupPeerConnectionListeners();

      // Get user media
      await _getUserMedia();

      // Create offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Save offer to Supabase
      await _saveOfferToDatabase(offer);

      // Listen for answer
      _listenForAnswer();

      return true;
    } catch (e) {
      _setError('Failed to start call: $e');
      _setCallState(CallState.failed);
      return false;
    }
  }

  Future<bool> joinCall({
    required String appointmentId,
    required CallType callType,
  }) async {
    try {
      _setCallState(CallState.connecting);
      _callType = callType;
      _currentCallId = appointmentId;
      _currentRoomId = 'room_$appointmentId';

      // Create peer connection
      _peerConnection = await createPeerConnection(_configuration, _constraints);
      _setupPeerConnectionListeners();

      // Get user media
      await _getUserMedia();

      // Get offer from database
      final offer = await _getOfferFromDatabase();
      if (offer != null) {
        await _peerConnection!.setRemoteDescription(offer);

        // Create answer
        RTCSessionDescription answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        // Save answer to database
        await _saveAnswerToDatabase(answer);

        // Listen for ICE candidates
        _listenForIceCandidates();
      }

      return true;
    } catch (e) {
      _setError('Failed to join call: $e');
      _setCallState(CallState.failed);
      return false;
    }
  }

  Future<void> _getUserMedia() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': _callType == CallType.video ? {
          'facingMode': _isFrontCamera ? 'user' : 'environment',
          'width': {'ideal': 640},
          'height': {'ideal': 480},
        } : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      
      // Add tracks to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      notifyListeners();
    } catch (e) {
      _setError('Failed to get user media: $e');
      throw e;
    }
  }

  void _setupPeerConnectionListeners() {
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _sendIceCandidate(candidate);
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      _remoteStream = stream;
      _setCallState(CallState.connected);
      notifyListeners();
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE Connection State: $state');
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
          _setCallState(CallState.connected);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          _setCallState(CallState.failed);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          _setCallState(CallState.disconnected);
          break;
        default:
          break;
      }
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Peer Connection State: $state');
    };
  }

  Future<void> _saveOfferToDatabase(RTCSessionDescription offer) async {
    try {
      await _supabase.from('call_sessions').upsert({
        'room_id': _currentRoomId,
        'offer': {
          'type': offer.type,
          'sdp': offer.sdp,
        },
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving offer: $e');
    }
  }

  Future<void> _saveAnswerToDatabase(RTCSessionDescription answer) async {
    try {
      await _supabase.from('call_sessions').update({
        'answer': {
          'type': answer.type,
          'sdp': answer.sdp,
        },
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('room_id', _currentRoomId);
    } catch (e) {
      debugPrint('Error saving answer: $e');
    }
  }

  Future<RTCSessionDescription?> _getOfferFromDatabase() async {
    try {
      final response = await _supabase
          .from('call_sessions')
          .select('offer')
          .eq('room_id', _currentRoomId)
          .single();

      if (response['offer'] != null) {
        final offerData = response['offer'];
        return RTCSessionDescription(offerData['sdp'], offerData['type']);
      }
    } catch (e) {
      debugPrint('Error getting offer: $e');
    }
    return null;
  }

  void _listenForAnswer() {
    _supabase
        .from('call_sessions')
        .stream(primaryKey: ['room_id'])
        .eq('room_id', _currentRoomId)
        .listen((data) async {
          if (data.isNotEmpty) {
            final session = data.first;
            if (session['answer'] != null && _peerConnection != null) {
              final answerData = session['answer'];
              final answer = RTCSessionDescription(answerData['sdp'], answerData['type']);
              await _peerConnection!.setRemoteDescription(answer);
              _listenForIceCandidates();
            }
          }
        });
  }

  void _listenForIceCandidates() {
    _supabase
        .from('ice_candidates')
        .stream(primaryKey: ['id'])
        .eq('room_id', _currentRoomId)
        .listen((data) async {
          for (final candidate in data) {
            if (_peerConnection != null) {
              await _peerConnection!.addCandidate(RTCIceCandidate(
                candidate['candidate'],
                candidate['sdp_mid'],
                candidate['sdp_mline_index'],
              ));
            }
          }
        });
  }

  Future<void> _sendIceCandidate(RTCIceCandidate candidate) async {
    try {
      await _supabase.from('ice_candidates').insert({
        'room_id': _currentRoomId,
        'candidate': candidate.candidate,
        'sdp_mid': candidate.sdpMid,
        'sdp_mline_index': candidate.sdpMLineIndex,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error sending ICE candidate: $e');
    }
  }

  Future<void> toggleMute() async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        _isMuted = !_isMuted;
        audioTracks.first.enabled = !_isMuted;
        notifyListeners();
      }
    }
  }

  Future<void> toggleVideo() async {
    if (_localStream != null && _callType == CallType.video) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        _isVideoEnabled = !_isVideoEnabled;
        videoTracks.first.enabled = _isVideoEnabled;
        notifyListeners();
      }
    }
  }

  Future<void> switchCamera() async {
    if (_localStream != null && _callType == CallType.video) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks.first);
        _isFrontCamera = !_isFrontCamera;
        notifyListeners();
      }
    }
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerEnabled = !_isSpeakerEnabled;
    await Helper.setSpeakerphoneOn(_isSpeakerEnabled);
    notifyListeners();
  }

  Future<void> endCall() async {
    try {
      _setCallState(CallState.disconnected);

      // Close peer connection
      await _peerConnection?.close();
      _peerConnection = null;

      // Stop local stream
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });
      _localStream = null;
      _remoteStream = null;

      // Clean up database
      if (_currentRoomId != null) {
        await _cleanupCallSession();
      }

      // Reset state
      _currentCallId = null;
      _currentRoomId = null;
      _isMuted = false;
      _isVideoEnabled = true;
      _isSpeakerEnabled = false;
      _isFrontCamera = true;

      notifyListeners();
    } catch (e) {
      _setError('Error ending call: $e');
    }
  }

  Future<void> _cleanupCallSession() async {
    try {
      // Delete call session
      await _supabase
          .from('call_sessions')
          .delete()
          .eq('room_id', _currentRoomId);

      // Delete ICE candidates
      await _supabase
          .from('ice_candidates')
          .delete()
          .eq('room_id', _currentRoomId);
    } catch (e) {
      debugPrint('Error cleaning up call session: $e');
    }
  }

  void _setCallState(CallState state) {
    _callState = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    endCall();
    super.dispose();
  }
}
