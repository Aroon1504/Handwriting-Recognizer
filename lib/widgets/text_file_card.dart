import 'package:flutter/material.dart';
import 'package:handwriting_recognizer/common/changeScreen.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:handwriting_recognizer/common/colors.dart';
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/pages/text_editor.dart';
import 'package:handwriting_recognizer/provider/fileprovider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../provider/appprovider.dart';

class TextFileCard extends StatelessWidget {
  final TextFileModel textFileModel;

  const TextFileCard({super.key, required this.textFileModel});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<Fileprovider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: () {
          changeScreen(
              context,
              TextEditor(
                textFileModel: textFileModel,
                toInsert: "",
              ));
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
              const Icon(
                Icons.file_copy,
                color: grey,
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 150,
                child: Text(
                  textFileModel.name,
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
                                  "Do you want to delete ${textFileModel.name}"),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      appProvider.changeIsLoading();
                                      await fileProvider.delete(textFileModel);
                                      await fileProvider.reloadTextFiles();
                                      appProvider.changeIsLoading();
                                      // ignore: use_build_context_synchronously
                                      popScreen(context);
                                    },
                                    child: Text("Yes")),
                                TextButton(
                                    onPressed: () {
                                      popScreen(context);
                                    },
                                    child: Text("No"))
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
