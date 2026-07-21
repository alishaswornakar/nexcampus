// lib/features/student/blocs/digital_queue/widgets/queue_icon_resolver.dart

import 'package:flutter/material.dart';

/// Resolves the `icon` string stored on a `queue_services` document
/// (e.g. "library", "accounts", "exam") to a concrete [IconData].
///
/// ASSUMPTION: `QueueServiceModel.icon` is a String key, not a raw
/// codepoint. If your model actually stores an icon codepoint (int) or
/// a Material icon name differently, tell me and I'll adjust this
/// mapping — every widget below only depends on this one function.
IconData resolveQueueIcon(String iconKey) {
  switch (iconKey.toLowerCase().trim()) {
    case 'library':
      return Icons.local_library_outlined;
    case 'accounts':
    case 'finance':
      return Icons.account_balance_wallet_outlined;
    case 'exam':
    case 'examination':
      return Icons.assignment_outlined;
    case 'admission':
      return Icons.school_outlined;
    case 'hostel':
      return Icons.home_work_outlined;
    case 'transport':
      return Icons.directions_bus_outlined;
    case 'medical':
    case 'health':
      return Icons.medical_services_outlined;
    case 'it':
    case 'tech':
      return Icons.computer_outlined;
    default:
      return Icons.confirmation_number_outlined;
  }
}
