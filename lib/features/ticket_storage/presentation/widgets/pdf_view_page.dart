import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewPage extends StatelessWidget {
  const PdfViewPage({Key? key, this.filePath, this.title}) : super(key: key);
  final String? filePath;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title ?? ''),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
