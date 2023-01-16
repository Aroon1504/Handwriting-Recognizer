import 'dart:async';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:handwriting_recognizer/common/colors.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    Timer(const Duration(seconds: 3), () => print("Splash Done"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(color: white),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: white,
                  radius: 50.0,
                  child: Image.asset("assets/images/hwrlogo.png"),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                const Text(
                  "Handwriting Recognizer",
                  style: TextStyle(
                      color: orange,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                )
              ],
            )),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: orange,
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Text(
                    "Digitalize Handwriting",
                    style: TextStyle(
                        color: orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  )
                ],
              ),
            )
          ],
        )
      ],
    ));
  }
}
