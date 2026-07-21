// lib/features/student/blocs/digital_queue/repository/digital_queue_repository.dart

import 'dart:async';

import '../models/queue_service_model.dart';
import '../models/queue_token_model.dart';
import '../models/queue_history_model.dart';
import '../services/digital_queue_firestore_service.dart';

/// -----------------------------------------------------------------------
/// EXCEPTIONS
/// -----------------------------------------------------------------------
/// Repository-level exception. Normalizes both raw Firestore errors and
/// the service's own [QueueException] into one type, so the BLoC only
/// ever needs to catch this.
class QueueRepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  QueueRepositoryException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'QueueRepositoryException(code: $code, message: $message)';
}

/// -----------------------------------------------------------------------
/// REQUEST MODEL
/// -----------------------------------------------------------------------
/// NOTE: `serviceName` and `counterName` are intentionally NOT included.
/// `DigitalQueueFirestoreService.generateQueueToken` reads both directly
/// from the `queue_services` document inside its transaction — passing
/// them here would let stale/incorrect client-side values silently
/// override the source of truth.
class JoinQueueRequest {
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String rollNumber;
  final String department;
  final String semester;
  final String serviceId;
  final int priority;
  final String deviceToken;

  const JoinQueueRequest({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.serviceId,
    this.priority = 0,
    this.deviceToken = '',
  });
}

/// -----------------------------------------------------------------------
/// REPOSITORY CONTRACT
/// -----------------------------------------------------------------------
abstract class DigitalQueueRepository {
  Stream<List<QueueServiceModel>> watchQueueServices();

  Stream<QueueServiceModel?> watchQueueService(String serviceId);

  /// Real-time active token (waiting/serving) for a student, across all
  /// services. Emits null when the student has no active token.
  Stream<QueueTokenModel?> watchActiveToken(String studentId);

  Stream<List<QueueHistoryModel>> watchQueueHistory(
    String studentId, {
    int limit,
  });

  Future<QueueTokenModel?> fetchActiveTokenOnce(String studentId);

  /// Joins a queue. `serviceName`/`counterName` are resolved server-side
  /// from the `queue_services` doc — see [JoinQueueRequest].
  Future<QueueTokenModel> joinQueue(JoinQueueRequest request);

  Future<void> cancelToken({
    required String tokenId,
    required String studentId,
  });
}

/// -----------------------------------------------------------------------
/// REPOSITORY IMPLEMENTATION
/// -----------------------------------------------------------------------
class DigitalQueueRepositoryImpl implements DigitalQueueRepository {
  final DigitalQueueFirestoreService _service;

  DigitalQueueRepositoryImpl({DigitalQueueFirestoreService? service})
    : _service = service ?? DigitalQueueFirestoreService();

  // -----------------------------------------------------------------
  // STREAMS
  // -----------------------------------------------------------------

  @override
  Stream<List<QueueServiceModel>> watchQueueServices() {
    return _wrapStream(
      _service.streamQueueServices(),
      context: 'Failed to load queue services',
    );
  }

  @override
  Stream<QueueServiceModel?> watchQueueService(String serviceId) {
    if (serviceId.trim().isEmpty) {
      return Stream.error(
        QueueRepositoryException(
          'serviceId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamQueueService(serviceId: serviceId),
      context: 'Failed to load queue service',
    );
  }

  @override
  Stream<QueueTokenModel?> watchActiveToken(String studentId) {
    if (studentId.trim().isEmpty) {
      return Stream.error(
        QueueRepositoryException(
          'studentId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamStudentActiveToken(studentId: studentId),
      context: 'Failed to load active token',
    );
  }

  @override
  Stream<List<QueueHistoryModel>> watchQueueHistory(
    String studentId, {
    int limit = 50,
  }) {
    if (studentId.trim().isEmpty) {
      return Stream.error(
        QueueRepositoryException(
          'studentId must not be empty',
          code: 'invalid-argument',
        ),
      );
    }
    return _wrapStream(
      _service.streamQueueHistory(studentId: studentId, limit: limit),
      context: 'Failed to load queue history',
    );
  }

  // -----------------------------------------------------------------
  // FUTURES
  // -----------------------------------------------------------------

  @override
  Future<QueueTokenModel?> fetchActiveTokenOnce(String studentId) async {
    if (studentId.trim().isEmpty) {
      throw QueueRepositoryException(
        'studentId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      return await _service.getStudentActiveTokenOnce(studentId: studentId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to fetch active token');
    }
  }

  @override
  Future<QueueTokenModel> joinQueue(JoinQueueRequest request) async {
    _validateJoinRequest(request);
    try {
      return await _service.generateQueueToken(
        studentId: request.studentId,
        studentName: request.studentName,
        studentEmail: request.studentEmail,
        rollNumber: request.rollNumber,
        department: request.department,
        semester: request.semester,
        serviceId: request.serviceId,
        priority: request.priority,
        deviceToken: request.deviceToken,
      );
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to join queue');
    }
  }

  @override
  Future<void> cancelToken({
    required String tokenId,
    required String studentId,
  }) async {
    if (tokenId.trim().isEmpty || studentId.trim().isEmpty) {
      throw QueueRepositoryException(
        'tokenId and studentId must not be empty',
        code: 'invalid-argument',
      );
    }
    try {
      await _service.cancelToken(tokenId: tokenId, studentId: studentId);
    } catch (e, st) {
      throw _mapError(e, st, context: 'Failed to cancel token');
    }
  }

  // -----------------------------------------------------------------
  // PRIVATE HELPERS
  // -----------------------------------------------------------------

  void _validateJoinRequest(JoinQueueRequest request) {
    final missingFields = <String>[];
    if (request.studentId.trim().isEmpty) missingFields.add('studentId');
    if (request.studentName.trim().isEmpty) missingFields.add('studentName');
    if (request.studentEmail.trim().isEmpty) {
      missingFields.add('studentEmail');
    }
    if (request.rollNumber.trim().isEmpty) missingFields.add('rollNumber');
    if (request.department.trim().isEmpty) missingFields.add('department');
    if (request.semester.trim().isEmpty) missingFields.add('semester');
    if (request.serviceId.trim().isEmpty) missingFields.add('serviceId');

    if (missingFields.isNotEmpty) {
      throw QueueRepositoryException(
        'Missing required field(s): ${missingFields.join(', ')}',
        code: 'invalid-argument',
      );
    }
  }

  /// Wraps a raw stream so any mid-stream error (Firestore error, or the
  /// service's own [QueueException]) is normalized before reaching the
  /// BLoC.
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

  /// Normalizes any caught error into a [QueueRepositoryException].
  ///
  /// The service throws its own `QueueException` (message-only, no error
  /// code) for predictable failures — e.g. "queue closed", "already have
  /// an active token", "not authorized". We tag those with
  /// `code: 'queue-error'` so the BLoC/UI can distinguish a friendly,
  /// already-readable message from a raw Firestore/platform error.
  /// Genuine `FirebaseException`s (permission-denied, unavailable, etc.)
  /// still get their real `.code` via the dynamic fallback below.
  QueueRepositoryException _mapError(
    dynamic error,
    StackTrace stackTrace, {
    required String context,
  }) {
    if (error is QueueRepositoryException) return error;

    final errorString = error.toString();

    // The service's QueueException has no .code — recognize it by type
    // name so its message (already human-readable) passes through
    // cleanly instead of being wrapped in a generic Firestore-style code.
    if (errorString.startsWith('QueueException:')) {
      final message = errorString.replaceFirst('QueueException: ', '');
      return QueueRepositoryException(
        message,
        code: 'queue-error',
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

    return QueueRepositoryException(
      '$context: $errorString',
      code: code,
      originalError: error,
    );
  }
}
