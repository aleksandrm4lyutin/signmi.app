import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signmi_app/models/public_card.dart';
import 'package:signmi_app/models/short_card_collect.dart';

/// Класс хранящий переменные, которые передаются как settings.arguments
/// в generateRoute при навигации между экранами

class RouteArguments {

  String? uid; /// ID Юзера
  String? cid; /// ID карточки, (!) при создании новой переменная должна быть пустой - ''
  String? title; /// Название
  String? link; /// Ссылка
  BuildContext? cont; /// BuildContext
  ShortCardCollect? cardDataCollect; /// Данные для сжатого класса карточки
  PublicCard? cardDataPreview; /// Данные для основного класса карточки
  bool? preview; /// Превью или нет
  bool? own; /// Своя или нет
  Color? color;  /// Цвет
  File? file; ///
  String? language; /// Выбранный язык
  int? number; ///

  RouteArguments({
    this.uid,
    this.cid,
    this.title,
    this.link,
    this.cont,
    this.preview,
    this.own,
    this.color,
    this.file,
    this.language,
    this.number,
    this.cardDataCollect,
    this.cardDataPreview,
  });

}