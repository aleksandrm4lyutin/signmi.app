import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../functions/data_services/get_collect_cards.dart';
import '../functions/data_services/get_user_cards.dart';
import '../functions/data_services/get_user_settings.dart';
import '../models/short_card_collect.dart';
import '../models/short_card_own.dart';
import '../models/user_settings.dart';
import 'data_holder.dart';
import 'home_page.dart';
import 'loading_page.dart';


/// Виджет отвечает за загрузку всех данных, а так же хранит связанные с этим функции,
/// на время загрузки показывается Loading виджет, при ошибке предлагает повторить
/// попытку, после умпешной загрузки передает данные в HomePage через "прослойку"
/// DataHolder, призвынную предоставить возможность виджетам дальше обращаться к функциям
/// загрузки и избирательно обновлять данные.
///

class DataLoader extends StatefulWidget {

  final String uid;

  const DataLoader({Key? key, required this.uid}) : super(key: key);

  @override
  _DataLoaderState createState() => _DataLoaderState();
}

class _DataLoaderState extends State<DataLoader> {

  late Future<List<ShortCardOwn>?> _ownCardsList;
  late Future<List<ShortCardCollect>?> _collectCardsList;
  late Future<UserSettings?> _settings;

  late List<ShortCardOwn> _ownCardsListData;
  late List<ShortCardCollect> _collectCardsListData;
  late UserSettings _settingsData;

  //int _switchPage = DataService();
  /// Для хранения информации о выбранной странице в BottomNavigationBar на HomePage
  int _selectedPage = 0;
  /// Флаг о том, нужно ли ждать выполнение загружки/обновления данных или испольщовать имеющися
  bool _hasData = false;
  /// Флаг о том, было ли открыто приложение при помощи динамической ссылки
  bool _withLink = false;

  Color highlightColor = Colors.deepOrangeAccent;

  /// костыль для использования snapshot.data TODO?
  dynamic _snapshotData;

  @override
  void initState() {
    super.initState();

    _ownCardsList = loadOwnCards(widget.uid);
    _collectCardsList = loadCollectCards(widget.uid);
    _settings = loadUserSettings(widget.uid, context);
  }


  @override
  Widget build(BuildContext context) {

    /// ID Юзера
    final _uid = Provider.of<User>(context).uid;

    return FutureBuilder(
      future: Future.wait([_ownCardsList, _collectCardsList, _settings]),
      builder: (context, snapshot) {
        /// Если просто переключает между экранами и т.п., то сразу идет дальше
        /// с имеющимися данными
        if(_hasData == true) {
          return DataHolder(
            refreshOwn: () {
              _updateOwn();
            },
            refreshCollect: () {
              _updateCollect();
            },
            refreshSettings: () {
              _updateSettings(context);
            },
            switch2Home: () {
              _switchPage(0);
            },
            switch2Collection: () {
              _switchPage(1);
            },
            switch2Feed: () {
              _switchPage(2);
            },
            switch2Manage: () {
              _switchPage(3);
            },
            linkHandler: () {
              _linkHandler();
            },
            ownCardList: _ownCardsListData,
            collectCardList: _collectCardsListData,
            userSettings: _settingsData,
            //child: HomePage1(),
            child: HomePage(
              currentPage: _selectedPage,
              withLink: _withLink,
              userUID: _uid,
            ),
          );
        } else {
          /// Если требуется обновление данных, то ждем snapshot.data
          if (snapshot.connectionState == ConnectionState.done) {
            _snapshotData = snapshot.data;

            if(_snapshotData[0] != null && _snapshotData[1] != null) {
              _ownCardsListData = _snapshotData[0];
              _collectCardsListData = _snapshotData[1];
              _settingsData = _snapshotData[2];
              highlightColor = _snapshotData[2].color;

              _hasData = true;
              return DataHolder(
                refreshOwn: () {
                  _updateOwn();
                },
                refreshCollect: () {
                  _updateCollect();
                },
                refreshSettings: () {
                  _updateSettings(context);
                },
                switch2Home: () {
                  _switchPage(0);
                },
                switch2Collection: () {
                  _switchPage(1);
                },
                switch2Feed: () {
                  _switchPage(2);
                },
                switch2Manage: () {
                  _switchPage(3);
                },
                linkHandler: () {
                  _linkHandler();
                },
                ownCardList: _snapshotData[0] ?? [],
                collectCardList: _snapshotData[1] ?? [],
                userSettings: _snapshotData[2],
                child: HomePage(
                  currentPage: _selectedPage,
                  withLink: _withLink,
                  userUID: _uid,
                ),
              );
            } else {
              /// В случае ошибки предлагает попробовать загрузить снова
              return Scaffold(
                backgroundColor: Colors.grey[900],
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.report_problem, color: Colors.deepOrangeAccent[400], size: 50,),
                        const SizedBox(height: 10,),
                        Wrap(
                          children: <Widget>[
                            Text('Could not load the data',
                              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Wrap(
                          children: <Widget>[
                            Text('Please check internet connection or try again later',
                              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            TextButton(
                              child: Row(
                                children: const <Widget>[
                                  Icon(Icons.arrow_back, color: Colors.white, size: 25,),
                                  Text('Exit', style: TextStyle(fontSize: 25, color: Colors.white)),//'Exit'
                                ],
                              ),
                              onPressed: () {
                                SystemChannels.platform.invokeMethod('SystemNavigator.pop');//EXIt THE aPP
                              },
                            ),
                            TextButton(
                              child: Row(
                                children: const <Widget> [
                                  Text('Retry', style: TextStyle(fontSize: 25, color: Colors.white)),//'Retry'
                                  Icon(Icons.refresh, color: Colors.white, size: 25,),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  _ownCardsList = loadOwnCards(widget.uid);
                                  _collectCardsList = loadCollectCards(widget.uid);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            /// Экран загрузки
            return Loading(color: highlightColor);
          }
        }
      },
    );
  }

  /// Функция для обновления данных о собственных карточках
  void _updateOwn() {
    setState(() {
      _hasData = false;
    });
    setState(() {
      _ownCardsList = loadOwnCards(widget.uid);
    });
  }

  /// Функция для обновления данных коллекции чужих карточек
  void _updateCollect() {
    setState(() {
      _hasData = false;
    });
    setState(() {
      _collectCardsList = loadCollectCards(widget.uid);
    });
  }

  /// Функция для обновления данных пользователя и настроек приложения
  void _updateSettings(BuildContext cont) {
    setState(() {
      _hasData = false;
    });
    setState(() {
      _settings = loadUserSettings(widget.uid, cont);
    });
  }

  /// Функция для переключения страниц HomePage
  void _switchPage(int _page) {
    setState(() {
      _selectedPage = _page;
    });
  }

  /// Функция сообщающая о том, что приложение было открыто или обновлено
  /// при помощи динамической ссылки
  void _linkHandler() {
    setState(() {
      _withLink = true;
    });
  }
}



//TODO: CHANGE THIS TO SOMETHING LIKE IN EDITOR LOADER WITH THROW ERROR

/// Загрузить собственные карточки
Future<List<ShortCardOwn>?> loadOwnCards(String uid) async {
  return await getUserCards(uid);
}

/// Загрузить коллекцию карточек
Future<List<ShortCardCollect>?> loadCollectCards(String uid) async {
  return await getCollectCards(uid);
}

/// Загрузить настройки приложения
Future<UserSettings?> loadUserSettings(String uid, BuildContext cont) async {
  return await getUserSettings(uid, cont);
}