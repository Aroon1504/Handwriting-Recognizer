import 'package:flutter/material.dart';
import 'package:handwriting_recognizer/widgets/text_file_card.dart';
import 'package:provider/provider.dart';

import '../provider/appprovider.dart';
import '../provider/fileprovider.dart';
import 'loading.dart';

class PdfFileList extends StatelessWidget {
  const PdfFileList({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<Fileprovider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    return appProvider.isLoading
        ? const Loading()
        : SafeArea(
            child: ListView(children: <Widget>[
            Column(
              children: fileProvider.pdfFiles
                  .map((e) => GestureDetector(
                        child: FileCard(fileModel: e),
                      ))
                  .toList(),
            ),
          ]));
  }
}
