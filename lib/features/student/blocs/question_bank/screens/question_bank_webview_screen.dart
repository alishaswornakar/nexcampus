import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QuestionBankWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const QuestionBankWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<QuestionBankWebViewScreen> createState() =>
      _QuestionBankWebViewScreenState();
}

class _QuestionBankWebViewScreenState extends State<QuestionBankWebViewScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // Future<bool> _onWillPop() async {
  //   if (await _controller.canGoBack()) {
  //     await _controller.goBack();
  //     return false;
  //   }

  //   return true;
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),

          actions: [
            IconButton(
              tooltip: "Back",
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  await _controller.goBack();
                }
              },
            ),
            IconButton(
              tooltip: "Forward",
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  await _controller.goForward();
                }
              },
            ),
            IconButton(
              tooltip: "Reload",
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _controller.reload();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),

            if (_isLoading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
