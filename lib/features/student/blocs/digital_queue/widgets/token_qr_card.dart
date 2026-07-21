// lib/features/student/blocs/digital_queue/widgets/token_qr_card.dart

import 'package:flutter/material.dart';

/// Displays the student's token as a scannable code for staff to
/// verify at the counter.
///
/// PLACEHOLDER NOTICE: `qr_flutter` isn't in pubspec.yaml yet, so this
/// renders a clean, styled token-ID box instead of an actual QR image.
/// Nothing else in the feature depends on this widget's internals —
/// once you add the package, replace only the body of [_CodeArea] below
/// with a real QR widget. The steps are:
///
///   1. Add to pubspec.yaml:  qr_flutter: ^4.1.0  (check latest)
///   2. Run: flutter pub get
///   3. Add import: import 'package:qr_flutter/qr_flutter.dart';
///   4. Replace the `_CodeArea` body with:
///        QrImageView(
///          data: tokenId,
///          version: QrVersions.auto,
///          size: 180,
///        )
///
/// Everything else (card chrome, token number label, service name)
/// stays exactly the same.
class TokenQrCard extends StatelessWidget {
  const TokenQrCard({
    super.key,
    required this.tokenId,
    required this.tokenNumber,
    required this.serviceName,
  });

  final String tokenId;
  final int tokenNumber;
  final String serviceName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            'Show this at the counter',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _CodeArea(tokenId: tokenId),
          const SizedBox(height: 12),
          Text(
            '$serviceName · Token #$tokenNumber',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Isolated so swapping in a real QR widget later touches only this
/// one class.
class _CodeArea extends StatelessWidget {
  const _CodeArea({required this.tokenId});

  final String tokenId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              tokenId,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
