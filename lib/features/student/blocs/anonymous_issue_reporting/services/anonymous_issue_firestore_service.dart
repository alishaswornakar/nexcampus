// lib/features/student/blocs/anonymous_issue_reporting/services/anonymous_issue_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/issue_comment_model.dart';
import '../models/issue_post_model.dart';
import '../utils/anonymous_identity.dart';

class AnonymousIssueException implements Exception {
  final String message;
  AnonymousIssueException(this.message);
  @override
  String toString() => 'AnonymousIssueException: $message';
}

/// Data-layer service for the Anonymous Issue Reporting feature.
///
/// Collections: `anonymous_issue_posts`, `anonymous_issue_comments`.
///
/// Anonymity model:
/// - `authorId` is stored on every document so the true author can still
///   edit/delete their own content and so moderators can act on abuse
///   reports, but it is NEVER read back into any display label.
/// - Every post/comment instead carries a generated `anonymousName`
///   (see [AnonymousIdentity]) which is the only identity ever rendered.
class AnonymousIssueFirestoreService {
  AnonymousIssueFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _postsRef =>
      _firestore.collection('anonymous_issue_posts');
  CollectionReference<Map<String, dynamic>> get _commentsRef =>
      _firestore.collection('anonymous_issue_comments');

  IssuePostModel _decodePost(DocumentSnapshot<Map<String, dynamic>> doc) =>
      IssuePostModel.fromMap({...doc.data()!, 'id': doc.id});

  IssueCommentModel _decodeComment(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) => IssueCommentModel.fromMap({...doc.data()!, 'id': doc.id});

  // ===================== STREAMS =====================

  Stream<List<IssuePostModel>> streamFeed({String? category}) {
    try {
      Query<Map<String, dynamic>> query = _postsRef;
      if (category != null && category.trim().isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      return query
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_decodePost).toList());
    } catch (e) {
      throw AnonymousIssueException('Failed to stream feed: $e');
    }
  }

  Stream<List<IssuePostModel>> streamMyPosts({required String authorId}) {
    try {
      return _postsRef
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_decodePost).toList());
    } catch (e) {
      throw AnonymousIssueException('Failed to stream your posts: $e');
    }
  }

  Stream<List<IssueCommentModel>> streamPostComments({
    required String postId,
  }) {
    try {
      return _commentsRef
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snap) => snap.docs.map(_decodeComment).toList());
    } catch (e) {
      throw AnonymousIssueException('Failed to stream comments: $e');
    }
  }

  Stream<IssuePostModel?> streamPost({required String postId}) {
    try {
      return _postsRef.doc(postId).snapshots().map((snap) {
        if (!snap.exists || snap.data() == null) return null;
        return _decodePost(snap);
      });
    } catch (e) {
      throw AnonymousIssueException('Failed to stream post: $e');
    }
  }

  // ===================== ONE-TIME READS =====================

  Future<IssuePostModel> getPostOnce({required String postId}) async {
    try {
      final snap = await _postsRef.doc(postId).get();
      if (!snap.exists || snap.data() == null) {
        throw AnonymousIssueException('Post not found');
      }
      return _decodePost(snap);
    } on AnonymousIssueException {
      rethrow;
    } catch (e) {
      throw AnonymousIssueException('Failed to fetch post: $e');
    }
  }

  // ===================== CREATE POST =====================

  Future<IssuePostModel> createPost({
    required String authorId,
    required String title,
    required String body,
    required String category,
    bool isAnswer = false,
  }) async {
    try {
      final docRef = _postsRef.doc();
      final now = DateTime.now();
      final post = IssuePostModel(
        id: docRef.id,
        authorId: authorId,
        anonymousName: AnonymousIdentity.labelFor(
          AnonymousIdentity.postSeed(docRef.id),
        ),
        title: title,
        body: body,
        category: category,
        isAnswer: isAnswer,
        createdAt: now,
      );
      await docRef.set(post.toMap());
      return post;
    } catch (e) {
      throw AnonymousIssueException('Failed to create post: $e');
    }
  }

  // ===================== DELETE / RESOLVE POST =====================

  Future<void> deletePost({
    required String postId,
    required String authorId,
  }) async {
    final postRef = _postsRef.doc(postId);
    try {
      final snap = await postRef.get();
      if (!snap.exists || snap.data() == null) {
        throw AnonymousIssueException('Post not found');
      }
      if (snap.data()!['authorId'] != authorId) {
        throw AnonymousIssueException(
          'You are not authorized to delete this post',
        );
      }
      final comments = await _commentsRef
          .where('postId', isEqualTo: postId)
          .get();
      final batch = _firestore.batch();
      for (final doc in comments.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(postRef);
      await batch.commit();
    } on AnonymousIssueException {
      rethrow;
    } catch (e) {
      throw AnonymousIssueException('Failed to delete post: $e');
    }
  }

  Future<void> setResolved({
    required String postId,
    required String authorId,
    required bool resolved,
  }) async {
    final postRef = _postsRef.doc(postId);
    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(postRef);
        if (!snap.exists || snap.data() == null) {
          throw AnonymousIssueException('Post not found');
        }
        if (snap.data()!['authorId'] != authorId) {
          throw AnonymousIssueException(
            'You are not authorized to update this post',
          );
        }
        txn.update(postRef, {
          'isResolved': resolved,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on AnonymousIssueException {
      rethrow;
    } catch (e) {
      throw AnonymousIssueException('Failed to update post: $e');
    }
  }

  // ===================== UPVOTE POST =====================

  Future<void> toggleUpvotePost({
    required String postId,
    required String studentId,
  }) async {
    final postRef = _postsRef.doc(postId);
    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(postRef);
        if (!snap.exists || snap.data() == null) {
          throw AnonymousIssueException('Post not found');
        }
        final data = snap.data()!;
        final upvotedBy = (data['upvotedBy'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        final alreadyUpvoted = upvotedBy.contains(studentId);
        if (alreadyUpvoted) {
          upvotedBy.remove(studentId);
        } else {
          upvotedBy.add(studentId);
        }
        txn.update(postRef, {
          'upvotedBy': upvotedBy,
          'upvoteCount': upvotedBy.length,
        });
      });
    } on AnonymousIssueException {
      rethrow;
    } catch (e) {
      throw AnonymousIssueException('Failed to update upvote: $e');
    }
  }

  // ===================== COMMENTS =====================

  Future<IssueCommentModel> createComment({
    required String postId,
    required String authorId,
    required String body,
  }) async {
    final postRef = _postsRef.doc(postId);
    final commentRef = _commentsRef.doc();
    try {
      return await _firestore.runTransaction<IssueCommentModel>((
        txn,
      ) async {
        final postSnap = await txn.get(postRef);
        if (!postSnap.exists || postSnap.data() == null) {
          throw AnonymousIssueException('This post no longer exists');
        }
        final postData = postSnap.data()!;
        final now = DateTime.now();
        final comment = IssueCommentModel(
          id: commentRef.id,
          postId: postId,
          authorId: authorId,
          anonymousName: AnonymousIdentity.labelFor(
            AnonymousIdentity.commentSeed(postId, authorId),
          ),
          isFromOriginalPoster: postData['authorId'] == authorId,
          body: body,
          createdAt: now,
        );
        txn.set(commentRef, comment.toMap());
        txn.update(postRef, {
          'commentsCount': ((postData['commentsCount'] as num?)?.toInt() ?? 0) + 1,
        });
        return comment;
      });
    } on AnonymousIssueException {
      rethrow;
    } catch (e) {
      throw AnonymousIssueException('Failed to post comment: $e');
    }
  }

  Future<void> deleteComment({
    required String commentId,
    required String authorId,
  }) async {
    final commentRef = _commentsRef.doc(commentId);
    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(commentRef);
        if (!snap.exists || snap.data() == null) {
          throw AnonymousIssueException('Comment not found');
        }
        final data = snap.data()!;
        if (data['authorId'] != authorId) {
          throw AnonymousIssueException(
            'You are not authorized to delete this comment',
          );
        }
        final postRef = _postsRef.doc(data['postId'] as String);
        final postSnap = await txn.get(postRef);
        txn.delete(commentRef);
        if (postSnap.exists && postSnap.data() != null) {
          final current = (postSnap.data()!['commentsCount'] as num?)?.toInt() ?? 0;
          txn.update(postRef, {
            'commentsCount': current > 0 ? current - 1 : 0,
          });
        }
      });
    } on AnonymousIssueException {
      rethrow;
    } catch (e) {
      throw AnonymousIssueException('Failed to delete comment: $e');
    }
  }

  Future<void> toggleUpvoteComment({
    required String commentId,
    required String studentId,
  }) async {
    final commentRef = _commentsRef.doc(commentId);
    try {
      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(commentRef);
        if (!snap.exists || snap.data() == null) {
          throw AnonymousIssueException('Comment not found');
        }
        final data = snap.data()!;
        final upvotedBy = (data['upvotedBy'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        final alreadyUpvoted = upvotedBy.contains(studentId);
        if (alreadyUpvoted) {
          upvotedBy.remove(studentId);
        } else {
          upvotedBy.add(studentId);
        }
        txn.update(commentRef, {
          'upvotedBy': upvotedBy,
          'upvoteCount': upvotedBy.length,
        });
      });
    } on AnonymousIssueException {
      rethrow;
    } catch (e) {
      throw AnonymousIssueException('Failed to update upvote: $e');
    }
  }
}
