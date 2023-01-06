import 'package:flutter/material.dart';

class TextViewer extends StatefulWidget {
  const TextViewer({super.key});

  @override
  State<TextViewer> createState() => _TextViewerState();
}

// ignore: camel_case_types
class _TextViewerState extends State<TextViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextViewer'),
      ),
      body: const Text("textView"),
    );
  }
}
