// lib/features/admin/team_finder/services/admin_team_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/team_model.dart';

class AdminTeamServiceException implements Exception {
  final String message;
  AdminTeamServiceException(this.message);
  @override
  String toString() => 'AdminTeamServiceException: $message';
}

/// Admin-side data layer for the Team Finder feature.
///
/// Reads and writes the exact same Firestore collections the student side
/// uses (see `TeamFinderFirestoreService`):
///   - `team_posts`         (was incorrectly `project_teams` before)
///   - `team_applications`
///
/// Students don't have an approval workflow ('Pending' / 'Approved' /
/// 'Rejected' doesn't exist in their schema) — a post is simply `open` or
/// `closed`. Admin acts as a moderator on top of that: it can force-close a
/// post (stop new applications), reopen one, delete a post (and its
/// applications), and inspect who has applied.
class AdminTeamService {
  AdminTeamService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection('team_posts');
  CollectionReference<Map<String, dynamic>> get _applicationsRef =>
      _firestore.collection('team_applications');

  TeamModel _decode(DocumentSnapshot<Map<String, dynamic>> doc) =>
      TeamModel.fromMap(doc.data()!, doc.id);

  // ===================== STREAMS =====================

  /// All team posts, newest first. No status filter.
  Stream<List<TeamModel>> getAllTeams() {
    try {
      return _postsRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_decode).toList());
    } catch (e) {
      throw AdminTeamServiceException('Failed to load teams: $e');
    }
  }

  /// Team posts filtered by status. Accepts [TeamPostStatus.open] or
  /// [TeamPostStatus.closed] to match the values students actually write.
  Stream<List<TeamModel>> getTeamsByStatus(String status) {
    try {
      return _postsRef
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_decode).toList());
    } catch (e) {
      throw AdminTeamServiceException('Failed to load $status teams: $e');
    }
  }

  /// Applicants for a given post, newest first — lets admin see who has
  /// applied without needing the full student bloc/repository stack.
  Stream<List<TeamApplicationSummary>> getApplicantsForPost(String postId) {
    try {
      return _applicationsRef
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => TeamApplicationSummary.fromMap(d.data(), d.id))
                .toList(),
          );
    } catch (e) {
      throw AdminTeamServiceException('Failed to load applicants: $e');
    }
  }

  // ===================== MUTATIONS =====================

  /// Force-closes a post so students can no longer apply to it. Unlike the
  /// student-side `closePost`, this doesn't check post ownership — admin can
  /// close any post.
  Future<void> closePost(String postId) async {
    try {
      await _postsRef.doc(postId).update({
        'status': TeamPostStatus.closed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error closing post: $e');
      throw AdminTeamServiceException('Failed to close post: $e');
    }
  }

  /// Reopens a previously closed post.
  Future<void> reopenPost(String postId) async {
    try {
      await _postsRef.doc(postId).update({
        'status': TeamPostStatus.open,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error reopening post: $e');
      throw AdminTeamServiceException('Failed to reopen post: $e');
    }
  }

  /// Deletes a post and cascades the delete to its applications, matching
  /// the cleanup behavior of the student-side `deletePost`.
  Future<void> deleteTeam(String postId) async {
    final postRef = _postsRef.doc(postId);
    try {
      final applications = await _applicationsRef
          .where('postId', isEqualTo: postId)
          .get();
      final batch = _firestore.batch();
      for (final doc in applications.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(postRef);
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting team: $e');
      throw AdminTeamServiceException('Failed to delete post: $e');
    }
  }
}
