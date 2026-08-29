import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';

/// Admin team member. Phase 3: `admins/{uid}` with custom claims.
class AdminProfile {
  const AdminProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.lastActive,
    this.active = true,
  });

  final String uid;
  final String name;
  final String email;
  final AdminRole role;
  final DateTime lastActive;
  final bool active;

  AdminProfile copyWith({AdminRole? role, bool? active}) => AdminProfile(
        uid: uid,
        name: name,
        email: email,
        role: role ?? this.role,
        lastActive: lastActive,
        active: active ?? this.active,
      );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'lastActive': Timestamp.fromDate(lastActive),
      'createdAt': Timestamp.fromDate(lastActive),
      'active': active,
    };
  }

  factory AdminProfile.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final roleVal = AdminRole.fromString(map['role']);

    return AdminProfile(
      uid: docId ?? map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Admin',
      email: map['email']?.toString() ?? '',
      role: roleVal,
      lastActive: parseDate(map['lastActive'] ?? map['createdAt']),
      active: map['active'] as bool? ?? true,
    );
  }
}
