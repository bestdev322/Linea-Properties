import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _users => _firestore.collection('users');

  String? get _uid => _auth.currentUser?.uid;

  /// ✅ Create or update user profile
  Future<void> saveUser({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String role = 'user',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final uid = user.uid;

    await _users.doc(uid).set({
      'uid': uid,
      'name': name ?? user.displayName,
      'email': email ?? user.email,
      'phone': phone,
      'photoUrl': photoUrl ?? user.photoURL,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ✅ Get user once
  Future<Map<String, dynamic>?> getUser() async {
    final uid = _uid;
    if (uid == null) return null;

    final doc = await _users.doc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// ✅ Real-time stream
  Stream<DocumentSnapshot<Object?>> streamUser() {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    return _users.doc(uid).snapshots();
  }

  /// ✅ Update user
  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _users.doc(uid).update(data);
  }
}