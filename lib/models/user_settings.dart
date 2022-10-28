import 'package:flutter/material.dart';

class UserSettings {

  String name;
  String photoUrl;
  String about;
  String language;
  String colorNum;
  String shadeNum;
  Color color;

  UserSettings({
    required this.name,
    required this.photoUrl,
    required this.about,
    required this.language,
    required this.colorNum,
    required this.shadeNum,
    required this.color });
}