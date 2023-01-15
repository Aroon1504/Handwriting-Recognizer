import 'dart:io';

import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/pages/scanner.dart';
import 'package:handwriting_recognizer/pages/text_editor.dart';
import 'package:handwriting_recognizer/widgets/loading.dart';
import 'package:handwriting_recognizer/widgets/text_file_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../common/changeScreen.dart';
import '../provider/appprovider.dart';
import '../provider/fileprovider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<Fileprovider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Handwriting Recognizer"),
      ),
      body: appProvider.isLoading
          ? const Loading()
          : SafeArea(
              child: ListView(children: <Widget>[
              Column(
                children: fileProvider.textFiles
                    .map((e) => GestureDetector(
                          child: TextFileCard(textFileModel: e),
                        ))
                    .toList(),
              ),
            ])),
      floatingActionButton: Wrap(
        //will break to another line on overflow
        direction: Axis.vertical, //use vertical to show  on vertical axis
        children: <Widget>[
          Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "btn1",
                onPressed: () async {
                  File? image;
                  try {
                    // ignore: use_build_context_synchronously
                    File? scannedDoc = await DocumentScannerFlutter.launch(
                        context,
                        source: ScannerFileSource
                            .CAMERA); // Or ScannerFileSource.CAMERA
                    // `scannedDoc` will be the image file scanned from scanner
                    if (scannedDoc != null) {
                      image = scannedDoc;
                    }
                  } on PlatformException {
                    print(PlatformException);
                  }
                  if (image != null) {
                    appProvider.changeIsLoading();
                    Directory? dir = await getExternalStorageDirectory();
                    if (kDebugMode) {
                      print(dir?.path);
                    }
                    var timestamp = DateTime.now().millisecondsSinceEpoch;
                    File file = File("${dir?.path}/file$timestamp.txt");
                    file.writeAsString("");
                    TextFileModel textFileModel = TextFileModel(
                        name: 'file$timestamp',
                        createdAt: DateTime.now().microsecondsSinceEpoch,
                        path: "${dir?.path}/file$timestamp.txt",
                        content: quill.Delta());
                    await fileProvider.save(textFileModel);
                    await fileProvider.reloadTextFiles();
                    appProvider.changeIsLoading();
                    // ignore: use_build_context_synchronously
                    String navigatorResult = await changeScreenWithResult(
                        context,
                        ScannerPage(
                          image: image,
                        ));

                    // ignore: use_build_context_synchronously
                    changeScreen(
                        context,
                        TextEditor(
                          textFileModel: textFileModel,
                          toInsert: navigatorResult,
                        ));
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context)
                      .showSnackBar(
                          const SnackBar(content: Text('Cancelled')));
                  }
                },
                child: const Icon(Icons.camera_alt),
              )), //button first
          Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "btn5",
                onPressed: () async {
                  File? image;
                  try {
                    // ignore: use_build_context_synchronously
                    File? scannedDoc = await DocumentScannerFlutter.launch(
                        context,
                        source: ScannerFileSource
                            .GALLERY); // Or ScannerFileSource.CAMERA
                    // `scannedDoc` will be the image file scanned from scanner
                    if (scannedDoc != null) {
                      image = scannedDoc;
                    }
                  } on PlatformException {
                    print(PlatformException);
                  }
                  if (image != null) {
                    appProvider.changeIsLoading();
                    Directory? dir = await getExternalStorageDirectory();
                    if (kDebugMode) {
                      print(dir?.path);
                    }
                    var timestamp = DateTime.now().millisecondsSinceEpoch;
                    File file = File("${dir?.path}/file$timestamp.txt");
                    file.writeAsString("");
                    TextFileModel textFileModel = TextFileModel(
                        name: 'file$timestamp',
                        createdAt: DateTime.now().microsecondsSinceEpoch,
                        path: "${dir?.path}/file$timestamp.txt",
                        content: quill.Delta());
                    await fileProvider.save(textFileModel);
                    await fileProvider.reloadTextFiles();
                    appProvider.changeIsLoading();
                    // ignore: use_build_context_synchronously
                    String navigatorResult = await changeScreenWithResult(
                        context,
                        ScannerPage(
                          image: image,
                        ));

                    // ignore: use_build_context_synchronously
                    changeScreen(
                        context,
                        TextEditor(
                          textFileModel: textFileModel,
                          toInsert: navigatorResult,
                        ));
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                          const SnackBar(content: Text('Cancelled')));
                  }
                },
                child: const Icon(Icons.image),
              )),
          Container(
              margin: EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "btn2",
                onPressed: () async {
                  appProvider.changeIsLoading();
                  Directory? dir = await getExternalStorageDirectory();
                  if (kDebugMode) {
                    print(dir?.path);
                  }
                  var timestamp = DateTime.now().millisecondsSinceEpoch;
                  File file = File("${dir?.path}/file$timestamp.txt");
                  file.writeAsString("");
                  TextFileModel textFileModel = TextFileModel(
                      name: 'file$timestamp',
                      createdAt: DateTime.now().microsecondsSinceEpoch,
                      path: "${dir?.path}/file$timestamp.txt",
                      content: quill.Delta());
                  await fileProvider.save(textFileModel);
                  await fileProvider.reloadTextFiles();
                  appProvider.changeIsLoading();
                },
                child: Icon(Icons.add),
              )), // button second

          // Add more buttons here
        ],
      ),

      // FloatingActionButton(
      //   onPressed: () async {
      //

      //     // appProvider.changeIsLoading();
      //     // Directory? dir = await getExternalStorageDirectory();
      //     // File file = File(
      //     //     "${dir!.path}/file${DateTime.now().millisecondsSinceEpoch}.txt");
      //     // file.writeAsString(
      //     //     "This is my demo text that will be saved as s aa s a ss s to : demoTextFile.txt");
      //     // fileProvider.reload();
      //     // appProvider.changeIsLoading();

      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
