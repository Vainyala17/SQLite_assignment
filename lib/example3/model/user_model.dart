class UserModel {
  final int? id;
  final String name;
  final String mobile;
  final String email;
  final String gender;
  final String maritalStatus;
  final String state;
  final String educationalQualification;
  final String? subject1; // For Graduate subjects
  final String? subject2;
  final String? subject3;
  final String? pgSubject; // For Post Graduate subject
  final String? photoPath; // Local image path
  final String timestamp;
  final String address;

  UserModel({
    this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.gender,
    required this.maritalStatus,
    required this.state,
    required this.educationalQualification,
    this.subject1,
    this.subject2,
    this.subject3,
    this.pgSubject,
    this.photoPath,
    required this.timestamp,
    required this.address,
  });

  // ✅ FIXED: Separate method for users table (without address)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'state': state,
      'educationalQualification': educationalQualification,
      'subject1': subject1,
      'subject2': subject2,
      'subject3': subject3,
      'pgSubject': pgSubject,
      'photoPath': photoPath,
      'timestamp': timestamp,
      // ❌ REMOVED: Don't include address in users table map
      // 'address': address,
    };
  }

  // ✅ NEW: Method to get complete map including address (for UI/display purposes)
  Map<String, dynamic> toCompleteMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'state': state,
      'educationalQualification': educationalQualification,
      'subject1': subject1,
      'subject2': subject2,
      'subject3': subject3,
      'pgSubject': pgSubject,
      'photoPath': photoPath,
      'timestamp': timestamp,
      'address': address,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      maritalStatus: map['maritalStatus'] ?? '',
      state: map['state'] ?? '',
      educationalQualification: map['educationalQualification'] ?? '',
      subject1: map['subject1'],
      subject2: map['subject2'],
      subject3: map['subject3'],
      pgSubject: map['pgSubject'],
      photoPath: map['photoPath'],
      timestamp: map['timestamp'] ?? '',
      address: map['address'] ?? '',
    );
  }

  // Helper method to get subjects as a map (for backward compatibility)
  Map<String, dynamic>? get subjects {
    if (educationalQualification == 'Graduate') {
      return {
        'subject1': subject1,
        'subject2': subject2,
        'subject3': subject3,
      };
    }
    return null;
  }

  // Helper method to get PG subject (for backward compatibility)
  String? get subject {
    if (educationalQualification == 'Post Graduate') {
      return pgSubject;
    }
    return null;
  }

  // Helper method to simulate Firebase document data() method
  Map<String, dynamic> data() {
    final data = toCompleteMap(); // Use complete map here

    // Add subjects in the format expected by the UI
    if (educationalQualification == 'Graduate') {
      data['subjects'] = {
        'subject1': subject1,
        'subject2': subject2,
        'subject3': subject3,
      };
    } else if (educationalQualification == 'Post Graduate') {
      data['subject'] = pgSubject;
    }

    // Convert photoPath to photoUrl for UI compatibility
    if (photoPath != null) {
      data['photoUrl'] = photoPath;
    }

    return data;
  }
}