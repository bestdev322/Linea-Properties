import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_model.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> ensureUserProfile({
    required User authUser,
    String? fullName,
    String role = 'user',
  }) async {
    final doc = _users.doc(authUser.uid);
    final snapshot = await doc.get();

    final now = FieldValue.serverTimestamp();

    if (!snapshot.exists) {
      await doc.set({
        'uid': authUser.uid,
        'email': authUser.email,
        'fullName': fullName ?? authUser.displayName,
        'role': role,
        'photoUrl': authUser.photoURL,
        'emailVerified': authUser.emailVerified,
        'createdAt': now,
        'updatedAt': now,
      });
      return;
    }

    await doc.set({
      'email': authUser.email,
      'fullName': fullName ?? authUser.displayName,
      'photoUrl': authUser.photoURL,
      'emailVerified': authUser.emailVerified,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromDoc(doc);
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

