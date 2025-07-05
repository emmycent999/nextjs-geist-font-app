import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/call_service.dart';
import '../services/appointment_service.dart';
import '../models/appointment.dart';

class TeleconsultationScreen extends StatefulWidget {
  const TeleconsultationScreen({super.key});

  @override
  State<TeleconsultationScreen> createState() => _TeleconsultationScreenState();
}

class _TeleconsultationScreenState extends State<TeleconsultationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Teleconsultation'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppointmentService>(
        builder: (context, appointmentService, child) {
          final upcomingAppointments = appointmentService.getUpcomingAppointments()
              .where((appointment) => appointment.type != 'in_person')
              .toList();

          if (upcomingAppointments.isEmpty) {
            return _buildNoAppointmentsView();
          }

          return _buildAppointmentsList(upcomingAppointments);
        },
      ),
    );
  }

  Widget _buildNoAppointmentsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_call_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Teleconsultations Scheduled',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Book a video or audio consultation with a healthcare professional to get started.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/appointments');
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Consultation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(
          appointment: appointment,
          onJoinCall: () => _joinCall(appointment),
        );
      },
    );
  }

  void _joinCall(Appointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallScreen(appointment: appointment),
      ),
    );
  }
}

class CallScreen extends StatefulWidget {
  final Appointment appointment;

  const CallScreen({super.key, required this.appointment});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late CallService _callService;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _callService = Provider.of<CallService>(context, listen: false);
    _initializeRenderers();
    _startCall();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startCall() async {
    final callType = widget.appointment.type == 'video' ? CallType.video : CallType.audio;
    await _callService.startCall(
      appointmentId: widget.appointment.id,
      participantId: widget.appointment.doctorId,
      callType: callType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CallService>(
        builder: (context, callService, child) {
          // Set up video streams
          if (callService.localStream != null) {
            _localRenderer.srcObject = callService.localStream;
          }
          if (callService.remoteStream != null) {
            _remoteRenderer.srcObject = callService.remoteStream;
          }

          return Stack(
            children: [
              // Remote video (full screen)
              if (callService.remoteStream != null && widget.appointment.type == 'video')
                Positioned.fill(
                  child: RTCVideoView(_remoteRenderer, mirror: false),
                ),
              
              // Audio call background
              if (widget.appointment.type == 'audio' || callService.remoteStream == null)
                _buildAudioCallBackground(),

              // Local video (picture-in-picture)
              if (callService.localStream != null && widget.appointment.type == 'video')
                Positioned(
                  top: 60,
                  right: 20,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: RTCVideoView(_localRenderer, mirror: true),
                    ),
                  ),
                ),

              // Call controls
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: _buildCallControls(callService),
              ),

              // Call status
              Positioned(
                top: 60,
                left: 20,
                child: _buildCallStatus(callService),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAudioCallBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF9C27B0),
            const Color(0xFF9C27B0).withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: widget.appointment.doctorImageUrl != null
                  ? NetworkImage(widget.appointment.doctorImageUrl!)
                  : null,
              child: widget.appointment.doctorImageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              widget.appointment.doctorName ?? 'Doctor',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.appointment.doctorSpecialty ?? 'General Practice',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallStatus(CallService callService) {
    String statusText;
    Color statusColor;

    switch (callService.callState) {
      case CallState.connecting:
        statusText = 'Connecting...';
        statusColor = Colors.orange;
        break;
      case CallState.connected:
        statusText = 'Connected';
        statusColor = Colors.green;
        break;
      case CallState.failed:
        statusText = 'Connection Failed';
        statusColor = Colors.red;
        break;
      case CallState.disconnected:
        statusText = 'Disconnected';
        statusColor = Colors.grey;
        break;
      default:
        statusText = 'Idle';
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(CallService callService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _CallControlButton(
            icon: callService.isMuted ? Icons.mic_off : Icons.mic,
            isActive: !callService.isMuted,
            onPressed: callService.toggleMute,
          ),
          
          // Video toggle (only for video calls)
          if (widget.appointment.type == 'video')
            _CallControlButton(
              icon: callService.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              isActive: callService.isVideoEnabled,
              onPressed: callService.toggleVideo,
            ),
          
          // Speaker toggle
          _CallControlButton(
            icon: callService.isSpeakerEnabled ? Icons.volume_up : Icons.volume_down,
            isActive: callService.isSpeakerEnabled,
            onPressed: callService.toggleSpeaker,
          ),
          
          // Camera switch (only for video calls)
          if (widget.appointment.type == 'video')
            _CallControlButton(
              icon: Icons.flip_camera_ios,
              isActive: true,
              onPressed: callService.switchCamera,
            ),
          
          // End call button
          _CallControlButton(
            icon: Icons.call_end,
            isActive: false,
            backgroundColor: Colors.red,
            onPressed: () async {
              await callService.endCall();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onJoinCall;

  const _AppointmentCard({
    required this.appointment,
    required this.onJoinCall,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final appointmentTime = appointment.scheduledDateTime;
    final canJoin = appointmentTime.difference(now).inMinutes.abs() <= 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF9C27B0),
                backgroundImage: appointment.doctorImageUrl != null
                    ? NetworkImage(appointment.doctorImageUrl!)
                    : null,
                child: appointment.doctorImageUrl == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName ?? 'Doctor',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      appointment.doctorSpecialty ?? 'General Practice',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appointment.type == 'video'
                      ? const Color(0xFF9C27B0).withOpacity(0.1)
                      : const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      appointment.type == 'video' ? Icons.videocam : Icons.call,
                      size: 16,
                      color: appointment.type == 'video'
                          ? const Color(0xFF9C27B0)
                          : const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: appointment.type == 'video'
                            ? const Color(0xFF9C27B0)
                            : const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                '${appointmentTime.day}/${appointmentTime.month}/${appointmentTime.year} at ${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (canJoin)
                ElevatedButton.icon(
                  onPressed: onJoinCall,
                  icon: Icon(
                    appointment.type == 'video' ? Icons.videocam : Icons.call,
                    size: 16,
                  ),
                  label: const Text('Join'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                )
              else
                Text(
                  'Available 15 min before',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const _CallControlButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isActive ? Colors.white : Colors.white.withOpacity(0.3)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: backgroundColor != null
              ? Colors.white
              : (isActive ? Colors.black : Colors.white),
          size: 24,
        ),
      ),
    );
  }
}
