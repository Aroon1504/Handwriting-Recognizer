import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/data/pdf_database.dart';
import 'package:handwriting_recognizer/services/file_service.dart';
import 'package:handwriting_recognizer/services/pdf_service.dart';
import 'package:path_provider/path_provider.dart';

import '../data/model/pdf_file.dart';

enum Status { Loading, Loaded }

class Fileprovider with ChangeNotifier {
  // // ignore: prefer_typing_uninitialized_variables
  // var files;
  // Status _status = Status.Loading;
  // Status get status => _status;

  // intialization() {
  //   _getFiles();
  //   Timer(const Duration(seconds: 3), () {
  //     _status = Status.Loaded;
  //     notifyListeners();
  //   });
  // }

  // _getFiles() async {
  //   Directory? dir = await getExternalStorageDirectory();
  //   debugPrint(dir?.path);
  //   // files = Directory("$dir").listSync();
  //   var fm = FileManager(root: dir);
  //   files = await fm.filesTree();
  // }

  // Fileprovider.initialize() {
  //   intialization();
  // }

  // void reload() {
  //   _getFiles();
  // }

  // Future<void> removeFile({required file}) async {
  //   file.delete();
  // }

  Status _status = Status.Loading;
  Status get status => _status;

  final FileServices _fileServices = FileServices();
  final PdfServices _pdfServices = PdfServices();
  List<TextFileModel> textFiles = [];
  List<TextFileModel> textFilesSearched = [];
  List<PdfFileModel> pdfFiles = [];
  List<PdfFileModel> pdfFilesSearched = [];

  Fileprovider.initialize() {
    loadTextFiles();
    loadPdfFiles();
    _status = Status.Loaded;
    notifyListeners();
  }

  reloadTextFiles() {
    loadTextFiles();
    print("Reload");
  }

  reloadPdfFiles() {
    loadPdfFiles();
    print("Reload");
  }

  loadPdfFiles() async {
    pdfFiles = await _pdfServices.getPdfFiles();
    notifyListeners();
  }

  loadTextFiles() async {
    textFiles = await _fileServices.getTextFiles();
    notifyListeners();
  }

  Future search({required String fileName}) async {
    textFilesSearched = await _fileServices.searchTextFiles(filename: fileName);
    pdfFilesSearched = await _pdfServices.searchPdfFiles(filename: fileName);
    notifyListeners();
  }

  // Future<bool> updateTitle(TextFileModel textFileModel, String title) async {
  //   try {
  //     textFileModel.name = title;
  //     _fileServices.update(textFileModel);
  //     reloadTextFiles();
  //     return true;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("The Error ${e.toString()}");
  //     }
  //     return false;
  //   }
  // }

  Future<bool> updatePage({required TextFileModel textFileModel}) async {
    try {
      print(textFileModel.content);
      await _fileServices.update(textFileModel);
      reloadTextFiles();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("The Error ${e.toString()}");
      }
      return false;
    }
  }

  Future<bool> saveText(TextFileModel textFileModel) async {
    try {
      await _fileServices.insert(textFileModel);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("The Error ${e.toString()}");
      }
      return false;
    }
  }

  Future<bool> savePdf(PdfFileModel pdfFileModel) async {
    try {
      await _pdfServices.insert(pdfFileModel);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("The Error ${e.toString()}");
      }
      return false;
    }
  }

  Future<bool> deleteTextFile(TextFileModel textFileModel) async {
    try {
      await _fileServices.delete(textFileModel);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("The Error ${e.toString()}");
      }
      return false;
    }
  }

  Future<bool> deletepdfFile(PdfFileModel pdfFileModel) async {
    try {
      await _pdfServices.delete(pdfFileModel);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("The Error ${e.toString()}");
      }
      return false;
    }
  }
}
