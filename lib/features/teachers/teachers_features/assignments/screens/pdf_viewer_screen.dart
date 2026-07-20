import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print(pdfUrl);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewer.network(
        pdfUrl,

        onDocumentLoaded: (details) {
          debugPrint("PDF Loaded Successfully");
        },

        onDocumentLoadFailed: (details) {
          debugPrint(details.error);
          debugPrint(details.description);
        },
      ),
    );
  }
}