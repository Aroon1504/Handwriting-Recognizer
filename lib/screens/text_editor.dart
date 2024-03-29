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
import 'package:handwriting_recognizer/data/model/pdf_file.dart';
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/screens/pdf_viewer.dart';
import 'package:handwriting_recognizer/screens/scanner.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:quill_markdown/quill_markdown.dart';

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
  late TextEditingController dialogBoxController;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  createPdf(Fileprovider fileProvider, AppProvider appProvider) async {
    try {
      var content = quillToMarkdown(jsonEncode(quillDoc.toDelta()));
      // print(content);
      var html = md.markdownToHtml(content!);
      Directory? dir = await getExternalStorageDirectory();
      var pdfFile = dialogBoxController.text;
      var pdf = await FlutterHtmlToPdf.convertFromHtmlContent(
          html, dir!.path, pdfFile);
      PdfFileModel pdfFileModel = PdfFileModel(
          name: pdfFile,
          path: pdf.path,
          createdAt: DateTime.now().microsecondsSinceEpoch);
      appProvider.changeIsLoading();
      await fileProvider.savePdf(pdfFileModel);
      await fileProvider.reloadPdfFiles();
      appProvider.changeIsLoading();
      // ignore: use_build_context_synchronously
      changeScreen(context, PdfViewerPage(fileModel: pdfFileModel));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
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

    void showTextDialogBox() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: orange))),
                  // onChanged: (value) async {
                  //   print(value);
                  //   appProvider.changeIsLoading();
                  //   await updateTitle(fileProvider, value);
                  //   appProvider.changeIsLoading();
                  // },
                  // onSubmitted: (value) => updateTitle(fileProvider, value),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        popScreen(context);
                      },
                      hoverColor: red,
                      icon: const Icon(
                        Icons.close,
                      )),
                  IconButton(
                      onPressed: () async {
                        appProvider.changeIsLoading();
                        await updateTitle(fileProvider, titleController.text);
                        appProvider.changeIsLoading();
                        // ignore: use_build_context_synchronously
                        popScreen(context);
                      },
                      hoverColor: greenAccent,
                      icon: const Icon(
                        Icons.done,
                      ))
                ],
              ));
    }

    void showPdfDialogBox() {
      dialogBoxController = TextEditingController(text: titleController.text);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: TextField(
                  controller: dialogBoxController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: orange))),
                  // onChanged: (value) async {
                  //   print(value);
                  //   appProvider.changeIsLoading();
                  //   await updateTitle(fileProvider, value);
                  //   appProvider.changeIsLoading();
                  // },
                  // onSubmitted: (value) => updateTitle(fileProvider, value),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        popScreen(context);
                      },
                      hoverColor: red,
                      icon: const Icon(
                        Icons.close,
                      )),
                  IconButton(
                      onPressed: () async {
                        createPdf(fileProvider, appProvider);
                        // ignore: use_build_context_synchronously
                        popScreen(context);
                      },
                      hoverColor: greenAccent,
                      icon: const Icon(
                        Icons.done,
                      ))
                ],
              ));
    }

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
                        // ignore: use_build_context_synchronously
                        popScreen(context);
                        // ignore: use_build_context_synchronously
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
                    onPressed: () async {
                      showPdfDialogBox();
                    },
                    icon: const Icon(
                      Icons.share,
                      size: 16,
                    ),
                    label: const Text('Share'),
                  ),
                )
              ],
              title: SizedBox(
                height: 35,
                child: TextButton(
                    onPressed: () {
                      showTextDialogBox();
                    },
                    child: Text(
                      titleController.text,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: black),
                    )),
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
                            String navigatorResult =
                                // ignore: use_build_context_synchronously
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

                            String navigatorResult =
                                // ignore: use_build_context_synchronously
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
