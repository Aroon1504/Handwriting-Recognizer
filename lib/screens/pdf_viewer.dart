import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final fileModel;
  const PdfViewerPage({super.key, this.fileModel});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.fileModel.name)),
        body: SfPdfViewer.file(File(widget.fileModel.path))
        // PDFView(
        //   filePath: widget.fileModel.path,
        // ),
        );
  }
}
