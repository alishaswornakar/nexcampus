import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart%20';
import 'package:webview_flutter/webview_flutter.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final WebViewController _controller;

  double _progress = 0;

  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageFinished: (_) async {
            _updateButtons();
          },
        ),
      )
      ..loadRequest(Uri.parse("https://exam.pu.edu.np/"));
  }

  Future<void> _updateButtons() async {
    _canGoBack = await _controller.canGoBack();
    _canGoForward = await _controller.canGoForward();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (await _controller.canGoBack()) {
          await _controller.goBack();
          _updateButtons();
        } else {
          if (!context.mounted) return;
          (mounted) {
            Navigator.of(context).pop();
          };
        }
      },

      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.secondary,
          title: const Text("Results", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(
                context,
              ).pop(); //navigates back to the previous screen when the back button is pressed
              // Handle back button press
            },
          ),
          actions: [
            IconButton(
              tooltip: "Backward",
              icon: const Icon(Icons.arrow_back),
              onPressed: _canGoBack
                  ? () async {
                      await _controller.canGoBack();
                      _updateButtons();
                    }
                  : null,
            ),
            IconButton(
              tooltip: "Forward",
              icon: const Icon(Icons.arrow_forward),
              onPressed: _canGoForward
                  ? () async {
                      await _controller.goForward();
                      _updateButtons();
                    }
                  : null,
            ),
            IconButton(
              tooltip: "Reload",
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _controller.reload();
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: _progress < 1
                ? LinearProgressIndicator(value: _progress)
                : const SizedBox(height: 3),
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
