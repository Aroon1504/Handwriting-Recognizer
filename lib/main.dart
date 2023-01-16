import 'package:flutter/material.dart';
import 'package:handwriting_recognizer/data/model/text_file.dart';
import 'package:handwriting_recognizer/screens/home.dart';
import 'package:handwriting_recognizer/screens/splash.dart';
import 'package:handwriting_recognizer/screens/text_editor.dart';
import 'package:handwriting_recognizer/provider/appprovider.dart';
import 'package:handwriting_recognizer/provider/fileprovider.dart';
import 'package:provider/provider.dart';

Future main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Fileprovider.initialize()),
          ChangeNotifierProvider.value(value: AppProvider())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.orange,
          ),
          home: const ScreenController(),
        ));
  }
}

class ScreenController extends StatelessWidget {
  const ScreenController({super.key});

  @override
  Widget build(BuildContext context) {
    final file = Provider.of<Fileprovider>(context);
    switch (file.status) {
      case Status.Loading:
        return const Splash();
      case Status.Loaded:
        return const MyHomePage();
      default:
        return const MyHomePage();
    }
  }
}