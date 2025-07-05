class User {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'patient' or 'healthcare_professional'
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Patient-specific fields
  final String? medicalHistory;
  final String? allergies;
  final String? emergencyContact;
  
  // Healthcare professional-specific fields
  final String? licenseNumber;
  final String? specialty;
  final String? credentials;
  final bool? isVerified;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.medicalHistory,
    this.allergies,
    this.emergencyContact,
    this.licenseNumber,
    this.specialty,
    this.credentials,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      phoneNumber: json['phone_number'],
      profileImageUrl: json['profile_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      medicalHistory: json['medical_history'],
      allergies: json['allergies'],
      emergencyContact: json['emergency_contact'],
      licenseNumber: json['license_number'],
      specialty: json['specialty'],
      credentials: json['credentials'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'medical_history': medicalHistory,
      'allergies': allergies,
      'emergency_contact': emergencyContact,
      'license_number': licenseNumber,
      'specialty': specialty,
      'credentials': credentials,
      'is_verified': isVerified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? medicalHistory,
    String? allergies,
    String? emergencyContact,
    String? licenseNumber,
    String? specialty,
    String? credentials,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialty: specialty ?? this.specialty,
      credentials: credentials ?? this.credentials,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
