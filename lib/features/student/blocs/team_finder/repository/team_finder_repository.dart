// lib/features/student/blocs/team_finder/repository/team_finder_repository.dart
import 'dart:async';

import '../models/team_application_model.dart';
import '../models/team_post_model.dart';
import '../services/team_finder_firestore_service.dart';

class TeamFinderRepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  TeamFinderRepositoryException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'TeamFinderRepositoryException(code: $code, message: $message)';
}

class CreatePostRequest {
  final String ownerId, ownerName, ownerEmail, rollNumber, department, semester;
  final String title, description, projectType;
  final List<String> skillsNeeded;
  final int slotsTotal;

  const CreatePostRequest({
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.title,
    required this.description,
    required this.projectType,
    required this.skillsNeeded,
    required this.slotsTotal,
  });
}

class ApplyToPostRequest {
  final String postId,
      applicantId,
      applicantName,
      applicantEmail,
      rollNumber,
      department,
      semester;
  final String message;

  const ApplyToPostRequest({
    required this.postId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
    this.message = '',
  });
}

abstract class TeamFinderRepository {
  Stream<List<TeamPostModel>> watchOpenPosts({
    String? department,
    String? semester,
  });
  Stream<List<TeamPostModel>> watchMyPosts(String ownerId);
  Stream<List<TeamApplicationModel>> watchMyApplications(String applicantId);
  Stream<List<TeamApplicationModel>> watchPostApplications(String postId);
  Stream<TeamPostModel?> watchPost(String postId);

  Future<TeamPostModel> getPostOnce(String postId);
  Future<TeamPostModel> createPost(CreatePostRequest request);
  Future<TeamApplicationModel> applyToPost(ApplyToPostRequest request);
  Future<void> withdrawApplication({
    required String applicationId,
    required String applicantId,
  });
  Future<void> respondToApplication({
    required String applicationId,
    required String ownerId,
    required bool accept,
  });
  Future<void> closePost({required String postId, required String ownerId});
  Future<void> deletePost({required String postId, required String ownerId});
}

class TeamFinderRepositoryImpl implements TeamFinderRepository {
  final TeamFinderFirestoreService _service;

  TeamFinderRepositoryImpl({TeamFinderFirestoreService? service})
    : _service = service ?? TeamFinderFirestoreService();

  @override
  Stream<List<TeamPostModel>> watchOpenPosts({
    String? department,
    String? semester,
  }) {
    return _wrapStream(
      _service.streamOpenPosts(department: department, semester: semester),
      context: 'Failed to load open posts',
    );
  }

  @override
  Stream<List<TeamPostModel>> watchMyPosts(String ownerId) {
    if (ownerId.trim().isEmpty) {
      return Stream.error(
        TeamFinderRepositoryException(
          'ownerId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamMyPosts(ownerId: ownerId),
      context: 'Failed to load your posts',
    );
  }

  @override
  Stream<List<TeamApplicationModel>> watchMyApplications(String applicantId) {
    if (applicantId.trim().isEmpty) {
      return Stream.error(
        TeamFinderRepositoryException(
          'applicantId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamMyApplications(applicantId: applicantId),
      context: 'Failed to load your applications',
    );
  }

  @override
  Stream<List<TeamApplicationModel>> watchPostApplications(String postId) {
    if (postId.trim().isEmpty) {
      return Stream.error(
        TeamFinderRepositoryException(
          'postId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamPostApplications(postId: postId),
      context: 'Failed to load applicants',
    );
  }

  @override
  Stream<TeamPostModel?> watchPost(String postId) {
    if (postId.trim().isEmpty) {
      return Stream.error(
        TeamFinderRepositoryException(
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
  Future<TeamPostModel> getPostOnce(String postId) async {
    try {
      return await _service.getPostOnce(postId: postId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to fetch post');
    }
  }

  @override
  Future<TeamPostModel> createPost(CreatePostRequest request) async {
    _validateCreateRequest(request);
    try {
      return await _service.createPost(
        ownerId: request.ownerId,
        ownerName: request.ownerName,
        ownerEmail: request.ownerEmail,
        rollNumber: request.rollNumber,
        department: request.department,
        semester: request.semester,
        title: request.title,
        description: request.description,
        projectType: request.projectType,
        skillsNeeded: request.skillsNeeded,
        slotsTotal: request.slotsTotal,
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to create post');
    }
  }

  @override
  Future<TeamApplicationModel> applyToPost(ApplyToPostRequest request) async {
    if (request.postId.trim().isEmpty || request.applicantId.trim().isEmpty) {
      throw TeamFinderRepositoryException(
        'postId and applicantId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      return await _service.applyToPost(
        postId: request.postId,
        applicantId: request.applicantId,
        applicantName: request.applicantName,
        applicantEmail: request.applicantEmail,
        rollNumber: request.rollNumber,
        department: request.department,
        semester: request.semester,
        message: request.message,
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to apply');
    }
  }

  @override
  Future<void> withdrawApplication({
    required String applicationId,
    required String applicantId,
  }) async {
    if (applicationId.trim().isEmpty || applicantId.trim().isEmpty) {
      throw TeamFinderRepositoryException(
        'applicationId and applicantId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.withdrawApplication(
        applicationId: applicationId,
        applicantId: applicantId,
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to withdraw application');
    }
  }

  @override
  Future<void> respondToApplication({
    required String applicationId,
    required String ownerId,
    required bool accept,
  }) async {
    if (applicationId.trim().isEmpty || ownerId.trim().isEmpty) {
      throw TeamFinderRepositoryException(
        'applicationId and ownerId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.respondToApplication(
        applicationId: applicationId,
        ownerId: ownerId,
        accept: accept,
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to respond to application');
    }
  }

  @override
  Future<void> closePost({
    required String postId,
    required String ownerId,
  }) async {
    if (postId.trim().isEmpty || ownerId.trim().isEmpty) {
      throw TeamFinderRepositoryException(
        'postId and ownerId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.closePost(postId: postId, ownerId: ownerId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to close post');
    }
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String ownerId,
  }) async {
    if (postId.trim().isEmpty || ownerId.trim().isEmpty) {
      throw TeamFinderRepositoryException(
        'postId and ownerId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.deletePost(postId: postId, ownerId: ownerId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to delete post');
    }
  }

  void _validateCreateRequest(CreatePostRequest request) {
    final missing = <String>[];
    if (request.ownerId.trim().isEmpty) missing.add('ownerId');
    if (request.title.trim().isEmpty) missing.add('title');
    if (request.description.trim().isEmpty) missing.add('description');
    if (request.projectType.trim().isEmpty) missing.add('projectType');
    if (request.slotsTotal < 1) missing.add('slotsTotal (must be >= 1)');
    if (missing.isNotEmpty) {
      throw TeamFinderRepositoryException(
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

  TeamFinderRepositoryException _mapError(
    dynamic error,
    StackTrace stackTrace, {
    required String context,
  }) {
    if (error is TeamFinderRepositoryException) return error;
    final errorString = error.toString();
    if (errorString.startsWith('TeamFinderException:')) {
      final message = errorString.replaceFirst('TeamFinderException: ', '');
      return TeamFinderRepositoryException(
        message,
        code: 'team-finder-error',
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
    return TeamFinderRepositoryException(
      '$context: $errorString',
      code: code,
      originalError: error,
    );
  }
}
