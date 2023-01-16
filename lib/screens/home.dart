import 'dart:io';

import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/screens/scanner.dart';
import 'package:handwriting_recognizer/screens/text_editor.dart';
import 'package:handwriting_recognizer/widgets/loading.dart';
import 'package:handwriting_recognizer/widgets/pdf_file_list.dart';
import 'package:handwriting_recognizer/widgets/text_file_card.dart';
import 'package:handwriting_recognizer/widgets/text_file_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../common/changeScreen.dart';
import '../provider/appprovider.dart';
import '../provider/fileprovider.dart';
import '../widgets/action_button.dart';
import '../widgets/expand_fab.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<Fileprovider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    void createFile(String navigationResult) async {
      // TimeStamp
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      TextEditingController titleController =
          TextEditingController(text: "file$timestamp");
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Save changes"),
                content: TextField(
                  onChanged: (value) {},
                  controller: titleController,
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        appProvider.changeIsLoading();

                        // Getting Directory
                        Directory? dir = await getExternalStorageDirectory();

                        // Creating File
                        File file =
                            File("${dir?.path}/${titleController.text}.txt");

                        // Writing Text
                        file.writeAsString("");

                        // Creating new Instance of TextFileModel
                        TextFileModel textFileModel = TextFileModel(
                            name: titleController.text,
                            createdAt: DateTime.now().microsecondsSinceEpoch,
                            path: "${dir?.path}/${titleController.text}.txt",
                            content: quill.Delta());

                        // Saving new textFileModel
                        await fileProvider.saveText(textFileModel);

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
                              toInsert: navigationResult,
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

    void createFileFromPhoto(ScannerFileSource scannerFileSource) async {
      try {
        // ignore: use_build_context_synchronously
        File? scannedDoc = await DocumentScannerFlutter.launch(context,
            source: scannerFileSource); // Or ScannerFileSource.GALLERY
        // `scannedDoc` will be the image file scanned from scanner
        File? image;
        if (scannedDoc != null) {
          image = scannedDoc;
        }
        var navigatorResult;

        if (image != null) {
          // ignore: use_build_context_synchronously
          navigatorResult = await changeScreenWithResult(
              context,
              ScannerPage(
                image: image,
              ));

          if (navigatorResult != null) {
            createFile(navigatorResult);
          }
        }
      } on PlatformException {
        print(PlatformException);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Handwriting Recognizer"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.file_copy), text: 'Text'),
            Tab(
              icon: Icon(Icons.picture_as_pdf),
              text: 'Pdf',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TextFileList(),
          PdfFileList(),
        ],
      ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () async =>
                createFileFromPhoto(ScannerFileSource.CAMERA),
            icon: const Icon(Icons.camera_alt),
          ),
          ActionButton(
            onPressed: () async =>
                createFileFromPhoto(ScannerFileSource.GALLERY),
            icon: const Icon(Icons.insert_photo),
          ),
          ActionButton(
            onPressed: () async => createFile(""),
            icon: const Icon(Icons.file_copy),
          ),
        ],
      ),
    );
  }
}
