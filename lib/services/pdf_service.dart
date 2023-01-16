import 'dart:io';

import 'package:sembast/sembast.dart';
import '../data/app_database.dart';
import '../data/model/pdf_file.dart';

class PdfServices {
  // ignore: constant_identifier_names
  static const String PDFFILE_STORE_NAME = 'pdffile';
  // This Store acts like a persistent map, value of which are textfile objects converted to map.
  final _pdfFileStore = intMapStoreFactory.store(PDFFILE_STORE_NAME);

  // Private getter to shorten the amount of needed to get the
  // singleton instance of an opened database.

  Future<Database> get _db async => await AppDatabase.instance.database;

  // inserting new object
  Future insert(PdfFileModel pdfFileModel) async {
    await _pdfFileStore.add(await _db, pdfFileModel.toMap());
  }

  // updating object
  Future update(PdfFileModel pdfFileModel) async {
    // For filtering by key (ID), RegEx, greater then, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(pdfFileModel.id));
    await _pdfFileStore.update(await _db, pdfFileModel.toMap(), finder: finder);
  }

  // Deleting object
  Future delete(PdfFileModel pdfFileModel) async {
    File file = File(pdfFileModel.path);
    await file.delete();
    // For filtering by key (ID), RegEx, greater then, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(pdfFileModel.id));
    await _pdfFileStore.delete(await _db, finder: finder);
  }

  Future<List<PdfFileModel>> getPdfFiles() async {
    final finder = Finder(sortOrders: [
      SortOrder('createdAt', false),
    ]);

    final recordSnapshot = await _pdfFileStore.find(await _db, finder: finder);

    // Making a List<TextFile> out of List<RecordSnapshot>
    return recordSnapshot.map((snapshot) {
      final pdfFile = PdfFileModel.fromMap(snapshot.value);

      //  An ID is a key of a record from the database.
      pdfFile.id = snapshot.key;
      return pdfFile;
    }).toList();
  }

  // Searching file
  Future<List<PdfFileModel>> searchPdfFiles({required String filename}) async {
    final finder = Finder(filter: Filter.equals('name', filename), sortOrders: [
      SortOrder('createdAt', false),
    ]);

    final recordSnapshot = await _pdfFileStore.find(await _db, finder: finder);

    // Making a List<TextFile> out of List<RecordSnapshot>
    return recordSnapshot.map((snapshot) {
      final pdfFile = PdfFileModel.fromMap(snapshot.value);

      //  An ID is a key of a record from the database.
      pdfFile.id = snapshot.key;
      return pdfFile;
    }).toList();
  }
}
