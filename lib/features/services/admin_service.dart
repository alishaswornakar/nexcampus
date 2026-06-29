import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Stream<QuerySnapshot> getStudentsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots();
  }


  Stream<QuerySnapshot> getTeachersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots();
  }


  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}