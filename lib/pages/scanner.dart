import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, required this.image});

  final File image;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  changeBase64() async {
    Uint8List imageBytes = await widget.image.readAsBytes();
    if (kDebugMode) {
      print(imageBytes);
    }
    String base64Image = base64.encode(imageBytes);
    if (kDebugMode) {
      print(base64Image);
    }
  }

  byteStream() async {
    var uri = Uri.parse('http://192.168.1.9:5000/detecttxt');
    var request = http.MultipartRequest("POST", uri);
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.files.add(
      http.MultipartFile(
        'image',
        widget.image.readAsBytes().asStream(),
        widget.image.lengthSync(),
        filename: widget.image.path.split('/').last,
      ),
    );
    request.headers.addAll(headers);

    if (kDebugMode) {
      print("request: $request");
    }
    var res = await request.send();
    if (kDebugMode) {
      print(res);
    }

    // print(widget.image.readAsBytes().asStream());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Text Detect"),
        ),
        body: Center(
          child: Column(
            children: [
              Image.file(widget.image),
              // Image.memory(base64Decode()),
              ElevatedButton.icon(
                onPressed: () {
                  // changeBase64();
                  byteStream();
                },
                icon: const Icon(
                  Icons.arrow_forward,
                  size: 24.0,
                ),
                label: const Text('Detect Text'), // <-- Text
              ),
            ],
          ),
        ));
  }
}