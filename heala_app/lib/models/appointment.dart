class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime scheduledDateTime;
  final String status; // 'scheduled', 'completed', 'cancelled', 'in_progress'
  final String type; // 'video', 'audio', 'in_person'
  final String? notes;
  final String? prescription;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Doctor information (for display purposes)
  final String? doctorName;
  final String? doctorSpecialty;
  final String? doctorImageUrl;
  
  // Patient information (for healthcare professionals)
  final String? patientName;
  final String? patientImageUrl;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.scheduledDateTime,
    required this.status,
    required this.type,
    this.notes,
    this.prescription,
    required this.createdAt,
    required this.updatedAt,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorImageUrl,
    this.patientName,
    this.patientImageUrl,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      scheduledDateTime: DateTime.parse(json['scheduled_date_time']),
      status: json['status'],
      type: json['type'],
      notes: json['notes'],
      prescription: json['prescription'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      doctorName: json['doctor_name'],
      doctorSpecialty: json['doctor_specialty'],
      doctorImageUrl: json['doctor_image_url'],
      patientName: json['patient_name'],
      patientImageUrl: json['patient_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'scheduled_date_time': scheduledDateTime.toIso8601String(),
      'status': status,
      'type': type,
      'notes': notes,
      'prescription': prescription,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'doctor_name': doctorName,
      'doctor_specialty': doctorSpecialty,
      'doctor_image_url': doctorImageUrl,
      'patient_name': patientName,
      'patient_image_url': patientImageUrl,
    };
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? scheduledDateTime,
    String? status,
    String? type,
    String? notes,
    String? prescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorImageUrl,
    String? patientName,
    String? patientImageUrl,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      status: status ?? this.status,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      prescription: prescription ?? this.prescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      patientName: patientName ?? this.patientName,
      patientImageUrl: patientImageUrl ?? this.patientImageUrl,
    );
  }

  bool get isUpcoming => scheduledDateTime.isAfter(DateTime.now()) && status == 'scheduled';
  bool get isToday => scheduledDateTime.day == DateTime.now().day && 
                     scheduledDateTime.month == DateTime.now().month && 
                     scheduledDateTime.year == DateTime.now().year;
}
