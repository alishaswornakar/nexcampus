// lib/features/student/blocs/team_finder/services/team_finder_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/team_application_model.dart';
import '../models/team_post_model.dart';

class TeamFinderException implements Exception {
  final String message;
  TeamFinderException(this.message);
  @override
  String toString() => 'TeamFinderException: $message';
}

/// Data-layer service for the Team Finder feature.
/// Collections: `team_posts`, `team_applications`.
/// Application doc id is deterministic: `{postId}_{applicantId}`, so a
/// student can never submit two active applications to the same post.
/// `team_posts.slotsFilled` only increments when an application is
/// *accepted* (not merely submitted).
class TeamFinderFirestoreService {
  TeamFinderFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection('team_posts');
  CollectionReference<Map<String, dynamic>> get _applicationsRef =>
      _firestore.collection('team_applications');

  TeamPostModel _decodePost(DocumentSnapshot<Map<String, dynamic>> doc) =>
      TeamPostModel.fromMap({...doc.data()!, 'id': doc.id});

  TeamApplicationModel _decodeApplication(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) => TeamApplicationModel.fromMap({...doc.data()!, 'id': doc.id});

  // ===================== STREAMS =====================

  Stream<List<TeamPostModel>> streamOpenPosts({
    String? department,
    String? semester,
  }) {
    try {
      Query<Map<String, dynamic>> query = _postsRef.where(
        'status',
        isEqualTo: TeamPostStatus.open,
      );
      if (department != null && department.trim().isNotEmpty) {
        query = query.where('department', isEqualTo: department);
      }
      if (semester != null && semester.trim().isNotEmpty) {
        query = query.where('semester', isEqualTo: semester);
      }
      return query
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_decodePost).toList());
    } catch (e) {
      throw TeamFinderException('Failed to stream open posts: $e');
    }
  }

  Stream<List<TeamPostModel>> streamMyPosts({required String ownerId}) {
    try {
      return _postsRef
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_decodePost).toList());
    } catch (e) {
      throw TeamFinderException('Failed to stream your posts: $e');
    }
  }

  Stream<List<TeamApplicationModel>> streamMyApplications({
    required String applicantId,
  }) {
    try {
      return _applicationsRef
          .where('applicantId', isEqualTo: applicantId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_decodeApplication).toList());
    } catch (e) {
      throw TeamFinderException('Failed to stream your applications: $e');
    }
  }

  Stream<List<TeamApplicationModel>> streamPostApplications({
    required String postId,
  }) {
    try {
      return _applicationsRef
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_decodeApplication).toList());
    } catch (e) {
      throw TeamFinderException('Failed to stream applicants: $e');
    }
  }

  Stream<TeamPostModel?> streamPost({required String postId}) {
    try {
      return _postsRef.doc(postId).snapshots().map((snap) {
        if (!snap.exists || snap.data() == null) return null;
        return _decodePost(snap);
      });
    } catch (e) {
      throw TeamFinderException('Failed to stream post: $e');
    }
  }

  // ===================== ONE-TIME READS =====================

  Future<TeamPostModel> getPostOnce({required String postId}) async {
    try {
      final snap = await _postsRef.doc(postId).get();
      if (!snap.exists || snap.data() == null) {
        throw TeamFinderException('Post not found');
      }
      return _decodePost(snap);
    } on TeamFinderException {
      rethrow;
    } catch (e) {
      throw TeamFinderException('Failed to fetch post: $e');
    }
  }

  // ===================== CREATE POST =====================

  Future<TeamPostModel> createPost({
    required String ownerId,
    required String ownerName,
    required String ownerEmail,
    required String rollNumber,
    required String department,
    required String semester,
    required String title,
    required String description,
    required String projectType,
    required List<String> skillsNeeded,
    required int slotsTotal,
  }) async {
    try {
      final docRef = _postsRef.doc();
      final now = DateTime.now();
      final post = TeamPostModel(
        id: docRef.id,
        ownerId: ownerId,
        ownerName: ownerName,
        ownerEmail: ownerEmail,
        rollNumber: rollNumber,
        department: department,
        semester: semester,
        title: title,
        description: description,
        projectType: projectType,
        skillsNeeded: skillsNeeded,
        slotsTotal: slotsTotal,
        slotsFilled: 0,
        status: TeamPostStatus.open,
        createdAt: now,
      );
      await docRef.set(post.toMap());
      return post;
    } catch (e) {
      throw TeamFinderException('Failed to create post: $e');
    }
  }

  // ===================== CLOSE / DELETE POST =====================

  Future<void> closePost({
    required String postId,
    required String ownerId,
  }) async {
    final postRef = _postsRef.doc(postId);
    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(postRef);
        if (!snap.exists || snap.data() == null) {
          throw TeamFinderException('Post not found');
        }
        if (snap.data()!['ownerId'] != ownerId) {
          throw TeamFinderException(
            'You are not authorized to close this post',
          );
        }
        txn.update(postRef, {
          'status': TeamPostStatus.closed,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on TeamFinderException {
      rethrow;
    } catch (e) {
      throw TeamFinderException('Failed to close post: $e');
    }
  }

  Future<void> deletePost({
    required String postId,
    required String ownerId,
  }) async {
    final postRef = _postsRef.doc(postId);
    try {
      final snap = await postRef.get();
      if (!snap.exists || snap.data() == null) {
        throw TeamFinderException('Post not found');
      }
      if (snap.data()!['ownerId'] != ownerId) {
        throw TeamFinderException('You are not authorized to delete this post');
      }
      final applications = await _applicationsRef
          .where('postId', isEqualTo: postId)
          .get();
      final batch = _firestore.batch();
      for (final doc in applications.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(postRef);
      await batch.commit();
    } on TeamFinderException {
      rethrow;
    } catch (e) {
      throw TeamFinderException('Failed to delete post: $e');
    }
  }

  // ===================== APPLY TO POST =====================

  Future<TeamApplicationModel> applyToPost({
    required String postId,
    required String applicantId,
    required String applicantName,
    required String applicantEmail,
    required String rollNumber,
    required String department,
    required String semester,
    String message = '',
  }) async {
    final postRef = _postsRef.doc(postId);
    final applicationRef = _applicationsRef.doc('${postId}_$applicantId');

    try {
      return await _firestore.runTransaction<TeamApplicationModel>((txn) async {
        final postSnap = await txn.get(postRef);
        if (!postSnap.exists || postSnap.data() == null) {
          throw TeamFinderException('This post no longer exists');
        }
        final postData = postSnap.data()!;

        if (postData['status'] != TeamPostStatus.open) {
          throw TeamFinderException('This post is no longer open');
        }
        if (postData['ownerId'] == applicantId) {
          throw TeamFinderException('You cannot apply to your own post');
        }

        final slotsTotal = (postData['slotsTotal'] as num?)?.toInt() ?? 1;
        final slotsFilled = (postData['slotsFilled'] as num?)?.toInt() ?? 0;
        if (slotsFilled >= slotsTotal) {
          throw TeamFinderException('All slots for this post are filled');
        }

        final existingSnap = await txn.get(applicationRef);
        if (existingSnap.exists) {
          final existingStatus = existingSnap.data()?['status'] as String?;
          if (existingStatus == TeamApplicationStatus.pending ||
              existingStatus == TeamApplicationStatus.accepted) {
            throw TeamFinderException('You already applied to this post');
          }
        }

        final now = DateTime.now();
        final application = TeamApplicationModel(
          id: applicationRef.id,
          postId: postId,
          postTitle: postData['title'] as String? ?? '',
          postOwnerId: postData['ownerId'] as String? ?? '',
          applicantId: applicantId,
          applicantName: applicantName,
          applicantEmail: applicantEmail,
          rollNumber: rollNumber,
          department: department,
          semester: semester,
          message: message,
          status: TeamApplicationStatus.pending,
          createdAt: now,
        );

        txn.set(applicationRef, application.toMap());
        return application;
      });
    } on TeamFinderException {
      rethrow;
    } catch (e) {
      throw TeamFinderException('Failed to apply: $e');
    }
  }

  // ===================== WITHDRAW APPLICATION =====================

  Future<void> withdrawApplication({
    required String applicationId,
    required String applicantId,
  }) async {
    final applicationRef = _applicationsRef.doc(applicationId);
    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(applicationRef);
        if (!snap.exists || snap.data() == null) {
          throw TeamFinderException('Application not found');
        }
        final data = snap.data()!;
        if (data['applicantId'] != applicantId) {
          throw TeamFinderException(
            'You are not authorized to withdraw this application',
          );
        }
        if (data['status'] != TeamApplicationStatus.pending) {
          throw TeamFinderException(
            'Only a pending application can be withdrawn',
          );
        }
        txn.update(applicationRef, {
          'status': TeamApplicationStatus.withdrawn,
          'respondedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } on TeamFinderException {
      rethrow;
    } catch (e) {
      throw TeamFinderException('Failed to withdraw application: $e');
    }
  }

  // ===================== RESPOND TO APPLICATION =====================

  Future<void> respondToApplication({
    required String applicationId,
    required String ownerId,
    required bool accept,
  }) async {
    final applicationRef = _applicationsRef.doc(applicationId);
    try {
      await _firestore.runTransaction((txn) async {
        final appSnap = await txn.get(applicationRef);
        if (!appSnap.exists || appSnap.data() == null) {
          throw TeamFinderException('Application not found');
        }
        final appData = appSnap.data()!;
        if (appData['status'] != TeamApplicationStatus.pending) {
          throw TeamFinderException(
            'This application has already been responded to',
          );
        }

        final postRef = _postsRef.doc(appData['postId'] as String);
        final postSnap = await txn.get(postRef);
        if (!postSnap.exists || postSnap.data() == null) {
          throw TeamFinderException('Post not found');
        }
        final postData = postSnap.data()!;
        if (postData['ownerId'] != ownerId) {
          throw TeamFinderException(
            'You are not authorized to respond to this application',
          );
        }

        final now = DateTime.now();

        if (!accept) {
          txn.update(applicationRef, {
            'status': TeamApplicationStatus.rejected,
            'respondedAt': Timestamp.fromDate(now),
          });
          return;
        }

        final slotsTotal = (postData['slotsTotal'] as num?)?.toInt() ?? 1;
        final slotsFilled = (postData['slotsFilled'] as num?)?.toInt() ?? 0;
        if (slotsFilled >= slotsTotal) {
          throw TeamFinderException(
            'All slots for this post are already filled',
          );
        }

        final newSlotsFilled = slotsFilled + 1;
        txn.update(applicationRef, {
          'status': TeamApplicationStatus.accepted,
          'respondedAt': Timestamp.fromDate(now),
        });
        txn.update(postRef, {
          'slotsFilled': newSlotsFilled,
          'status': newSlotsFilled >= slotsTotal
              ? TeamPostStatus.closed
              : TeamPostStatus.open,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on TeamFinderException {
      rethrow;
    } catch (e) {
      throw TeamFinderException('Failed to respond to application: $e');
    }
  }
}
