import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/widgets/loading.dart';
import 'package:handwriting_recognizer/widgets/text_file_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
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
      floatingActionButton: FloatingActionButton(
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

          // appProvider.changeIsLoading();
          // Directory? dir = await getExternalStorageDirectory();
          // File file = File(
          //     "${dir!.path}/file${DateTime.now().millisecondsSinceEpoch}.txt");
          // file.writeAsString(
          //     "This is my demo text that will be saved as s aa s a ss s to : demoTextFile.txt");
          // fileProvider.reload();
          // appProvider.changeIsLoading();

          // try {
          //   File? scannedDoc = await DocumentScannerFlutter.launch(context,
          //       source:
          //           ScannerFileSource.CAMERA); // Or ScannerFileSource.GALLERY
          //   // `scannedDoc` will be the image file scanned from scanner
          //   File image = scannedDoc!;
          //   // ignore: use_build_context_synchronously
          //   changeScreen(context, ScannerPage(image: image));
          // } on PlatformException {
          //   print(PlatformException);
          // }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
