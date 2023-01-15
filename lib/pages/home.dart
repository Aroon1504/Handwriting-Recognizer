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

    void createFile() async {
      // TimeStamp
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      TextEditingController _titleController =
          TextEditingController(text: "file$timestamp");
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Save changes"),
                content: TextField(
                  onChanged: (value) {},
                  controller: _titleController,
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        appProvider.changeIsLoading();

                        // Getting Directory
                        Directory? dir = await getExternalStorageDirectory();

                        // Creating File
                        File file = File("${dir?.path}/file$timestamp.txt");

                        // Writing Text
                        file.writeAsString("");

                        // Creating new Instance of TextFileModel
                        TextFileModel textFileModel = TextFileModel(
                            name: 'file$timestamp',
                            createdAt: DateTime.now().microsecondsSinceEpoch,
                            path: "${dir?.path}/file$timestamp.txt",
                            content: quill.Delta());

                        // Saving new textFileModel
                        await fileProvider.save(textFileModel);

                        // Reload
                        await fileProvider.reloadTextFiles();

                        appProvider.changeIsLoading();

                        // ignore: use_build_context_synchronously
                        popScreen(context);
                        // ignore: use_build_context_synchronously
                        changeScreen(
                            context,
                            TextEditor(
                              textFileModel: textFileModel,
                              toInsert: "",
                            ));
                      },
                      child: const Text("Yes")),
                  TextButton(
                      onPressed: () {
                        popScreen(context);
                      },
                      child: const Text("No")),
                ],
              ));
    }

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
                  appProvider.changeIsLoading();

                  // Getting Directory
                  Directory? dir = await getExternalStorageDirectory();

                  // TimeStamp
                  var timestamp = DateTime.now().millisecondsSinceEpoch;

                  // Creating File
                  File file = File("${dir?.path}/file$timestamp.txt");

                  // Writing Text
                  file.writeAsString("");

                  // Creating new Instance of TextFileModel
                  TextFileModel textFileModel = TextFileModel(
                      name: 'file$timestamp',
                      createdAt: DateTime.now().microsecondsSinceEpoch,
                      path: "${dir?.path}/file$timestamp.txt",
                      content: quill.Delta());

                  // Saving new textFileModel
                  await fileProvider.save(textFileModel);

                  // Reload
                  await fileProvider.reloadTextFiles();

                  appProvider.changeIsLoading();
                  try {
                    // ignore: use_build_context_synchronously
                    File? scannedDoc = await DocumentScannerFlutter.launch(
                        context,
                        source: ScannerFileSource
                            .CAMERA); // Or ScannerFileSource.GALLERY
                    // `scannedDoc` will be the image file scanned from scanner
                    late File image;
                    if (scannedDoc != null) {
                      image = scannedDoc;
                    }

                    if (image != null) {
                      
                      // ignore: use_build_context_synchronously
                      String navigatorResult = await changeScreenWithResult(
                          context,
                          ScannerPage(
                            image: image,
                          ));

                          if(navigatorResult!=null){
                            createFile();
                          }

                      // // ignore: use_build_context_synchronously
                      // changeScreen(
                      //     context,
                      //     TextEditor(
                      //       textFileModel: textFileModel,
                      //       toInsert: navigatorResult,
                      //     ));
                    }
                  } on PlatformException {
                    print(PlatformException);
                  }
                },
                child: Icon(Icons.camera_alt),
              )), //button first

          Container(
              margin: EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "btn2",
                onPressed: () async => createFile(),
                child: Icon(Icons.add),
              )), // button second
        ],
      ),
    );
  }
}
