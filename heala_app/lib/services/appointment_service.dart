import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AppointmentService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Appointment> _appointments = [];
  List<User> _doctors = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Appointment> get appointments => _appointments;
  List<User> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AppointmentService() {
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedAppointments = await StorageService.getAppointments();
      _appointments = cachedAppointments;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached appointments: $e');
    }
  }

  Future<bool> fetchAppointments(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase
          .from('appointments')
          .select('''
            *,
            doctor:users!appointments_doctor_id_fkey(
              id, full_name, specialty, profile_image_url
            ),
            patient:users!appointments_patient_id_fkey(
              id, full_name, profile_image_url
            )
          ''')
          .or('patient_id.eq.$userId,doctor_id.eq.$userId')
          .order('scheduled_date_time', ascending: true);

      _appointments = (response as List)
          .map((data) => _parseAppointmentWithUserData(data))
          .toList();

      await StorageService.saveAppointments(_appointments);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to fetch appointments: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> fetchDoctors({String? specialty, String? searchQuery}) async {
    try {
      _setLoading(true);
      _clearError();

      var query = _supabase
          .from('users')
          .select()
          .eq('role', 'healthcare_professional')
          .eq('is_verified', true);

      if (specialty != null && specialty.isNotEmpty) {
        query = query.eq('specialty', specialty);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('full_name.ilike.%$searchQuery%,specialty.ilike.%$searchQuery%');
      }

      final response = await query.order('full_name', ascending: true);

      _doctors = (response as List)
          .map((data) => User.fromJson(data))
          .toList();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to fetch doctors: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required DateTime scheduledDateTime,
    required String type,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if the time slot is available
      final existingAppointments = await _supabase
          .from('appointments')
          .select()
          .eq('doctor_id', doctorId)
          .eq('scheduled_date_time', scheduledDateTime.toIso8601String())
          .neq('status', 'cancelled');

      if (existingAppointments.isNotEmpty) {
        _setError('This time slot is not available');
        return false;
      }

      final appointmentData = {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'scheduled_date_time': scheduledDateTime.toIso8601String(),
        'status': 'scheduled',
        'type': type,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('appointments')
          .insert(appointmentData)
          .select()
          .single();

      final newAppointment = Appointment.fromJson(response);
      _appointments.add(newAppointment);
      _appointments.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));

      await StorageService.saveAppointment(newAppointment);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to book appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase
          .from('appointments')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appointmentId);

      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await StorageService.saveAppointment(_appointments[index]);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to update appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    return await updateAppointmentStatus(appointmentId, 'cancelled');
  }

  Future<bool> completeAppointment(String appointmentId, {String? prescription, String? notes}) async {
    try {
      _setLoading(true);
      _clearError();

      final updateData = {
        'status': 'completed',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (prescription != null) {
        updateData['prescription'] = prescription;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _supabase
          .from('appointments')
          .update(updateData)
          .eq('id', appointmentId);

      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: 'completed',
          prescription: prescription ?? _appointments[index].prescription,
          notes: notes ?? _appointments[index].notes,
          updatedAt: DateTime.now(),
        );
        await StorageService.saveAppointment(_appointments[index]);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to complete appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rescheduleAppointment(String appointmentId, DateTime newDateTime) async {
    try {
      _setLoading(true);
      _clearError();

      final appointment = _appointments.firstWhere((a) => a.id == appointmentId);

      // Check if the new time slot is available
      final existingAppointments = await _supabase
          .from('appointments')
          .select()
          .eq('doctor_id', appointment.doctorId)
          .eq('scheduled_date_time', newDateTime.toIso8601String())
          .neq('status', 'cancelled')
          .neq('id', appointmentId);

      if (existingAppointments.isNotEmpty) {
        _setError('This time slot is not available');
        return false;
      }

      await _supabase
          .from('appointments')
          .update({
            'scheduled_date_time': newDateTime.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appointmentId);

      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          scheduledDateTime: newDateTime,
          updatedAt: DateTime.now(),
        );
        _appointments.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
        await StorageService.saveAppointment(_appointments[index]);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to reschedule appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((appointment) => 
            appointment.scheduledDateTime.isAfter(now) && 
            appointment.status == 'scheduled')
        .toList();
  }

  List<Appointment> getTodayAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((appointment) => 
            appointment.scheduledDateTime.day == now.day &&
            appointment.scheduledDateTime.month == now.month &&
            appointment.scheduledDateTime.year == now.year)
        .toList();
  }

  List<Appointment> getAppointmentsByStatus(String status) {
    return _appointments
        .where((appointment) => appointment.status == status)
        .toList();
  }

  Appointment? getAppointmentById(String appointmentId) {
    try {
      return _appointments.firstWhere((a) => a.id == appointmentId);
    } catch (e) {
      return null;
    }
  }

  List<String> getAvailableSpecialties() {
    return _doctors
        .where((doctor) => doctor.specialty != null)
        .map((doctor) => doctor.specialty!)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<DateTime>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 9, 0); // 9 AM
      final endOfDay = DateTime(date.year, date.month, date.day, 17, 0); // 5 PM
      
      // Get existing appointments for the doctor on this date
      final existingAppointments = await _supabase
          .from('appointments')
          .select('scheduled_date_time')
          .eq('doctor_id', doctorId)
          .gte('scheduled_date_time', startOfDay.toIso8601String())
          .lt('scheduled_date_time', endOfDay.toIso8601String())
          .neq('status', 'cancelled');

      final bookedTimes = (existingAppointments as List)
          .map((data) => DateTime.parse(data['scheduled_date_time']))
          .toSet();

      // Generate available time slots (every 30 minutes)
      final availableSlots = <DateTime>[];
      var currentTime = startOfDay;
      
      while (currentTime.isBefore(endOfDay)) {
        if (!bookedTimes.contains(currentTime)) {
          availableSlots.add(currentTime);
        }
        currentTime = currentTime.add(const Duration(minutes: 30));
      }

      return availableSlots;
    } catch (e) {
      debugPrint('Error getting available time slots: $e');
      return [];
    }
  }

  Appointment _parseAppointmentWithUserData(Map<String, dynamic> data) {
    final appointment = Appointment.fromJson(data);
    
    // Add doctor information if available
    if (data['doctor'] != null) {
      final doctorData = data['doctor'];
      return appointment.copyWith(
        doctorName: doctorData['full_name'],
        doctorSpecialty: doctorData['specialty'],
        doctorImageUrl: doctorData['profile_image_url'],
      );
    }
    
    // Add patient information if available
    if (data['patient'] != null) {
      final patientData = data['patient'];
      return appointment.copyWith(
        patientName: patientData['full_name'],
        patientImageUrl: patientData['profile_image_url'],
      );
    }
    
    return appointment;
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
