import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

/// In-app PDF viewer for notice attachments.
///
/// Downloads the PDF at [pdfUrl] into a temp file (once — reused if already
/// present) and renders it with `flutter_pdfview`, so students can read the
/// attachment right inside the app instead of downloading it and relying on
/// a third-party PDF app / browser.
class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath;
  String? _error;

  int _currentPage = 0;
  int _totalPages = 0;
  bool _isRendered = false;

  PDFViewController? pdfController;

  @override
  void initState() {
    super.initState();
    _downloadAndLoad();
  }

  Future<void> _downloadAndLoad() async {
    setState(() {
      _error = null;
      _localPath = null;
      _isRendered = false;
    });

    try {
      final dir = await getTemporaryDirectory();

      // Derive a stable, filesystem-safe file name from the URL so repeat
      // visits to the same notice reuse the cached download.
      final rawName = widget.pdfUrl.split('/').last.split('?').first;
      final fileName = rawName.toLowerCase().endsWith('.pdf')
          ? rawName
          : '$rawName.pdf';
      final filePath = '${dir.path}/$fileName';

      final file = File(filePath);

      if (!await file.exists()) {
        await Dio().download(widget.pdfUrl, filePath);
      }

      if (!mounted) return;
      setState(() => _localPath = filePath);
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 401) {
        setState(() {
          _error =
              'This PDF isn\'t available right now.\nAsk your teacher to '
              're-check the attachment settings.';
        });
      } else {
        setState(() => _error = 'Could not load the attachment.\n$e');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not load the attachment.\n$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        actions: [
          if (_isRendered && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _downloadAndLoad,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_localPath == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.BOTH,
          defaultPage: _currentPage,
          onRender: (pages) {
            setState(() {
              _totalPages = pages ?? 0;
              _isRendered = true;
            });
          },
          onViewCreated: (controller) {
            pdfController = controller;
          },
          onPageChanged: (page, total) {
            setState(() {
              _currentPage = page ?? 0;
              if (total != null) _totalPages = total;
            });
          },
          onError: (error) {
            setState(() => _error = 'Failed to render PDF.\n$error');
          },
          onPageError: (page, error) {
            setState(() => _error = 'Error on page $page.\n$error');
          },
        ),
        if (!_isRendered)
          const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
      ],
    );
  }
}
