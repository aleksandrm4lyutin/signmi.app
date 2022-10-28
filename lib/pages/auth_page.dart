import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../functions/authservice.dart';
import '../functions/validators.dart';
import '../shared/constants.dart';
import '../texts/text_auth_page.dart';



class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

/// Enums для списка выбора языка
enum languages { english, russian, german, japanese, italian, french, spanish, korean }//TODO ADD Other languages



class _AuthPageState extends State<AuthPage> {

  Validators validators = Validators();

  //final ThemeData myTheme = ThemeData();

  /// Переменная для разового авто выбора языка
  bool _runOnce = true;

  /// Инстанс класса AuthService
  final AuthService _auth = AuthService();

  /// Скрыть или показать содержимое поля пароля
  bool hidePass = true;

  /// Переключает между экранами Войти и Зарегистрироваться, true если Войти
  bool showSignInPage = true;

  /// Переключает на экран загрузки на время загрузки или выполнения облачной функции
  bool isLoading = false;

  /// Переменная для имени при регистрации
  String nameReg = '';

  /// Переменная для почты при регистрации
  String emailReg ='';

  /// Переменная для пароля при регистрации
  String passwordReg = '';

  /// Переменная для повтора пароля при регистрации
  String passwordRepReg = '';

  /// Переменная для почты при входе
  String emailSign ='';

  /// Переменная для пароля при входе
  String passwordSign = '';
  /// Переменная для почты при сбросе почты
  String emailReset ='';
  /// Переменная для имени при сбросе почты
  String nameReset = '';

  Color color0 = Colors.grey[900]!;
  Color color1 = Colors.deepOrangeAccent[400]!;
  Color color2 = Colors.grey[300]!;

  /// Переменная хранящая выбранный язык
  String language = 'english';

  late String locale;

  /// Инстанс класса содержащего тексты для виджета(экрана) на поддерживаемых языках,
  /// как работает см. внутри класса
  TextAuthPage textAuthPage = TextAuthPage();

  /// Переменная для функции approveName()
  late Future<bool?> _approve;

  /// Переменная для хранения состояния готовности имени пользователя:
  /// 0 - не готово, произошла ошибка при запросе; 1 - готово и подтверждено;
  /// 2 - не готово, пришел отрицательный ответ
  int nameApproved = 2;//0 = not ready, 1 = approved, 2 = rejected

  /// Сообщение об ошибке при регистрации
  String registerErrMessage = '';

  /// Сообщение об ошибке при входе
  String loginErrMessage = '';

  TextEditingController emailSignController = TextEditingController();
  TextEditingController passwordSignController = TextEditingController();
  TextEditingController nameRegController = TextEditingController();
  TextEditingController emailRegController = TextEditingController();
  TextEditingController passwordRegController = TextEditingController();
  TextEditingController passwordRegRepController = TextEditingController();

  /// Переменная для галочки о согласии с пользовательским соглашением
  bool termsAgree = false;

  /// Future для функции loadTerms()
  late Future<String?> termsTxt;

  /// Переменная хранит результат loadTerms(), используется, чтобы не загружать
  /// данные при каждом запросе
  String termsTxtCopy = '';

  /// Переменная хранит выбранный язык с момента последней загрузки loadTerms(),
  /// при смене языка заставляет загрузить соглашение заного, на новом языке
  String copyLan = '';

  //formKey instance
  final _formKey = GlobalKey<FormState>();

  late double _s;


  @override
  void dispose() {
    emailSignController.dispose();
    passwordSignController.dispose();
    nameRegController.dispose();
    emailRegController.dispose();
    passwordRegController.dispose();
    passwordRegRepController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    locale = Localizations.localeOf(context).languageCode;

    /// Начальный автовыбор языка для приложения из поддерживаемых, исходя из языка устройства
    if(_runOnce) {
      _runOnce = false;
      switch (locale) {
        case 'en':
          language = 'english';
          break;
        case 'ru':
          language = 'russian';
          break;
        case 'de':
          language = 'german';
          break;
        case 'ja':
          language = 'japanese';
          break;
        case 'es':
          language = 'spanish';
          break;
        case 'ko':
          language = 'korean';
          break;
        case 'fr':
          language = 'french';
          break;
        case 'it':
          language = 'italian';
          break;

        default: language = 'english';
      }
    }

    _s = MediaQuery.of(context).size.width / 3;


    if (!isLoading) {
      if (showSignInPage) {
        //===================================================================
        //=========================== LOGIN =================================
        //===================================================================
        ///================================================Show Log In==========
        return Scaffold(
          backgroundColor: color0,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: color0,
            title: Text(textAuthPage.strings[language]!['T03'] ?? 'Welcome!',
            ),
            centerTitle: true,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: lanPopupMenu(),
              ),
            ],
          ),

          body: SingleChildScrollView(
            child: Center(
              child: Container(
                //height: MediaQuery.of(context).size.height - 200,//ADJUST
                color: color0,
                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 40,),
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 52,
                        child: Image(
                          image: AssetImage('assets/DejitaruMeishiLogo.png'),//TODO перенести в переменную куда-нибудь
                          height: 100.0,
                          width: 100.0,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      ///'Don\'t have an account yet?  Sign Up'
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: textAuthPage.strings[language]!['T04']
                              ?? 'Don\'t have an account yet?  ',
                          //text:,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: textAuthPage.strings[language]!['T05'] ?? 'Sign Up',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: color1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    emailSign = '';
                                    passwordSign = '';
                                    emailSignController.clear();
                                    passwordSignController.clear();

                                    showSignInPage = !showSignInPage;
                                  });
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      ///Email field (log in)-----------------------------------
                      TextFormField(
                        controller: emailSignController,
                        //autovalidateMode: AutovalidateMode.always,
                        //autovalidate: true,
                        keyboardType: TextInputType.emailAddress,
                        //maxLength: 100,
                        //maxLengthEnforced: true,
                        style: const TextStyle(
                          fontSize: 18.0,
                          //color: Colors.black,
                        ),
                        decoration: inputDecorationSetup(
                            textAuthPage.strings[language]!['T06'] ?? 'Email*', false
                        ),
                        /*validator: (val) =>
                        textAuthPage.strings[language][validators.emailSignUpValidator(
                            val)],*/
                        /*switchLanguage.textList[validators.emailSignUpValidator(
                            val)],*/
                        onChanged: (val) {
                          setState(() {
                            loginErrMessage = '';
                            emailSign = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),

                      ///Password field (log in)--------------------------------
                      TextFormField(
                        controller: passwordSignController,
                        //autovalidateMode: AutovalidateMode.always,
                        //autovalidate: true,
                        keyboardType: TextInputType.visiblePassword,
                        style: const TextStyle(
                          fontSize: 18.0,
                          //color: Colors.black,
                        ),
                        obscureText: hidePass,
                        decoration: inputDecorationSetup(
                            textAuthPage.strings[language]!['T07'] ?? 'Password*', true),
                        /*validator: (val) =>
                        textAuthPage.strings[language][validators.passwordSignUpValidator(
                            val)],*/
                        /*switchLanguage.textList[validators.passwordSignUpValidator(
                            val)],*/
                        onChanged: (val) {
                          setState(() {
                            loginErrMessage = '';
                            passwordSign = val;
                          });
                        },
                      ),
                      const SizedBox(height: 10.0),

                      ///'Forgot password?'-------------------------------------
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          text: '',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: textAuthPage.strings[language]!['T08'] ?? 'Forgot password?',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w300,
                                fontSize: 14.0,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  /// ++++++++++++++++++++++++++++++++++++++++++++++++++++  >
                                  showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (BuildContext context) => SimpleDialog(
                                      title: Center(
                                        child: Text(textAuthPage.strings[language]!['T08'] ?? 'Forgot password?',
                                          style: const TextStyle(fontSize: 20),),
                                      ),
                                      titlePadding: const EdgeInsets.all(10.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Center(
                                            child: Text(
                                              textAuthPage.strings[language]!['T16']
                                                  ?? 'Please enter your accounts name and email address to receive a reset password link',
                                              style: const TextStyle(fontSize: 20),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: TextFormField(
                                            //maxLength: 100,
                                            //maxLengthEnforced: true,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              //color: Colors.black,
                                            ),
                                            decoration: inputDecorationSetup(
                                                textAuthPage.strings[language]!['T14'] ?? 'Account Name', false),
                                            //validator: (val) => switchLanguage.textList[validators.emailSignUpValidator(val)],
                                            onChanged: (val) async {
                                              setState(() {
                                                nameReset = val;
                                              });
                                            },
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: TextFormField(
                                            //autovalidateMode: AutovalidateMode.always,
                                            //autovalidate: true,
                                            keyboardType: TextInputType.emailAddress,
                                            //maxLength: 100,
                                            //maxLengthEnforced: true,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              //color: Colors.black,
                                            ),
                                            decoration: inputDecorationSetup(
                                                textAuthPage.strings[language]!['T06'] ?? 'Email*', false
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                emailReset = val;
                                              });
                                            },
                                          ),
                                        ),


                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            TextButton(
                                              child: Text(textAuthPage.strings[language]!['T17'] ?? 'Send', style: const TextStyle(fontSize: 20),),
                                              onPressed: () async {
                                                _auth.resetPasswordFunction(emailReset, nameReset);
                                                //TODO SHOW CONFIRM DIALOG
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15.0),

                      ///MESSAGE------------------------------------------------
                      loginErrMessage != '' ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            loginErrMessage,
                            style: TextStyle(fontSize: 16, color: color1),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ) : Container(),
                      const SizedBox(height: 10.0),

                      ///Log In button------------------------------------------
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          foregroundColor: color1, // foreground
                        ),
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(8.0)),
                        // color: color1,
                        child: Text(textAuthPage.strings[language]!['T09'] ?? 'Log In',
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        onPressed: () async {
                          setState(() => isLoading = true);
                          var connectivityResult = await (Connectivity().checkConnectivity());
                          if(connectivityResult != ConnectivityResult.none) {
                            dynamic result = await _auth.signInFunction(
                                emailSign, passwordSign);
                            if (result == null) {
                              setState(() {
                                isLoading = false;
                                loginErrMessage = textAuthPage.strings[language]!['T27']
                                    ?? 'Could not log in with provided credentials';
                              });
                            } else {
                              isLoading = false;
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                              loginErrMessage = textAuthPage.strings[language]!['T28']
                                  ?? 'Please check your internet connection and try again';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 40,),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        //===================================================================
        //======================== REGISTER =================================
        //===================================================================
        ///================================================Show Sign Up======
        return Scaffold(
          backgroundColor: color0,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: color0,
            title: Text(textAuthPage.strings[language]!['T03'] ?? 'Welcome!',
            ),
            centerTitle: true,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: lanPopupMenu(),
              ),
            ],
          ),

          body: SingleChildScrollView(
            child: Center(
              child: Container(
                //height: MediaQuery.of(context).size.height - 80,
                color: color0,
                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 40,),
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 52,
                        child: Image(
                          image: AssetImage('assets/DejitaruMeishiLogo.png'),
                          height: 100.0,
                          width: 100.0,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      ///'Already have an account?  Log in language(icon)'------
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: textAuthPage.strings[language]!['T11']
                              ?? 'Already have an account?  ',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: textAuthPage.strings[language]!['T09'] ?? 'Log In',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.deepOrangeAccent[400],
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    nameApproved = 2;
                                    nameReg = '';
                                    emailReg = '';
                                    passwordReg = '';
                                    nameRegController.clear();
                                    emailRegController.clear();
                                    passwordRegController.clear();
                                    passwordRegRepController.clear();

                                    showSignInPage = !showSignInPage;
                                  });
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      ///APPROVE NAME ICON (sign up)----------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            (nameReg.isNotEmpty && textAuthPage.strings[language]![validators
                                .accountNameValidator(nameReg)] == null) ? FutureBuilder(
                                future: _approve,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    if(snapshot.data != null) {
                                      if(snapshot.data == true) {
                                        nameApproved = 1;// approved
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(textAuthPage.strings[language]!['T20'] ?? 'Name is free to use',
                                              style: TextStyle(color: color2, fontSize: 16),
                                            ),
                                            const SizedBox(width: 10.0),
                                            Icon(
                                              Icons.check,
                                              size: 30,
                                              color: color2,
                                            ),
                                          ],
                                        );
                                      } else {
                                        nameApproved = 2;// rejected
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(textAuthPage.strings[language]!['T21'] ?? 'Name is already taken',
                                              style: TextStyle(color: color1, fontSize: 16),
                                            ),
                                            const SizedBox(width: 10.0),
                                            Icon(
                                              Icons.error_outline,
                                              size: 30,
                                              color: color1,
                                            ),
                                          ],
                                        );
                                      }
                                    } else {
                                      nameApproved = 0;// not ready
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(textAuthPage.strings[language]!['T34'] ?? 'Error',
                                            style: TextStyle(color: color1, fontSize: 16),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Icon(
                                            Icons.warning_amber_outlined,
                                            size: 30,
                                            color: color1,
                                          ),
                                        ],
                                      );
                                    }
                                  } else {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(textAuthPage.strings[language]!['T22'] ?? 'Checking name...',
                                          style: TextStyle(color: color2, fontSize: 16),
                                        ),
                                        const SizedBox(width: 10.0),
                                        SpinKitDualRing(
                                          size: 30,
                                          color: color1,
                                        ),
                                      ],
                                    );
                                  }
                                }
                            ) : Container(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      ///Name field (sign up)-----------------------------------
                      TextFormField(
                        controller: nameRegController,
                        autovalidateMode: AutovalidateMode.always,
                        /*maxLength: 32,
                        maxLengthEnforced: true,*/
                        style: const TextStyle(
                          fontSize: 18.0,
                          //color: Colors.black,
                        ),
                        decoration: inputDecorationSetup(
                            textAuthPage.strings[language]!['T14'] ?? 'Account Name', false),
                        validator: (val) =>
                        textAuthPage.strings[language]![validators
                            .accountNameValidator(val!)],
                        onChanged: (val) {
                          setState(() {
                            nameReg = val;
                            nameApproved = 0;// not ready
                            validateRegisterErrMessageFunc();
                            if(val.isNotEmpty && textAuthPage.strings[language]![validators
                                .accountNameValidator(val)] == null) {
                              _approve = approveName(val);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 10.0),

                      ///Email field (sign up)----------------------------------
                      TextFormField(
                        controller: emailRegController,
                        autovalidateMode: AutovalidateMode.always,
                        //autovalidate: true,
                        keyboardType: TextInputType.emailAddress,
                        //maxLength: 100,
                        //maxLengthEnforced: true,
                        style: const TextStyle(
                          fontSize: 18.0,
                          //color: Colors.black,
                        ),
                        decoration: inputDecorationSetup(
                            textAuthPage.strings[language]!['T06'] ?? 'Email*', false),
                        validator: (val) =>
                        textAuthPage.strings[language]![validators.emailSignUpValidator(
                            val!)],
                        /*switchLanguage.textList[validators.emailSignUpValidator(
                            val)],*/
                        onChanged: (val) {
                          setState(() {
                            emailReg = val;
                            validateRegisterErrMessageFunc();
                          });
                        },
                      ),
                      const SizedBox(height: 10.0),

                      ///Password field (sign up)-------------------------------
                      TextFormField(
                        controller: passwordRegController,
                        autovalidateMode: AutovalidateMode.always,
                        //autovalidate: true,
                        keyboardType: TextInputType.visiblePassword,
                        style: const TextStyle(
                          fontSize: 18.0,
                          //color: Colors.black,
                        ),
                        obscureText: hidePass,
                        decoration: inputDecorationSetup(
                            textAuthPage.strings[language]!['T07'] ?? 'Password*', true),
                        validator: (val) =>
                        textAuthPage.strings[language]![validators
                            .passwordSignUpValidator(val!)],
                        /*switchLanguage.textList[validators
                            .passwordSignUpValidator(val)],*/
                        onChanged: (val) {
                          setState(() {
                            passwordReg = val;
                            validateRegisterErrMessageFunc();
                          });
                        },
                      ),
                      const SizedBox(height: 10.0),

                      ///Repeat Password field (sign up)--------------------------
                      TextFormField(
                        controller: passwordRegRepController,
                        autovalidateMode: AutovalidateMode.always,
                        //autovalidate: true,
                        keyboardType: TextInputType.visiblePassword,
                        style: const TextStyle(
                          fontSize: 18.0,
                          //color: Colors.black,
                        ),
                        obscureText: hidePass,
                        decoration: inputDecorationSetup(
                            textAuthPage.strings[language]!['T13'] ?? 'Confirm password*', true),
                        validator: (val) =>
                        textAuthPage.strings[language]![validators
                            .repeatPasswordSignUpValidator(passwordReg, passwordRepReg)],
                        /*switchLanguage.textList[validators
                            .repeatPasswordSignUpValidator(passwordReg, passwordRepReg)],*/
                        onChanged: (val) {
                          setState(() {
                            passwordRepReg = val;
                            validateRegisterErrMessageFunc();
                          });
                        },
                      ),
                      const SizedBox(height: 10.0),

                      ///MESSAGE-----------------------------------
                      registerErrMessage != '' ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            registerErrMessage,
                            style: TextStyle(fontSize: 16, color: color1),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ) : Container(),
                      const SizedBox(height: 10.0),

                      Center(
                        child: InkWell(
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              Text(textAuthPage.strings[language]!['T29'] ?? 'Terms of service and Privacy policy',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: termsAgree == false ? color1 : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Icon(termsAgree == false ? Icons.check_box_outline_blank : Icons.check_box,
                                color: termsAgree == false ? color1 : Colors.white,
                              ),
                            ],
                          ),
                          onTap: () {
                            termsTxt = loadTerms(termsTxtCopy, language, copyLan);

                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) => SimpleDialog(
                                // title: Center(
                                //   child: Text(textAuthPage.strings[language]['T30'] ?? 'Please read and accept',
                                //     style: TextStyle(fontSize: 20),
                                //     textAlign: TextAlign.center,
                                //   ),
                                // ),
                                title: Column(
                                  children: [
                                    Center(
                                      child: Text(textAuthPage.strings[language]!['T30'] ?? 'Please read and accept',
                                        style: const TextStyle(fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        TextButton(
                                          child: Text(textAuthPage.strings[language]!['T31'] ?? 'Accept',
                                            style: TextStyle(fontSize: 20, color: color1),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              termsAgree = true;
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                          child: Text(textAuthPage.strings[language]!['T32'] ?? 'Decline',
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              termsAgree = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                titlePadding: const EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                children: <Widget>[
                                  FutureBuilder(
                                      future: termsTxt,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          if(snapshot.data != null) {
                                            termsTxtCopy = snapshot.data as String;
                                            copyLan = language;
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Text(termsTxtCopy),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Text(textAuthPage.strings[language]!['T28']
                                                      ?? 'Please check your internet connection and try again'),
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: <Widget>[
                                                    TextButton(
                                                      child: Text(textAuthPage.strings[language]!['T33'] ?? 'Ok',
                                                        style: const TextStyle(fontSize: 20),
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          termsAgree = false;
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }
                                        } else {
                                          return SpinKitDualRing(
                                            size: 40,
                                            color: color0,
                                          );
                                        }
                                        //return null;
                                      }
                                  ),

                                ],
                              ),
                            );


                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      ///Sign Up button-----------------------------------
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          foregroundColor: color1,
                          disabledForegroundColor: Colors.grey[800], // foreground
                        ),
                        child: Text(textAuthPage.strings[language]!['T05'] ?? 'Sign Up',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: termsAgree == false ? color2 : color0,
                          ),
                        ),
                        onPressed: termsAgree == true ? () async {
                          validateRegisterErrMessageFunc();
                          if(nameApproved == 1) {

                            if (_formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              dynamic result = await _auth.registerFunction(
                                  emailReg, passwordReg, nameReg, language);
                              if (result == null) {
                                setState(() {
                                  isLoading = false;
                                  registerErrMessage = textAuthPage.strings[language]!['T23'] ?? 'Error occurred while signing up';
                                  //print('error sign in');
                                });
                              }
                            } else {
                              setState(() {
                                isLoading = false;
                                //print('error sign in');
                              });
                            }
                          } else {
                            //print('NOT READY TO SIGN UP');
                          }
                        } : null,
                      ),
                      const SizedBox(height: 40,),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
      ///================================================Loading================
    } else {
      return Container(
        color: Colors.grey[900],
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SpinKitDualRing(
              color: Colors.deepOrangeAccent[400]!,
              size: _s,//160
            ),
            SpinKitCubeGrid(
              color: Colors.grey[600],
              size: _s / 1.7778,
            ),
          ],
        ),
      );
    }//if(isLoading)
  }//if(showSighIn)


  ///................
  //TODO make this into a initState AND ditch the validator
  String? emailSignUpValidator(String val){
    if (val.isNotEmpty) {
      if (val.contains(RegExp(r'[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,64}'))) {
        return null;
      } else {
        return 'Valid Email is required';
      }
    } else {
      return 'This field must not be empty';
    }
  }


  /// Функция, возвращает InputDecoration для TextFormField,
  /// требует переменные: String для hintText и bool для поля пароля,
  /// если true, то показывает иконку suffix с функцией переключения видимости,
  /// остальные параметры получает из txtInputDecor.
  ///
  InputDecoration inputDecorationSetup(String hint, bool pass) {
    if (pass) {
      return txtInputDecor.copyWith(
        suffix: IconButton(
          padding: const EdgeInsets.all(0.0),
          constraints: const BoxConstraints(minHeight: 16.0, minWidth: 16.0),
          iconSize: 16.0,
          icon: hidePass ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
          onPressed: () {
            hidePass = !hidePass;
            setState(() {});
          },
        ),
        hintText: hint,
      );
    } else {
      return txtInputDecor.copyWith(
        hintText: hint,
      );
    }
  }


  validateRegisterErrMessageFunc() {
    setState(() {
      if(textAuthPage.strings[language]![validators.accountNameValidator(nameReg)] != null || nameApproved == 2) {
        registerErrMessage = textAuthPage.strings[language]!['T25'] ?? 'Unique Account Name is required';
      } else {
        if(textAuthPage.strings[language]![validators.emailSignUpValidator(emailReg)] != null
            || textAuthPage.strings[language]![validators.passwordSignUpValidator(passwordReg)] != null
            || textAuthPage.strings[language]![validators.repeatPasswordSignUpValidator(passwordReg, passwordRepReg)] != null
        ) {
          registerErrMessage = textAuthPage.strings[language]!['T24']
              ?? 'Please fill in all required fields with correct information';
        } else {
          registerErrMessage = '';
        }
      }
    });
  }


  /// Выскакивающий список выбора языка
  ///
  PopupMenuButton lanPopupMenu() {
    return PopupMenuButton<languages>(
      icon: Icon(
        Icons.translate,
        color: color2,
        size: 20.0,
      ),
      onSelected: (languages result) {
        setState(() {
          switch(result) {
            case languages.english:
              language = 'english';
              break;
            case languages.russian:
              language = 'russian';
              break;
            case languages.german:
              language = 'german';
              break;
            case languages.japanese:
              language = 'japanese';
              break;
            case languages.italian:
              language = 'italian';
              break;
            case languages.french:
              language = 'french';
              break;
            case languages.spanish:
              language = 'spanish';
              break;
            case languages.korean:
              language = 'korean';
              break;
            default: language = 'english';
          }
          //_selection = result;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<languages>>[
        const PopupMenuItem<languages>(
          value: languages.english,
          child: Text('English'),
        ),
        const PopupMenuItem<languages>(
          value: languages.russian,
          child: Text('Русский'),
        ),
        const PopupMenuItem<languages>(
          value: languages.german,
          child: Text('Deutsche'),
        ),
        const PopupMenuItem<languages>(
          value: languages.japanese,
          child: Text('日本人'),
        ),
        const PopupMenuItem<languages>(
          value: languages.italian,
          child: Text('Italiano'),
        ),
        const PopupMenuItem<languages>(
          value: languages.french,
          child: Text('Français'),
        ),
        const PopupMenuItem<languages>(
          value: languages.spanish,
          child: Text('Español'),
        ),
        const PopupMenuItem<languages>(
          value: languages.korean,
          child: Text('한국어'),
        ),
      ],
    );
  }

}


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



/// Функция передает имя пользователя в FirebaseFunction для сравнения, чтобы
/// исключить повтор никнейма пользователя. В качестве ответа получает bool.
/// Возвращает true, если имя свободно; false, если занято; null если произошла ошибка
/// TODO -- ЗАМЕНИТЬ?, Т.К. ФУНКЦИИ FIREBASE БОЛЬШЕ НЕ ДОСТУПНЫ НА ТАРИФЕ SPARK!
///
Future<bool?> approveName(String val) async {
  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'approveAccountName',
  );
  var v = val.toLowerCase();
  try {
    var result = await callable.call({
      'name': v,
    });
    return result.data;
  } catch(e) {
    //print('$e');
    return null;
  }
}

/// Функция делает загружает документ с пользовательским соглашением выбранного языка
/// из Firestore
///
Future<String?> loadTerms(String? copy, String language, String copyLan) async {

  if(copy == null || copyLan != language) {
    try {
      //TODO maybe load terms from website?
      var result = await FirebaseFirestore.instance.collection('licenses').doc('terms').get();
      return result.data()?[language];
    } catch(e) {
      //print('$e');
      return null;
    }
  } else {
    return copy;
  }

}