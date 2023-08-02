import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:handwriting_recognizer/common/changeScreen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({
    super.key,
    required this.image,
  });

  final File image;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  @override
  void dispose() {
    super.dispose();
  }

  bool uploading = false;

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

  // Stream<List<int>> funcStream() async* {
  //   yield ;
  // }

  Future<String> byteStream() async {
    var uri = Uri.parse('http://192.168.104.104:5000/detecttxt');
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

    var res = await request.send().timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        // Time has run out, do what you wanted to do.
        return http.StreamedResponse(
            http.ByteStream.fromBytes(utf8.encode(jsonEncode('error'))), 503);
      },
    );
    if (res.statusCode == 503) {
      // ignore: use_build_context_synchronously
      throw Exception('Error 503: Unable to process your request');
    }

    String response = jsonDecode(await res.stream.bytesToString());
    if (kDebugMode) {
      print(response);
    }

    return response;

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
              SizedBox(
                height: 10,
              ),
              uploading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          uploading = true;
                        });

                        try {
                          // changeBase64();
                          String result = await byteStream();
                          // final textRecognizer =
                          //     TextRecognizer(script: TextRecognitionScript.latin);
                          // final RecognizedText recognizedText = await textRecognizer
                          //     .processImage(InputImage.fromFile(widget.image));
                          // print(result);

                          // String recognizedText =
                          //     await FlutterTesseractOcr.extractText(
                          //         widget.image.path);
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, result);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                          popScreen(context);
                        }
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
