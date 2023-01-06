import 'package:flutter/material.dart';
import 'package:handwriting_recognizer/common/changeScreen.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:handwriting_recognizer/common/colors.dart';
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/pages/text_editor.dart';

class TextFileCard extends StatelessWidget {
  final TextFileModel textFileModel;

  const TextFileCard({super.key, required this.textFileModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: () {
          changeScreen(context, TextEditor(textFileModel: textFileModel));
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
              Text(textFileModel.name),
              const SizedBox(
                width: 10,
              )
            ])),
      ),
    );
  }
}
