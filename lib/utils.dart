import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getProjectDirectory() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  return path;
}