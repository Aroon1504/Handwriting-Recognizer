// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:handwriting_recognizer/common/colors.dart';
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:provider/provider.dart';
import 'package:delta_markdown/delta_markdown.dart';

import '../provider/appprovider.dart';
import '../provider/fileprovider.dart';

class TextEditor extends StatefulWidget {
  final TextFileModel textFileModel;
  const TextEditor({super.key, required this.textFileModel});

  @override
  // ignore: no_logic_in_create_state
  State<TextEditor> createState() => _TextEditorState(textFileModel);
}

class _TextEditorState extends State<TextEditor> {
  _TextEditorState(TextFileModel textFileModel) {
    if (textFileModel.content.isEmpty) {
      quillDoc = quill.Document()..insert(0, "");
      print("Delta Empty");
    } else {
      quillDoc = quill.Document.fromDelta(textFileModel.content);
      print(textFileModel.content);
    }
    titleController = TextEditingController(text: textFileModel.name);
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
    var convertedValue = jsonEncode(quillDoc.toDelta().toJson());
    var markdown = deltaToMarkdown(convertedValue.toString());
    print('Debug$convertedValue');
    final appProvider = Provider.of<AppProvider>(context);
    final fileProvider = Provider.of<Fileprovider>(context);

    return Scaffold(
        appBar: AppBar(
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
                decoration:
                    BoxDecoration(border: Border.all(color: grey, width: .2))),
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
        ));
  }
}
