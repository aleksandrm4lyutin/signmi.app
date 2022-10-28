import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:signmi_app/pages/wrapper.dart';
import 'functions/authservice.dart';
import 'functions/route_generator.dart';



void main() {
  ///Чек на инициализацию
  WidgetsFlutterBinding.ensureInitialized();
  ///Только вертикальная ориентация
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {
    runApp(App());
  });
}

//&&&&&&&&&&&&&&&&&&&&&&&  APP  &&&&&&&&&&&&&&&&&&&&&&&&&&&
class App extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      /// Инициализирует FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        /// Проверка на ошибку
        if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('ERROR AT FIREBASE'),
              ),
            ),
          );//TODO Заменить сообщение о ошибке и добавить кнопку повторить
        }

        /// Как только все ок и есть соединение, возвращет приложение
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }

        /// То, что показывается во время инициализации
        return MaterialApp(
          home: Scaffold(
            body: Container(),//TODO Заменить на логотип приложения
          ),
        );
      },
    );
  }
}
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

//=========================  MYAPP  ======================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    ///Стрим предоставляющий данные User'а из Firebase
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        //Lines for localization TODO
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: _supportedLocales,
        //
        theme: _themeData,
        ///Использется RouteGenerator с аргументами для навигации по экранам

        /// Начальный виджет
        home: const Wrapper(),
        //initialRoute: '/',
        //initialRoute: '/prototype',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}

//========================================================================

///Лист поддерживаемых Locales
const List<Locale> _supportedLocales = [
  Locale('en', ''),
  Locale('ru', ''),
  Locale('de', ''),
  Locale('ja', ''),
  Locale('it', ''),
  Locale('fr', ''),
  Locale('es', ''),
  Locale('ko', ''),
];

///Параметры темы
ThemeData _themeData = ThemeData(
  //primarySwatch: Colors.cyanAccent[200],
  focusColor: Colors.grey,
  highlightColor: Colors.grey,
  errorColor: Colors.deepOrangeAccent[400],
  appBarTheme: AppBarTheme(
    color: Colors.grey[800],
    actionsIconTheme: const IconThemeData(
      color: Colors.white,
    ),
  ),
  //indicatorColor: Colors.deepOrangeAccent[400],
  //toggleableActiveColor: Colors.grey[600],
  hoverColor: Colors.grey,
  splashColor: Colors.grey[900],
  iconTheme: const IconThemeData(
    color: Colors.grey,
  ),
  /*accentIconTheme: IconThemeData(
            color: Colors.grey[600],
          ),*/
  primaryIconTheme: const IconThemeData(
    color: Colors.grey,
  ), textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.grey[600], selectionColor: Colors.grey, selectionHandleColor: Colors.grey,),
);