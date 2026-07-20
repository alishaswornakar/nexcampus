import 'package:flutter/material.dart';

class PdfUploadCard extends StatelessWidget {
  final bool isUploading;
  final String? pdfName;
  final VoidCallback onTap;

  const PdfUploadCard({
    super.key,
    required this.isUploading,
    required this.pdfName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final uploaded = pdfName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Assignment PDF",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isUploading ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: uploaded
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: isUploading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            uploaded
                                ? Icons.check
                                : Icons.picture_as_pdf,
                            color: uploaded
                                ? Colors.green
                                : Colors.red,
                          ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          pdfName ?? "Upload Assignment PDF",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          isUploading
                              ? "Uploading..."
                              : uploaded
                                  ? "PDF uploaded successfully"
                                  : "Tap to choose a PDF",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        
                        ),
                        
                      ],
                    ),
                  ),

                  Icon(
                    uploaded
                        ? Icons.edit
                        : Icons.upload_file,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}