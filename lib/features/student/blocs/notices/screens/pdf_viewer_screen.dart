import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';

/// In-app PDF viewer for notice attachments.
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isRendered && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(isSmallScreen, isTablet),
    );
  }

  Widget _buildBody(bool isSmallScreen, bool isTablet) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isSmallScreen ? 48 : 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _downloadAndLoad,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_localPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3.0,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ],
        ),
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
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              color: AppTheme.primary,
            ),
          ),
      ],
    );
  }
}
