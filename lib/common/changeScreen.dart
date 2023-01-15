import 'package:flutter/material.dart';

void changeScreen(BuildContext context, Widget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

dynamic changeScreenWithResult(BuildContext context, Widget widget) async {
  final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => widget));
  return result;
}

void popScreen(BuildContext context) {
  Navigator.pop(context);
}
