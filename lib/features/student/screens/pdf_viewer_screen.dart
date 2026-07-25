import 'dart:io';

import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _loading = true;
  bool _downloading = false;
  double _progress = 0.0;
  String? _localPath;
  String? _error;

  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? pdfController;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  /// Builds a stable, filesystem-safe filename from the PDF URL so the
  /// same document maps to the same cached file every time.
  String _cacheFileNameForUrl(String url) {
    final hash = md5.convert(utf8.encode(url)).toString();
    return '$hash.pdf';
  }

  /// Shortens a filename for AppBar display, keeping the extension visible.
  /// e.g. "Ganesh_Chapagain_Final_Assignment_Submission_v2.pdf"
  ///   -> "Ganesh_Chapagain_Fi....pdf"
  String _shortenTitle(String title, {int maxLength = 24}) {
    if (title.length <= maxLength) return title;

    final dotIndex = title.lastIndexOf('.');
    final hasExt = dotIndex > 0 && dotIndex > title.length - 6;
    final ext = hasExt ? title.substring(dotIndex) : '';
    final nameOnly = hasExt ? title.substring(0, dotIndex) : title;

    final keep = maxLength - ext.length - 3; // 3 chars for "..."
    if (keep <= 0) return title;

    return '${nameOnly.substring(0, keep)}...$ext';
  }

  Future<void> _loadPdf() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final fileName = _cacheFileNameForUrl(widget.pdfUrl);
      final file = File('${dir.path}/$fileName');

      if (await file.exists() && await file.length() > 0) {
        // Reuse cached file, skip network call entirely.
        if (!mounted) return;
        setState(() {
          _localPath = file.path;
          _loading = false;
        });
        return;
      }

      await _downloadPdf(file);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(e);
        _loading = false;
      });
    }
  }

  Future<void> _downloadPdf(File file) async {
    setState(() {
      _downloading = true;
      _progress = 0.0;
    });

    try {
      await Dio().download(
        widget.pdfUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          if (!mounted) return;
          setState(() {
            _progress = received / total;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _localPath = file.path;
        _loading = false;
        _downloading = false;
      });
    } catch (e) {
      // Clean up any partial file so a retry doesn't pick up junk.
      if (await file.exists()) {
        await file.delete().catchError((_) => file);
      }
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(e);
        _loading = false;
        _downloading = false;
      });
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'The connection timed out. Please check your internet and try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please try again.';
        default:
          return 'Could not download this document. Please try again.';
      }
    }
    return 'Something went wrong while opening this document.';
  }

  Future<void> _retry() async {
    await _loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        title: Text(
          _shortenTitle(widget.title),
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        actions: [
          if (_localPath != null && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return _buildErrorView(context);
    }

    if (_loading) {
      return _buildLoadingView(context);
    }

    if (_localPath == null) {
      return _buildErrorView(context);
    }

    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageSnap: true,
          pageFling: true,
          fitPolicy: FitPolicy.BOTH,
          nightMode: false,
          onRender: (pages) {
            if (!mounted) return;
            setState(() {
              _totalPages = pages ?? 0;
            });
          },
          onPageChanged: (page, total) {
            if (!mounted) return;
            setState(() {
              _currentPage = page ?? 0;
              if (total != null) _totalPages = total;
            });
          },
          onViewCreated: (controller) {
            pdfController = controller;
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _error = 'This document could not be displayed.';
            });
          },
          onPageError: (page, error) {
            debugPrint('Error on page $page: $error');
          },
        ),
      ],
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              value: _downloading && _progress > 0 ? _progress : null,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _downloading ? 'Downloading document…' : 'Opening document…',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          if (_downloading && _progress > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to open document',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unexpected error occurred.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
