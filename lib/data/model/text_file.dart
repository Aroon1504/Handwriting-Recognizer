import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart';

class TextFileModel {
  late int id;

  String name;
  final String path;
  final int createdAt;
  late Delta content;

  TextFileModel(
      {required this.name,
      required this.path,
      required this.createdAt,
      required this.content});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'createdAt': createdAt,
      'content': jsonEncode(content.toJson())
    };
  }

  static TextFileModel fromMap(Map<String, dynamic> map) {
    final contentJson =
        (map['content'] == null) ? [] : jsonDecode(map['content']);
    return TextFileModel(
        name: map['name'],
        path: map['path'],
        createdAt: map['createdAt'],
        content: Delta.fromJson(contentJson));
  }

  copyWith({required id}) {
    this.id = id;
  }
}
