import 'package:sembast/sembast.dart';
import '../data/app_database.dart';
import '../data/model/text_file.dart';

class FileServices {
  // ignore: constant_identifier_names
  static const String TEXTFILE_STORE_NAME = 'textfile';
  // This Store acts like a persistent map, value of which are textfile objects converted to map.
  final _textFileStore = intMapStoreFactory.store(TEXTFILE_STORE_NAME);

  // Private getter to shorten the amount of needed to get the
  // singleton instance of an opened database.

  Future<Database> get _db async => await AppDatabase.instance.database;

  // inserting new object
  Future insert(TextFileModel textFileModel) async {
    await _textFileStore.add(await _db, textFileModel.toMap());
  }

  // updating object
  Future update(TextFileModel textFileModel) async {
    // For filtering by key (ID), RegEx, greater then, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(textFileModel.id));
    await _textFileStore.update(await _db, textFileModel.toMap(),
        finder: finder);
  }

  // Deleting object
  Future delete(TextFileModel textFileModel) async {
    // For filtering by key (ID), RegEx, greater then, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(textFileModel.id));
    await _textFileStore.delete(await _db, finder: finder);
  }

  Future<List<TextFileModel>> getTextFiles() async {
    final finder = Finder(sortOrders: [
      SortOrder('createdAt', false),
    ]);

    final recordSnapshot = await _textFileStore.find(await _db, finder: finder);

    // Making a List<TextFile> out of List<RecordSnapshot>
    return recordSnapshot.map((snapshot) {
      final textFile = TextFileModel.fromMap(snapshot.value);

      //  An ID is a key of a record from the database.
      textFile.id = snapshot.key;
      return textFile;
    }).toList();
  }

  // Searching file
  Future<List<TextFileModel>> searchTextFiles(
      {required String filename}) async {
    final finder = Finder(filter: Filter.equals('name', filename), sortOrders: [
      SortOrder('createdAt', false),
    ]);

    final recordSnapshot = await _textFileStore.find(await _db, finder: finder);

    // Making a List<TextFile> out of List<RecordSnapshot>
    return recordSnapshot.map((snapshot) {
      final textFile = TextFileModel.fromMap(snapshot.value);

      //  An ID is a key of a record from the database.
      textFile.id = snapshot.key;
      return textFile;
    }).toList();
  }
}
