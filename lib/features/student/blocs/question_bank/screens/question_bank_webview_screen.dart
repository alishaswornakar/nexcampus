import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class DriveWebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final String? fallbackUrl;

  const DriveWebViewScreen({
    super.key,
    required this.title,
    required this.url,
    this.fallbackUrl,
  });

  @override
  State<DriveWebViewScreen> createState() => _DriveWebViewScreenState();
}

class _DriveWebViewScreenState extends State<DriveWebViewScreen> {
  late final WebViewController _controller;

  bool _loading = true;
  bool _usedFallback = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // Ignore errors from sub-resources (images, scripts, etc.);
            // only react when the main page itself fails to load.
            if (error.isForMainFrame == false) return;
            _handleLoadError();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _handleLoadError() {
    if (_usedFallback) return; // already tried the fallback once, stop here
    final fallback = widget.fallbackUrl;
    if (fallback == null || fallback.isEmpty || fallback == widget.url) return;

    _usedFallback = true;
    _controller.loadRequest(Uri.parse(fallback));
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBack();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.secondary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                if (await _controller.canGoBack()) await _controller.goBack();
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  await _controller.goForward();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
