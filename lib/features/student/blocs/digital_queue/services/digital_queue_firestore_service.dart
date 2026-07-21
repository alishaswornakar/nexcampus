import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/queue_history_model.dart';
import '../models/queue_service_model.dart';
import '../models/queue_token_model.dart';

/// Thrown for any predictable, user-facing failure inside the queue service.
/// The Repository/BLoC layer should catch this and map it to UI-friendly
/// failure states instead of letting raw Firestore exceptions leak upward.
class QueueException implements Exception {
  final String message;
  QueueException(this.message);

  @override
  String toString() => 'QueueException: $message';
}

/// Data-layer service responsible for ALL direct Firestore access for the
/// Digital Queue Management feature.
///
/// Collections used:
/// - `queue_services` : one doc per service/counter (e.g. Library, Accounts)
/// - `queue_tokens`    : one doc per active/recent token issued to a student
/// - `queue_history`   : permanent archive of completed/cancelled tokens
///
/// Design notes:
/// - Token documents use a **deterministic ID** of
///   `{serviceId}_{studentId}_{yyyyMMdd}`. This guarantees — at the database
///   level, inside a transaction — that a student can never hold two active
///   tokens for the same service on the same day, without needing a
///   secondary query (Firestore transactions can only `get()` by reference,
///   not run queries).
/// - `queue_services.currentToken` and `queue_services.totalWaiting` act as
///   atomic counters. `totalWaiting` doubles as the "next queue position"
///   when a token is appended to the back of the line.
/// - Position recalculation (after a cancel/complete) is done via a
///   `WriteBatch` immediately after the transaction commits, since it can
///   touch an unbounded number of documents.
/// - Models expose a single-argument `fromMap(Map)` where the map itself
///   must contain the `id` key — so every read merges `doc.id` into the
///   data map before decoding: `{...doc.data(), 'id': doc.id}`.
class DigitalQueueFirestoreService {
  DigitalQueueFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------
  // Collection references
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _servicesRef =>
      _firestore.collection('queue_services');

  CollectionReference<Map<String, dynamic>> get _tokensRef =>
      _firestore.collection('queue_tokens');

  CollectionReference<Map<String, dynamic>> get _historyRef =>
      _firestore.collection('queue_history');

  /// Statuses that count as "the student currently holds this token".
  static const List<String> _activeStatuses = <String>[
    QueueStatus.waiting,
    QueueStatus.serving,
  ];

  /// Terminal statuses that trigger archiving into `queue_history`.
  static const List<String> _terminalStatuses = <String>[
    QueueStatus.completed,
    QueueStatus.cancelled,
    QueueStatus.missed,
  ];

  // ---------------------------------------------------------------------
  // Decoding helpers (merge doc.id into the map before calling fromMap)
  // ---------------------------------------------------------------------

  QueueServiceModel _decodeService(DocumentSnapshot<Map<String, dynamic>> doc) {
    return QueueServiceModel.fromMap({...doc.data()!, 'id': doc.id});
  }

  QueueTokenModel _decodeToken(DocumentSnapshot<Map<String, dynamic>> doc) {
    return QueueTokenModel.fromMap({...doc.data()!, 'id': doc.id});
  }

  QueueHistoryModel _decodeHistory(DocumentSnapshot<Map<String, dynamic>> doc) {
    return QueueHistoryModel.fromMap({...doc.data()!, 'id': doc.id});
  }

  /// Formats a [DateTime] as `yyyy-MM-dd`, matching the string format stored
  /// in `queueDate` fields and used to build deterministic document ids.
  String _formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '-${date.month.toString().padLeft(2, '0')}'
        '-${date.day.toString().padLeft(2, '0')}';
  }

  // =====================================================================
  // STREAMS (real-time)
  // =====================================================================

  /// Streams all queue services ordered for display (e.g. on a student's
  /// "choose a service" screen).
  Stream<List<QueueServiceModel>> streamQueueServices() {
    try {
      return _servicesRef
          .orderBy('displayOrder')
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_decodeService).toList());
    } catch (e) {
      throw QueueException('Failed to stream queue services: $e');
    }
  }

  /// Streams a single queue service by id (e.g. to watch `currentToken` /
  /// `totalWaiting` live on a "your position" screen).
  Stream<QueueServiceModel?> streamQueueService({required String serviceId}) {
    try {
      return _servicesRef.doc(serviceId).snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return null;
        return _decodeService(snapshot);
      });
    } catch (e) {
      throw QueueException('Failed to stream queue service: $e');
    }
  }

  /// Streams the student's current active token (status `waiting` or
  /// `serving`) across ALL services. Returns `null` when the student has
  /// no active token. Intended for a persistent "your token" banner/widget.
  Stream<QueueTokenModel?> streamStudentActiveToken({
    required String studentId,
  }) {
    try {
      return _tokensRef
          .where('studentId', isEqualTo: studentId)
          .where('status', whereIn: _activeStatuses)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return null;
            return _decodeToken(snapshot.docs.first);
          });
    } catch (e) {
      throw QueueException('Failed to stream active token: $e');
    }
  }

  /// Streams the live waiting list for a specific service, ordered by
  /// position. Useful for a counter/admin display and internally for
  /// verifying recalculation results.
  Stream<List<QueueTokenModel>> streamServiceWaitingTokens({
    required String serviceId,
  }) {
    try {
      return _tokensRef
          .where('serviceId', isEqualTo: serviceId)
          .where('status', isEqualTo: QueueStatus.waiting)
          .orderBy('queuePosition')
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_decodeToken).toList());
    } catch (e) {
      throw QueueException('Failed to stream service queue: $e');
    }
  }

  /// Streams a student's queue history, most recent first.
  Stream<List<QueueHistoryModel>> streamQueueHistory({
    required String studentId,
    int limit = 50,
  }) {
    try {
      return _historyRef
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_decodeHistory).toList());
    } catch (e) {
      throw QueueException('Failed to stream queue history: $e');
    }
  }

  // =====================================================================
  // ONE-TIME READS
  // =====================================================================

  /// Fetches a single service document once (non-streaming).
  Future<QueueServiceModel> getQueueServiceOnce({
    required String serviceId,
  }) async {
    try {
      final snapshot = await _servicesRef.doc(serviceId).get();
      if (!snapshot.exists || snapshot.data() == null) {
        throw QueueException('Queue service not found');
      }
      return _decodeService(snapshot);
    } on QueueException {
      rethrow;
    } catch (e) {
      throw QueueException('Failed to fetch queue service: $e');
    }
  }

  /// Fetches the student's active token once (non-streaming). Returns
  /// `null` if none exists.
  Future<QueueTokenModel?> getStudentActiveTokenOnce({
    required String studentId,
  }) async {
    try {
      final snapshot = await _tokensRef
          .where('studentId', isEqualTo: studentId)
          .where('status', whereIn: _activeStatuses)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return _decodeToken(snapshot.docs.first);
    } catch (e) {
      throw QueueException('Failed to fetch active token: $e');
    }
  }

  // =====================================================================
  // TOKEN GENERATION
  // =====================================================================

  /// Builds the deterministic token document id that enforces
  /// "one active token per student per service per day" at write time.
  String _buildTokenDocId({
    required String serviceId,
    required String studentId,
    required DateTime queueDate,
  }) {
    final dateKey =
        '${queueDate.year}${queueDate.month.toString().padLeft(2, '0')}'
        '${queueDate.day.toString().padLeft(2, '0')}';
    return '${serviceId}_${studentId}_$dateKey';
  }

  /// Generates a new queue token for a student for the given [serviceId].
  ///
  /// Guarantees, all inside a single Firestore transaction:
  /// - The service exists and is currently open.
  /// - The student does not already hold an active (waiting/serving) token
  ///   for this service today (enforced via the deterministic doc id).
  /// - The token number is generated atomically from
  ///   `queue_services.currentToken`.
  /// - The queue position is the new `totalWaiting` count (i.e. the token
  ///   is appended to the back of the line).
  /// - The estimated wait time is `queuePosition * averageServiceTime`.
  ///
  /// [priority] follows the model's `int` convention (e.g. `0` = normal,
  /// higher values = higher priority) — adjust the scale to match your
  /// UI/business rules.
  Future<QueueTokenModel> generateQueueToken({
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String rollNumber,
    required String department,
    required String semester,
    required String serviceId,
    int priority = 0,
    String deviceToken = '',
  }) async {
    final now = DateTime.now();
    final tokenDocId = _buildTokenDocId(
      serviceId: serviceId,
      studentId: studentId,
      queueDate: now,
    );
    final tokenRef = _tokensRef.doc(tokenDocId);
    final serviceRef = _servicesRef.doc(serviceId);

    try {
      return await _firestore.runTransaction<QueueTokenModel>((txn) async {
        // --- Reads must happen before any writes in a transaction ---
        final serviceSnap = await txn.get(serviceRef);
        if (!serviceSnap.exists || serviceSnap.data() == null) {
          throw QueueException('Queue service not found');
        }
        final serviceData = serviceSnap.data()!;

        final isOpen = serviceData['isOpen'] as bool? ?? false;
        if (!isOpen) {
          throw QueueException('This queue service is currently closed');
        }

        final existingSnap = await txn.get(tokenRef);
        if (existingSnap.exists) {
          final existingStatus = existingSnap.data()?['status'] as String?;
          if (existingStatus != null &&
              _activeStatuses.contains(existingStatus)) {
            throw QueueException(
              'You already have an active token for this service today',
            );
          }
        }

        final currentToken =
            (serviceData['currentToken'] as num?)?.toInt() ?? 0;
        final totalWaiting =
            (serviceData['totalWaiting'] as num?)?.toInt() ?? 0;
        final averageServiceTime =
            (serviceData['averageServiceTime'] as num?)?.toInt() ?? 5;
        final counterName = serviceData['counterName'] as String? ?? '';
        final serviceName = serviceData['name'] as String? ?? '';

        final newTokenNumber = currentToken + 1;
        final newTotalWaiting = totalWaiting + 1;
        // New token always joins the back of the line.
        final queuePosition = newTotalWaiting;
        final estimatedWaitMinutes = queuePosition * averageServiceTime;

        final tokenModel = QueueTokenModel(
          id: tokenDocId,
          studentId: studentId,
          studentName: studentName,
          studentEmail: studentEmail,
          rollNumber: rollNumber,
          department: department,
          semester: semester,
          priority: priority,
          queueDate: _formatDateKey(now),
          deviceToken: deviceToken,
          serviceId: serviceId,
          serviceName: serviceName,
          tokenNumber: newTokenNumber,
          queuePosition: queuePosition,
          estimatedWaitMinutes: estimatedWaitMinutes,
          status: QueueStatus.waiting,
          counterName: counterName,
          createdAt: now,
          calledAt: null,
          completedAt: null,
          cancelledAt: null,
        );

        // --- Writes ---
        txn.set(tokenRef, tokenModel.toMap());
        txn.update(serviceRef, {
          'currentToken': newTokenNumber,
          'totalWaiting': newTotalWaiting,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return tokenModel;
      });
    } on QueueException {
      rethrow;
    } catch (e) {
      throw QueueException('Failed to generate queue token: $e');
    }
  }

  // =====================================================================
  // CANCEL TOKEN
  // =====================================================================

  /// Cancels a student's own token. Only `waiting` or `serving` tokens can
  /// be cancelled. On success the token is archived into `queue_history`
  /// and remaining waiting tokens for the service have their positions
  /// shifted down by one.
  Future<void> cancelToken({
    required String tokenId,
    required String studentId,
  }) async {
    final tokenRef = _tokensRef.doc(tokenId);
    String? serviceId;
    int removedPosition = 0;
    bool wasWaiting = false;

    try {
      await _firestore.runTransaction((txn) async {
        final tokenSnap = await txn.get(tokenRef);
        if (!tokenSnap.exists || tokenSnap.data() == null) {
          throw QueueException('Token not found');
        }
        final data = tokenSnap.data()!;

        if (data['studentId'] != studentId) {
          throw QueueException('You are not authorized to cancel this token');
        }

        final status = data['status'] as String? ?? '';
        if (!_activeStatuses.contains(status)) {
          throw QueueException(
            'Only waiting or serving tokens can be cancelled',
          );
        }

        serviceId = data['serviceId'] as String;
        removedPosition = (data['queuePosition'] as num?)?.toInt() ?? 0;
        wasWaiting = status == QueueStatus.waiting;

        final now = DateTime.now();
        txn.update(tokenRef, {
          'status': QueueStatus.cancelled,
          'cancelledAt': Timestamp.fromDate(now),
        });

        // Only decrement totalWaiting if the token was actually occupying
        // a waiting slot (a token already 'serving' isn't counted in it).
        if (wasWaiting) {
          final serviceRef = _servicesRef.doc(serviceId!);
          txn.update(serviceRef, {
            'totalWaiting': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      await _archiveTokenById(tokenId);

      if (wasWaiting && serviceId != null && removedPosition > 0) {
        await _recalculateQueuePositions(
          serviceId: serviceId!,
          removedPosition: removedPosition,
        );
      }
    } on QueueException {
      rethrow;
    } catch (e) {
      throw QueueException('Failed to cancel token: $e');
    }
  }

  // =====================================================================
  // COMPLETE TOKEN
  // =====================================================================

  /// Marks a token as completed (called by counter staff once service is
  /// rendered). Archives the token and shifts remaining positions down.
  Future<void> completeToken({
    required String tokenId,
    String? counterName,
  }) async {
    final tokenRef = _tokensRef.doc(tokenId);
    String? serviceId;
    int removedPosition = 0;
    bool wasWaiting = false;

    try {
      await _firestore.runTransaction((txn) async {
        final tokenSnap = await txn.get(tokenRef);
        if (!tokenSnap.exists || tokenSnap.data() == null) {
          throw QueueException('Token not found');
        }
        final data = tokenSnap.data()!;

        final status = data['status'] as String? ?? '';
        if (!_activeStatuses.contains(status)) {
          throw QueueException(
            'Token cannot be completed from its current status',
          );
        }

        serviceId = data['serviceId'] as String;
        removedPosition = (data['queuePosition'] as num?)?.toInt() ?? 0;
        wasWaiting = status == QueueStatus.waiting;

        final now = DateTime.now();
        final updateData = <String, dynamic>{
          'status': QueueStatus.completed,
          'completedAt': Timestamp.fromDate(now),
        };
        if (counterName != null) updateData['counterName'] = counterName;

        txn.update(tokenRef, updateData);

        if (wasWaiting) {
          final serviceRef = _servicesRef.doc(serviceId!);
          txn.update(serviceRef, {
            'totalWaiting': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      await _archiveTokenById(tokenId);

      if (wasWaiting && serviceId != null && removedPosition > 0) {
        await _recalculateQueuePositions(
          serviceId: serviceId!,
          removedPosition: removedPosition,
        );
      }
    } on QueueException {
      rethrow;
    } catch (e) {
      throw QueueException('Failed to complete token: $e');
    }
  }

  // =====================================================================
  // MARK TOKEN AS MISSED (student didn't respond when called)
  // =====================================================================

  /// Marks a `serving` token as `missed` (e.g. student didn't show up
  /// after being called). Archives it into history. Since a `serving`
  /// token no longer occupies a waiting slot, no position recalculation
  /// is required.
  Future<void> markTokenAsMissed({required String tokenId}) async {
    final tokenRef = _tokensRef.doc(tokenId);
    try {
      await _firestore.runTransaction((txn) async {
        final tokenSnap = await txn.get(tokenRef);
        if (!tokenSnap.exists || tokenSnap.data() == null) {
          throw QueueException('Token not found');
        }
        final status = tokenSnap.data()!['status'] as String? ?? '';
        if (status != QueueStatus.serving) {
          throw QueueException(
            'Only a token being served can be marked missed',
          );
        }
        txn.update(tokenRef, {
          'status': QueueStatus.missed,
          'completedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      await _archiveTokenById(tokenId);
    } on QueueException {
      rethrow;
    } catch (e) {
      throw QueueException('Failed to mark token as missed: $e');
    }
  }

  // =====================================================================
  // CALL NEXT TOKEN (counter/admin action)
  // =====================================================================

  /// Calls the next `waiting` token (lowest `queuePosition`) for a service
  /// to a given counter, transitioning it to `serving`. Returns `null` if
  /// the queue is empty. Guards against a race where another
  /// call/cancel already changed the token's status between the initial
  /// query and the transaction.
  Future<QueueTokenModel?> callNextToken({
    required String serviceId,
    required String counterName,
  }) async {
    try {
      final query = await _tokensRef
          .where('serviceId', isEqualTo: serviceId)
          .where('status', isEqualTo: QueueStatus.waiting)
          .orderBy('queuePosition')
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final tokenRef = query.docs.first.reference;

      return await _firestore.runTransaction<QueueTokenModel?>((txn) async {
        final snap = await txn.get(tokenRef);
        if (!snap.exists || snap.data() == null) return null;
        final data = Map<String, dynamic>.from(snap.data()!);

        if (data['status'] != QueueStatus.waiting) {
          // Someone else already grabbed/cancelled it — nothing to do.
          return null;
        }

        final now = DateTime.now();
        data['id'] = tokenRef.id;
        data['status'] = QueueStatus.serving;
        data['calledAt'] = Timestamp.fromDate(now);
        data['counterName'] = counterName;

        txn.update(tokenRef, {
          'status': QueueStatus.serving,
          'calledAt': Timestamp.fromDate(now),
          'counterName': counterName,
        });

        return QueueTokenModel.fromMap(data);
      });
    } catch (e) {
      throw QueueException('Failed to call next token: $e');
    }
  }

  // =====================================================================
  // INTERNAL HELPERS
  // =====================================================================

  /// Copies a token document into `queue_history` using the token's own id
  /// (kept identical across collections for easy cross-referencing), then
  /// removes it from the live `queue_tokens` collection so that collection
  /// only ever holds active/very-recent tokens.
  Future<void> _archiveTokenById(String tokenId) async {
    final tokenRef = _tokensRef.doc(tokenId);
    final snapshot = await tokenRef.get();
    final data = snapshot.data();
    if (data == null) return;

    final status = data['status'] as String? ?? '';
    if (!_terminalStatuses.contains(status)) {
      // Safety guard: never archive a token that isn't actually terminal.
      return;
    }

    final historyModel = QueueHistoryModel(
      id: tokenId,
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      rollNumber: data['rollNumber'] as String? ?? '',
      serviceId: data['serviceId'] as String? ?? '',
      serviceName: data['serviceName'] as String? ?? '',
      counterName: data['counterName'] as String? ?? '',
      tokenNumber: (data['tokenNumber'] as num?)?.toInt() ?? 0,
      status: status,
      queueDate: data['queueDate'] as String? ?? '',
      createdAt: _asDateTime(data['createdAt']) ?? DateTime.now(),
      completedAt: _asDateTime(data['completedAt']),
    );

    final batch = _firestore.batch();
    batch.set(_historyRef.doc(tokenId), historyModel.toMap());
    batch.delete(tokenRef);
    await batch.commit();
  }

  /// Shifts down, by one, the `queuePosition` (and recalculates
  /// `estimatedWaitMinutes`) of every waiting token positioned behind the
  /// one that was just removed from a service's queue.
  Future<void> _recalculateQueuePositions({
    required String serviceId,
    required int removedPosition,
  }) async {
    try {
      final serviceSnap = await _servicesRef.doc(serviceId).get();
      final averageServiceTime =
          (serviceSnap.data()?['averageServiceTime'] as num?)?.toInt() ?? 5;

      final affected = await _tokensRef
          .where('serviceId', isEqualTo: serviceId)
          .where('status', isEqualTo: QueueStatus.waiting)
          .where('queuePosition', isGreaterThan: removedPosition)
          .orderBy('queuePosition')
          .get();

      if (affected.docs.isEmpty) return;

      // Firestore batches cap at 500 writes; chunk defensively.
      const chunkSize = 450;
      for (var i = 0; i < affected.docs.length; i += chunkSize) {
        final chunk = affected.docs.sublist(
          i,
          (i + chunkSize > affected.docs.length)
              ? affected.docs.length
              : i + chunkSize,
        );
        final batch = _firestore.batch();
        for (final doc in chunk) {
          final currentPosition = (doc.data()['queuePosition'] as num).toInt();
          final newPosition = currentPosition - 1;
          batch.update(doc.reference, {
            'queuePosition': newPosition,
            'estimatedWaitMinutes': newPosition * averageServiceTime,
          });
        }
        await batch.commit();
      }
    } catch (e) {
      throw QueueException('Failed to recalculate queue positions: $e');
    }
  }

  /// Safely converts a Firestore field (Timestamp, or already-null) into a
  /// nullable [DateTime].
  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
