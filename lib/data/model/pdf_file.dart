import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart';

class PdfFileModel {
  late int id;

  String name;
  final String path;
  final int createdAt;
  late Delta content;

  PdfFileModel({
    required this.name,
    required this.path,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'createdAt': createdAt,
    };
  }

  static PdfFileModel fromMap(Map<String, dynamic> map) {
    return PdfFileModel(
      name: map['name'],
      path: map['path'],
      createdAt: map['createdAt'],
    );
  }

  copyWith({required id}) {
    this.id = id;
  }
}
