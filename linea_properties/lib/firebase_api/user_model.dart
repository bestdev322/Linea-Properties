import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? fullName;
  final String role;
  final String? phone;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    required this.email,
    this.fullName,
    this.role = 'user',
    this.phone,
    this.photoUrl,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  /// 🔁 CopyWith
  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 🔄 Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'phone': phone,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// 📥 Convert from Firestore document
  static AppUser fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime? toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return AppUser(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'],
      role: data['role'] ?? 'user',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      emailVerified: data['emailVerified'] ?? false,
      createdAt: toDate(data['createdAt']),
      updatedAt: toDate(data['updatedAt']),
    );
  }
}