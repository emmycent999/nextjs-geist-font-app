import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Check if user is already logged in
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _loadUserProfile(session.user.id);
    }

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session?.user != null) {
            _loadUserProfile(session!.user.id);
          }
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          StorageService.clearUserData();
          notifyListeners();
          break;
        default:
          break;
      }
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phoneNumber,
    String? licenseNumber,
    String? specialty,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
          'phone_number': phoneNumber,
          'license_number': licenseNumber,
          'specialty': specialty,
        },
      );

      if (response.user != null) {
        // Create user profile in the database
        await _createUserProfile(response.user!, {
          'full_name': fullName,
          'role': role,
          'phone_number': phoneNumber,
          'license_number': licenseNumber,
          'specialty': specialty,
        });
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during sign up');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during sign in');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabase.auth.signOut();
      _currentUser = null;
      await StorageService.clearUserData();
      notifyListeners();
    } catch (e) {
      _setError('Error signing out');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createUserProfile(User user, Map<String, dynamic> userData) async {
    try {
      await _supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'full_name': userData['full_name'],
        'role': userData['role'],
        'phone_number': userData['phone_number'],
        'license_number': userData['license_number'],
        'specialty': userData['specialty'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = User.fromJson(response);
      await StorageService.saveUserData(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Try to load from local storage
      final cachedUser = await StorageService.getUserData();
      if (cachedUser != null) {
        _currentUser = cachedUser;
        notifyListeners();
      }
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) return false;

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', _currentUser!.id);

      // Reload user profile
      await _loadUserProfile(_currentUser!.id);
      return true;
    } catch (e) {
      _setError('Error updating profile');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
