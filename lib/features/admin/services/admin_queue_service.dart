import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/queue_model.dart';

class AdminQueueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time Stream for Today's Queue
  Stream<List<QueueModel>> getTodayQueue() {
    return _firestore
        .collection('digital_queue')
        .orderBy('tokenNumber', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QueueModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update Status (Serving, Completed, Skipped)
  Future<void> updateTokenStatus(String tokenId, String status, {String? counter}) async {
    Map<String, dynamic> data = {'status': status};
    if (counter != null) data['counterName'] = counter;

    await _firestore.collection('digital_queue').doc(tokenId).update(data);
  }

  // Reset Queue (For a new day)
  Future<void> resetQueue() async {
    var collection = _firestore.collection('digital_queue');
    var snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}