// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:handwriting_recognizer/common/colors.dart';
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/pages/scanner.dart';
import 'package:provider/provider.dart';

import '../common/changeScreen.dart';
import '../provider/appprovider.dart';
import '../provider/fileprovider.dart';

class TextEditor extends StatefulWidget {
  final TextFileModel textFileModel;
  final String toInsert;
  const TextEditor(
      {super.key, required this.textFileModel, required this.toInsert});

  @override
  // ignore: no_logic_in_create_state
  State<TextEditor> createState() => _TextEditorState(textFileModel, toInsert);
}

class _TextEditorState extends State<TextEditor> {
  Timer? _debounce;
  _TextEditorState(TextFileModel textFileModel, toInsert) {
    // Content of the document
    if (textFileModel.content.isEmpty) {
      quillDoc = quill.Document()..insert(0, toInsert);
      print("Delta Empty");
    } else {
      quillDoc = quill.Document.fromDelta(textFileModel.content);
      print(textFileModel.content);
    }

    // Title Controller
    titleController = TextEditingController(text: textFileModel.name);

    // quill Controller
    _controller = quill.QuillController(
      document: quillDoc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }
  late quill.Document quillDoc;
  late TextEditingController titleController;
  late quill.QuillController _controller;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  Future<void> updateContent(Fileprovider fileProvider) async {
    widget.textFileModel.content = quillDoc.toDelta();
    await fileProvider.updatePage(textFileModel: widget.textFileModel);
  }

  Future<void> updateTitle(Fileprovider fileProvider, String title) async {
    widget.textFileModel.name = title;
    await fileProvider.updatePage(textFileModel: widget.textFileModel);
  }

  @override
  Widget build(BuildContext context) {
    // var convertedValue = jsonEncode(quillDoc.toDelta().toJson());
    final appProvider = Provider.of<AppProvider>(context);
    final fileProvider = Provider.of<Fileprovider>(context);
    showDialogBox() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Save changes"),
                content:
                    Text("Want to save changes to ${titleController.text}"),
                actions: [
                  TextButton(
                      onPressed: () async {
                        await updateContent(fileProvider);
                        popScreen(context);
                        popScreen(context);
                      },
                      child: const Text("Yes")),
                  TextButton(
                      onPressed: () {
                        popScreen(context);
                        popScreen(context);
                      },
                      child: const Text("No")),
                ],
              ));
    }

    return WillPopScope(
        onWillPop: () async {
          // Save Changes Alert Dialog Box
          showDialogBox();
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  // Save Changes Alert Dialog Box
                  showDialogBox();
                },
                icon: const Icon(Icons.arrow_back),
                //replace with our own icon data.
              ),
              backgroundColor: white,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      updateContent(fileProvider);
                    },
                    icon: const Icon(
                      Icons.lock,
                      size: 16,
                    ),
                    label: const Text('Share'),
                  ),
                )
              ],
              title: SizedBox(
                height: 30,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: orange))),
                  onChanged: (value) async {
                    print(value);
                    appProvider.changeIsLoading();
                    await updateTitle(fileProvider, value);
                    appProvider.changeIsLoading();
                  },
                  onSubmitted: (value) => updateTitle(fileProvider, value),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: grey, width: .2))),
              ),
            ),
            body: Column(
              children: [
                quill.QuillToolbar.basic(controller: _controller),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: _controller,
                      readOnly: false, // true for view only mode
                    ),
                  ),
                )
              ],
            ),
            floatingActionButton: Wrap(
                //will break to another line on overflow
                direction:
                    Axis.vertical, //use vertical to show  on vertical axis
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.all(10),
                      child: FloatingActionButton(
                        heroTag: "btn3",
                        onPressed: () async {
                          try {
                            File? scannedDoc =
                                await DocumentScannerFlutter.launch(context,
                                    source: ScannerFileSource
                                        .CAMERA); // Or ScannerFileSource.GALLERY
                            // `scannedDoc` will be the image file scanned from scanner
                            late File image;
                            if (scannedDoc != null) {
                              image = scannedDoc;
                            }

                            var index = _controller.selection.baseOffset;
                            // ignore: use_build_context_synchronously
                            String navigatorResult =
                                await changeScreenWithResult(
                                    context,
                                    ScannerPage(
                                      image: image,
                                    ));
                            quillDoc.insert(index, navigatorResult);
                          } on PlatformException {
                            print(PlatformException);
                          }
                        },
                        child: const Icon(Icons.camera_alt),
                      )),
                  Container(
                      margin: const EdgeInsets.all(10),
                      child: FloatingActionButton(
                        heroTag: "btn4",
                        onPressed: () async {
                          try {
                            File? scannedDoc =
                                await DocumentScannerFlutter.launch(context,
                                    source: ScannerFileSource
                                        .GALLERY); // Or ScannerFileSource.GALLERY
                            // `scannedDoc` will be the image file scanned from scanner
                            late File image;
                            if (scannedDoc != null) {
                              image = scannedDoc;
                            }

                            var index = _controller.selection.baseOffset;
                            // ignore: use_build_context_synchronously
                            String navigatorResult =
                                await changeScreenWithResult(
                                    context,
                                    ScannerPage(
                                      image: image,
                                    ));
                            quillDoc.insert(index, navigatorResult);
                          } on PlatformException {
                            print(PlatformException);
                          }
                        },
                        child: const Icon(Icons.image),
                      ))
                ])));
  }
}
