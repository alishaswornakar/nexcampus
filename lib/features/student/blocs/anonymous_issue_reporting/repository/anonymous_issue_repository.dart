// lib/features/student/blocs/anonymous_issue_reporting/repository/anonymous_issue_repository.dart
import 'dart:async';

import '../models/issue_comment_model.dart';
import '../models/issue_post_model.dart';
import '../services/anonymous_issue_firestore_service.dart';

class AnonymousIssueRepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AnonymousIssueRepositoryException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() =>
      'AnonymousIssueRepositoryException(code: $code, message: $message)';
}

class CreateIssuePostRequest {
  final String authorId;
  final String title;
  final String body;
  final String category;
  final bool isAnswer;

  const CreateIssuePostRequest({
    required this.authorId,
    required this.title,
    required this.body,
    required this.category,
    this.isAnswer = false,
  });
}

abstract class AnonymousIssueRepository {
  Stream<List<IssuePostModel>> watchFeed({String? category});
  Stream<List<IssuePostModel>> watchMyPosts(String authorId);
  Stream<List<IssueCommentModel>> watchPostComments(String postId);
  Stream<IssuePostModel?> watchPost(String postId);

  Future<IssuePostModel> getPostOnce(String postId);
  Future<IssuePostModel> createPost(CreateIssuePostRequest request);
  Future<void> deletePost({required String postId, required String authorId});
  Future<void> setResolved({
    required String postId,
    required String authorId,
    required bool resolved,
  });
  Future<void> toggleUpvotePost({
    required String postId,
    required String studentId,
  });

  Future<IssueCommentModel> createComment({
    required String postId,
    required String authorId,
    required String body,
  });
  Future<void> deleteComment({
    required String commentId,
    required String authorId,
  });
  Future<void> toggleUpvoteComment({
    required String commentId,
    required String studentId,
  });
}

class AnonymousIssueRepositoryImpl implements AnonymousIssueRepository {
  final AnonymousIssueFirestoreService _service;

  AnonymousIssueRepositoryImpl({AnonymousIssueFirestoreService? service})
    : _service = service ?? AnonymousIssueFirestoreService();

  @override
  Stream<List<IssuePostModel>> watchFeed({String? category}) {
    return _wrapStream(
      _service.streamFeed(category: category),
      context: 'Failed to load the feed',
    );
  }

  @override
  Stream<List<IssuePostModel>> watchMyPosts(String authorId) {
    if (authorId.trim().isEmpty) {
      return Stream.error(
        AnonymousIssueRepositoryException(
          'authorId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamMyPosts(authorId: authorId),
      context: 'Failed to load your posts',
    );
  }

  @override
  Stream<List<IssueCommentModel>> watchPostComments(String postId) {
    if (postId.trim().isEmpty) {
      return Stream.error(
        AnonymousIssueRepositoryException(
          'postId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamPostComments(postId: postId),
      context: 'Failed to load comments',
    );
  }

  @override
  Stream<IssuePostModel?> watchPost(String postId) {
    if (postId.trim().isEmpty) {
      return Stream.error(
        AnonymousIssueRepositoryException(
          'postId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamPost(postId: postId),
      context: 'Failed to load post',
    );
  }

  @override
  Future<IssuePostModel> getPostOnce(String postId) async {
    try {
      return await _service.getPostOnce(postId: postId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to fetch post');
    }
  }

  @override
  Future<IssuePostModel> createPost(CreateIssuePostRequest request) async {
    _validateCreateRequest(request);
    try {
      return await _service.createPost(
        authorId: request.authorId,
        title: request.title,
        body: request.body,
        category: request.category,
        isAnswer: request.isAnswer,
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to create post');
    }
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String authorId,
  }) async {
    if (postId.trim().isEmpty || authorId.trim().isEmpty) {
      throw AnonymousIssueRepositoryException(
        'postId and authorId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.deletePost(postId: postId, authorId: authorId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to delete post');
    }
  }

  @override
  Future<void> setResolved({
    required String postId,
    required String authorId,
    required bool resolved,
  }) async {
    if (postId.trim().isEmpty || authorId.trim().isEmpty) {
      throw AnonymousIssueRepositoryException(
        'postId and authorId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.setResolved(
        postId: postId,
        authorId: authorId,
        resolved: resolved,
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to update post');
    }
  }

  @override
  Future<void> toggleUpvotePost({
    required String postId,
    required String studentId,
  }) async {
    if (postId.trim().isEmpty || studentId.trim().isEmpty) {
      throw AnonymousIssueRepositoryException(
        'postId and studentId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.toggleUpvotePost(postId: postId, studentId: studentId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to update upvote');
    }
  }

  @override
  Future<IssueCommentModel> createComment({
    required String postId,
    required String authorId,
    required String body,
  }) async {
    if (postId.trim().isEmpty || authorId.trim().isEmpty) {
      throw AnonymousIssueRepositoryException(
        'postId and authorId must not be empty',
        code: 'invalid-argument',
      );
    }
    if (body.trim().isEmpty) {
      throw AnonymousIssueRepositoryException(
        'Comment cannot be empty',
        code: 'invalid-argument',
      );
    }
    try {
      return await _service.createComment(
        postId: postId,
        authorId: authorId,
        body: body.trim(),
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to post comment');
    }
  }

  @override
  Future<void> deleteComment({
    required String commentId,
    required String authorId,
  }) async {
    if (commentId.trim().isEmpty || authorId.trim().isEmpty) {
      throw AnonymousIssueRepositoryException(
        'commentId and authorId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.deleteComment(commentId: commentId, authorId: authorId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to delete comment');
    }
  }

  @override
  Future<void> toggleUpvoteComment({
    required String commentId,
    required String studentId,
  }) async {
    if (commentId.trim().isEmpty || studentId.trim().isEmpty) {
      throw AnonymousIssueRepositoryException(
        'commentId and studentId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.toggleUpvoteComment(
        commentId: commentId,
        studentId: studentId,
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to update upvote');
    }
  }

  void _validateCreateRequest(CreateIssuePostRequest request) {
    final missing = <String>[];
    if (request.authorId.trim().isEmpty) missing.add('authorId');
    if (request.title.trim().isEmpty) missing.add('title');
    if (request.body.trim().isEmpty) missing.add('body');
    if (request.category.trim().isEmpty) missing.add('category');
    if (missing.isNotEmpty) {
      throw AnonymousIssueRepositoryException(
        'Missing/invalid field(s): ${missing.join(', ')}',
        code: 'invalid-argument',
      );
    }
  }

  Stream<T> _wrapStream<T>(Stream<T> source, {required String context}) {
    final controller = StreamController<T>();
    final subscription = source.listen(
      (event) {
        if (!controller.isClosed) controller.add(event);
      },
      onError: (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(_mapError(error, stackTrace, context: context));
        }
      },
      onDone: () {
        if (!controller.isClosed) controller.close();
      },
    );
    controller.onCancel = () => subscription.cancel();
    return controller.stream;
  }

  AnonymousIssueRepositoryException _mapError(
    dynamic error,
    StackTrace stackTrace, {
    required String context,
  }) {
    if (error is AnonymousIssueRepositoryException) return error;
    final errorString = error.toString();
    if (errorString.startsWith('AnonymousIssueException:')) {
      final message = errorString.replaceFirst(
        'AnonymousIssueException: ',
        '',
      );
      return AnonymousIssueRepositoryException(
        message,
        code: 'anonymous-issue-error',
        originalError: error,
      );
    }
    String? code;
    try {
      final dynamic dynError = error;
      code = dynError.code as String?;
    } catch (_) {
      code = null;
    }
    return AnonymousIssueRepositoryException(
      '$context: $errorString',
      code: code,
      originalError: error,
    );
  }
}
