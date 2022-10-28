import 'package:flutter/material.dart';
import 'package:signmi_app/models/user_settings.dart';
import '../models/short_card_collect.dart';
import '../models/short_card_own.dart';

/// TODO Добавить описание

class DataHolder extends InheritedWidget {

  final List<ShortCardOwn> ownCardList;
  final List<ShortCardCollect> collectCardList;
  final UserSettings userSettings;
  final Function refreshOwn;
  final Function refreshCollect;
  final Function refreshSettings;
  final Function switch2Home;
  final Function switch2Collection;
  final Function switch2Feed;
  final Function switch2Manage;
  final Function linkHandler;


  const DataHolder({Key? key,
    required this.ownCardList,
    required this.collectCardList,
    required this.userSettings,
    required this.refreshOwn,
    required this.refreshCollect,
    required this.refreshSettings,
    required this.switch2Home,
    required this.switch2Collection,
    required this.switch2Feed,
    required this.switch2Manage,
    required this.linkHandler,
    required Widget child
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static DataHolder? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DataHolder>();

}
