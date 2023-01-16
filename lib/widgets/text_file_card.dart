import 'dart:io';

import 'package:flutter/material.dart';
import 'package:handwriting_recognizer/common/changeScreen.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:handwriting_recognizer/common/colors.dart';
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/screens/text_editor.dart';
import 'package:handwriting_recognizer/provider/fileprovider.dart';
import 'package:provider/provider.dart';
import '../provider/appprovider.dart';
import '../screens/pdf_viewer.dart';

class FileCard extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final fileModel;

  const FileCard({super.key, required this.fileModel});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<Fileprovider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: fileModel is TextFileModel
            ? () {
                changeScreen(
                    context,
                    TextEditor(
                      textFileModel: fileModel,
                      toInsert: "",
                    ));
              }
            : () {
                changeScreen(
                    context, PdfViewerPage(fileModel: fileModel));
              },
        child: Container(
            height: 50,
            decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: shadow,
                    offset: const Offset(-2, -1),
                    blurRadius: 5,
                  ),
                ]),
            child: Row(children: [
              fileModel is TextFileModel
                  ? const Icon(
                      Icons.file_copy,
                      color: grey,
                    )
                  : const Icon(
                      Icons.picture_as_pdf,
                      color: grey,
                    ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 150,
                child: Text(
                  fileModel.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                              title: Text(
                                  "Do you want to delete ${fileModel.name}"),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      appProvider.changeIsLoading();
                                      fileModel is TextFileModel
                                          ? await fileProvider
                                              .deleteTextFile(fileModel)
                                          : await fileProvider
                                              .deletepdfFile(fileModel);
                                      fileModel is TextFileModel
                                          ? await fileProvider.reloadTextFiles()
                                          : await fileProvider.reloadPdfFiles();
                                      appProvider.changeIsLoading();
                                      // ignore: use_build_context_synchronously
                                      popScreen(context);
                                    },
                                    child: const Text("Yes")),
                                TextButton(
                                    onPressed: () {
                                      popScreen(context);
                                    },
                                    child: const Text("No"))
                              ]));
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: red,
                ),
              )
            ])),
      ),
    );
  }
}
