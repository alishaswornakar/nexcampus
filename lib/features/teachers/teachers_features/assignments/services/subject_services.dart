// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/subject_model.dart';

class SubjectService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<SubjectModel>> getSubjects({
  required String department,
  required String semester,
}) {
  print("Department = '$department'");
  print("Semester = '$semester'");

   return firestore
      .collection("subjects")
      .where("department", isEqualTo: department)
      .where("semester", isEqualTo: semester)
      .snapshots()
      .map((snapshot) {
        print("Documents found: ${snapshot.docs.length}");

        for (final doc in snapshot.docs) {
          print(doc.data());
        }

        return snapshot.docs
            .map((doc) => SubjectModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    //   return firestore
    // .collection("subjects")
    // .snapshots()
    // .map((snapshot) {
    //   print("Total documents: ${snapshot.docs.length}");

    //   for (var doc in snapshot.docs) {
    //     print("${doc.id} => ${doc.data()}");
    //   }

    //   return snapshot.docs
    //       .map((doc) => SubjectModel.fromMap(doc.data(), doc.id))
    //       .toList();
    // });
}
}