import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../functions/authservice.dart';
import '../functions/data_services/update_user_settings.dart';
import '../functions/pick_image.dart';
import '../models/route_arguments.dart';
import '../models/user_settings.dart';
import '../shared/colors_map.dart';
import '../texts/text_settings_page.dart';
import 'data_holder.dart';
import 'loading_page.dart';


class SettingsPage extends StatefulWidget {

  final String uid;
  final BuildContext cont;

  const SettingsPage({Key? key,
    required this.uid,
    required this.cont
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final AuthService _auth = AuthService();

  //TODO Dispose maybe, cuz it will be initialized in initState
  Map<String, String> colorName = {
    '0': 'Pink',
    '1': 'Red',
    '2': 'Deep Orange',
    '3': 'Orange',
    '4': 'Amber',
    '5': 'Yellow',
    '6': 'Lime',
    '7': 'Light Green',
    '8': 'Green',
    '9': 'Teal',
    '10': 'Cyan',
    '11': 'Light Blue',
    '12': 'Blue',
    '13': 'Indigo',
    '14': 'Purple',
    '15': 'Deep Purple',
    '16': 'Grey',
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    userSettings = DataHolder.of(widget.cont)!.userSettings;


    _sliderColor = double.parse(userSettings.colorNum);
    _sliderShade = double.parse(userSettings.shadeNum);

    language = userSettings.language;
    selectedLanguage = languageNamesReverse[language];

    _reassignColorNames();

    _imgPick = null;
    _imgUrl = userSettings.photoUrl;
    _txtAbout = userSettings.about;

    passwordNewController.clear();
    passwordNewRepController.clear();
  }

  @override
  void dispose() {
    txtController.dispose();
    passwordController.dispose();
    passwordNewController.dispose();
    passwordNewRepController.dispose();
    emailNewController.dispose();

    super.dispose();
  }


  late UserSettings userSettings;

  double _sliderColor = 2;
  double _sliderShade = 1200;

  bool _isUploading = false;

  String? selectedLanguage = 'English';
  List<String> chartLanguages = ['English', 'Русский', 'Deutsche', '日本語', 'Italiano', 'Français', 'Español', '한국어'];
  Map<String, String> languageNames = {
    'English': 'english',
    'Русский': 'russian',
    'Deutsche': 'german',
    '日本語': 'japanese',
    'Italiano': 'italian',
    'Français': 'french',
    'Español': 'spanish',
    '한국어': 'korean',
  };
  Map<String, String> languageNamesReverse = {
    'english': 'English',
    'russian': 'Русский',
    'german': 'Deutsche',
    'japanese': '日本語',
    'italian': 'Italiano',
    'french': 'Français',
    'spanish': 'Español',
    'korean': '한국어',
  };

  final txtController = TextEditingController();
  final emailNewController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordNewController = TextEditingController();
  final passwordNewRepController = TextEditingController();

  Color? highlightColor = Colors.deepOrangeAccent[700];
  String? language = 'english';//TODO
  TextSettingsPage textSettingsPage = TextSettingsPage();

  late File? _imgPick;
  late String _imgUrl;
  late String _txtAbout;

  late String _email;
  late bool _emailVerified;

  late UserSettings _tempSettings;

  late Future<PackageInfo> getAboutApp;

  late BuildContext mainContext;

  dynamic snapshotData;


  _upload() async {
    //TODO like in editor
    _tempSettings = userSettings;

    _tempSettings.photoUrl = _imgUrl;
    _tempSettings.about = _txtAbout;
    _tempSettings.language = languageNames[selectedLanguage]!;
    var _r = await updateUserSettings(widget.uid, _tempSettings, _imgPick);
/*    if(_r == true) {
      print('SETTING UPLOAD SUCCESSFUL');
    } else {
      print('SETTING UPLOAD FAILED');
    }*/
  }

  _reassignColorNames() {
    colorName = {
      '0': textSettingsPage.strings[language]!['T00'] ?? 'Pink',
      '1': textSettingsPage.strings[language]!['T01'] ?? 'Red',
      '2': textSettingsPage.strings[language]!['T02'] ?? 'Deep Orange',
      '3': textSettingsPage.strings[language]!['T03'] ?? 'Orange',
      '4': textSettingsPage.strings[language]!['T04'] ?? 'Amber',
      '5': textSettingsPage.strings[language]!['T05'] ?? 'Yellow',
      '6': textSettingsPage.strings[language]!['T06'] ?? 'Lime',
      '7': textSettingsPage.strings[language]!['T07'] ?? 'Light Green',
      '8': textSettingsPage.strings[language]!['T08'] ?? 'Green',
      '9': textSettingsPage.strings[language]!['T09'] ?? 'Teal',
      '10': textSettingsPage.strings[language]!['T10'] ?? 'Cyan',
      '11': textSettingsPage.strings[language]!['T11'] ?? 'Light Blue',
      '12': textSettingsPage.strings[language]!['T12'] ?? 'Blue',
      '13': textSettingsPage.strings[language]!['T13'] ?? 'Indigo',
      '14': textSettingsPage.strings[language]!['T14'] ?? 'Purple',
      '15': textSettingsPage.strings[language]!['T15'] ?? 'Deep Purple',
      '16': textSettingsPage.strings[language]!['T16'] ?? 'Grey',
    };
  }

  late double w;
  late double w1;
  late double w2;


  @override
  Widget build(BuildContext context) {

    mainContext = context;

    w = MediaQuery.of(context).size.width;
    w1 = (w - 20) / 4;
    w2 = (w - 40) * 0.5;

    final _user = Provider.of<User>(context);
    _email = _user.email!;
    _emailVerified = _user.emailVerified;


    return _isUploading ? Loading(color: highlightColor!) : Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[900],
        title: Text(textSettingsPage.strings[language]!['T17'] ?? 'Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey[500]),
            onPressed: () {

              Navigator.of(context).pushNamed('/help_page',
                  arguments: RouteArguments(
                    title: 'settings',
                    language: language,
                  )
              );

            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20,),

            //------------- Change PHOTO ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                children: [
                  const SizedBox(width: 20,),

                  SizedBox(
                    height: w1,
                    width: w1,
                    child: _imgPick != null ? CircleAvatar(
                      maxRadius: (w1 / 2) - 5,
                      //radius: (w1 / 2),
                      backgroundColor: Colors.grey[800],
                      child: (_imgPick == null && _imgUrl.isEmpty) ? Icon(
                        Icons.person,
                        size: w1 * 0.8,
                        color: Colors.grey[700],
                      ) : Container(),
                      backgroundImage: FileImage(_imgPick!),
                    ) :
                    _imgUrl.isNotEmpty ? CircleAvatar(
                      maxRadius: (w1 / 2) - 5,
                      //radius: (w1 / 2),
                      backgroundColor: Colors.grey[800],
                      child: (_imgPick == null && _imgUrl.isEmpty) ? Icon(
                        Icons.person,
                        size: w1 * 0.8,
                        color: Colors.grey[700],
                      ) : Container(),
                      backgroundImage: NetworkImage(userSettings.photoUrl,
                        ),
                    ) :
                    CircleAvatar(
                      maxRadius: (w1 / 2) - 5,
                      //radius: (w1 / 2),
                      backgroundColor: Colors.grey[800],
                      child: (_imgPick == null && _imgUrl.isEmpty) ? Icon(
                          Icons.person,
                          size: w1 * 0.8,
                          color: Colors.grey[700],
                        ) : Container(),
                      backgroundImage: const AssetImage('assets/empty.png'),
                    ),
                  ),

                  SizedBox(
                    height: w1,
                    width: w1,
                    child: IconButton(
                      icon: Icon(Icons.photo, size: w1 / 2.5,
                          color: Colors.grey[300]),
                      onPressed: () async {
                        _imgPick = (await PickImage(userSettings: userSettings).gallery()) as File?;
                        if(_imgPick != null) {
                          setState(() {});
                        }
                      },
                    ),
                  ),

                  SizedBox(
                    height: w1,
                    width: w1,
                    child: IconButton(
                      icon: Icon(Icons.photo_camera, size: w1 / 2.5,
                          color: Colors.grey[300]),
                      onPressed: () async {
                        _imgPick = (await PickImage(userSettings: userSettings).camera()) as File?;
                        if(_imgPick != null) {
                          setState(() {});
                        }
                      },
                    ),
                  ),

                  SizedBox(
                    height: w1,
                    width: w1,
                    child: IconButton(
                      icon: Icon(Icons.clear, size: w1 / 2.5,
                          color: Colors.grey[300]),
                      onPressed: () async {
                        setState(() {
                          _imgPick = null;
                          _imgUrl = '';
                        });
                      },
                    ),
                  ),

                ],
              ),
            ),

            Divider(
              color: Colors.grey[700],
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),

            //------------- Change ACCOUNT NAME ----------------
            Center(
              child: Text(userSettings.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white, fontSize: 20,
                ),
              ),
            ),

            Divider(
              color: Colors.grey[700],
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),

            //------------- Change ABOUT Info ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: (w - 40) * 0.8,
                    child: Wrap(
                      children: [
                        Text(_txtAbout,
                          style: TextStyle(
                            color: Colors.grey[400], fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: (w - 40) * 0.2,
                    child: IconButton(
                      iconSize: 30,
                      color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                      icon: const Icon(Icons.edit,),
                      onPressed: () {
                        ///

                        txtController.text = _txtAbout;
                        //_txtAbout = userSettings.about;

                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context) => SimpleDialog(

                            title: Center(
                              child: Text(
                                textSettingsPage.strings[language]!['T24'] ?? 'About you',//TODO: PROBLEM WITH SIZE
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            titlePadding: const EdgeInsets.all(10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            children: <Widget>[

                              //============= Edit About ==================
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  maxLength: 200,//TODO: adjust
                                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                  controller: txtController,
                                  decoration: InputDecoration(

                                    // labelText: textSettingsPage.strings[language]['About you'] ?? 'About you',//'Title'
                                    // labelStyle: TextStyle(color: Colors.grey),

                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide(
                                        width: 1.0,
                                        color: Colors.grey,//grey[200]
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide(
                                        color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,//deepOrangeAccent[400]
                                      ),
                                    ),
                                    focusedErrorBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        )
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        borderSide: BorderSide(
                                          width: 1.0,
                                          color: Colors.grey,//grey[500]
                                        )
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  //textInputAction: TextInputAction.newline,
                                  minLines: 2,
                                  maxLines: 4,
                                  onChanged: (val) {
                                    setState(() {
                                      _txtAbout = val;
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  TextButton(
                                    child: Row(
                                      children: [
                                        Text(textSettingsPage.strings[language]!['T25'] ?? 'Cancel',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 2,),
                                        const Icon(Icons.clear),
                                      ],
                                    ),//'Cancel'
                                    onPressed: () {
                                      txtController.clear();
                                      _txtAbout = userSettings.about;
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Row(
                                      children: [
                                        Text(textSettingsPage.strings[language]!['T26'] ?? 'Done',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 2,),
                                        const Icon(Icons.check),
                                      ],
                                    ),//'Done'
                                    onPressed: () {
                                      ///
                                      txtController.clear();
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
                  ),
                ],
              ),
            ),

            Divider(
              color: Colors.grey[700],
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),

            //-------------------- Change EMAIL --------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Center(
                    child: Text(_email,
                      style: TextStyle(
                        color: Colors.grey[400], fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: w2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: _emailVerified != true ? TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              foregroundColor: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,
                            ),
                            child: Text(textSettingsPage.strings[language]!['T27'] ?? 'Verify',
                              style: TextStyle(
                                color: Colors.grey[900], fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              _user.sendEmailVerification();

                              showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context) => SimpleDialog(
                                  title: Center(
                                    child: Text(textSettingsPage.strings[language]!['T29'] ?? 'Verify email',
                                      style: const TextStyle(fontSize: 20),),
                                  ),
                                  titlePadding: const EdgeInsets.all(10.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  children: <Widget>[
                                    Center(
                                      child: Icon(
                                        Icons.check_circle_outline,
                                        size: 40,
                                        color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Center(
                                        child: Text(
                                          textSettingsPage.strings[language]!['T30']
                                              ?? 'A link to verify your email address has been sent',
                                          style: const TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    TextButton(
                                      child: Text(textSettingsPage.strings[language]!['T41'] ?? 'Ok',
                                        style: const TextStyle(fontSize: 18),
                                      ),//'Cancel'
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),

                                  ],
                                ),
                              );

                            },
                          ) : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(textSettingsPage.strings[language]!['T28'] ?? 'Verified',
                                style: TextStyle(
                                  color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(Icons.check,
                                color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        width: w2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              foregroundColor: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,
                            ),
                            child: Text(textSettingsPage.strings[language]!['T31'] ?? 'Change',
                              style: TextStyle(
                                color: Colors.grey[900], fontSize: 16,
                              ),
                            ),
                            onPressed: () async {
                              /// ##################### CHANGE EMAIL #######################
                              String? _pass;

                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context0) => SimpleDialog(
                                  title: Center(
                                    child: Text(textSettingsPage.strings[language]!['T32'] ?? 'Authentication',
                                      style: const TextStyle(fontSize: 20),),
                                  ),
                                  titlePadding: const EdgeInsets.all(10.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  children: <Widget>[

                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: TextFormField(
                                        controller: passwordController,
                                        //maxLength: 100,
                                        //maxLengthEnforced: true,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          //color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: textSettingsPage.strings[language]!['T33'] ?? 'Enter password',
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.0,
                                              color: Colors.grey,//grey[200]
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            borderSide: BorderSide(
                                              color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,//deepOrangeAccent[400]
                                            ),
                                          ),
                                          focusedErrorBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              )
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                              borderSide: BorderSide(
                                                width: 1.0,
                                                color: Colors.grey,//grey[500]
                                              )
                                          ),
                                        ),

                                        onChanged: (val) async {
                                          setState(() {
                                            _pass = val;
                                          });
                                        },
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        TextButton(
                                          child: Row(
                                            children: [
                                              Text(textSettingsPage.strings[language]!['T25'] ?? 'Cancel',
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                              const SizedBox(width: 2,),
                                              const Icon(Icons.clear),
                                            ],
                                          ),//'Cancel'
                                          onPressed: () {
                                            passwordController.clear();
                                            Navigator.pop(context0);
                                          },
                                        ),
                                        TextButton(
                                          child: Row(
                                            children: [
                                              Text(textSettingsPage.strings[language]!['T34'] ?? 'Continue',
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                              const SizedBox(width: 2,),
                                              const Icon(Icons.arrow_forward),
                                            ],
                                          ),
                                          onPressed: () async {

                                            /// authenticate
                                            UserCredential? _result;
                                            try {
                                              _result = await _user.reauthenticateWithCredential(EmailAuthProvider.credential(email: _user.email!, password: _pass!));
                                            } catch(e) {
                                              _result = null;
                                            }

                                            _pass = null;
                                            passwordController.clear();

                                            if(_result != null) {
                                              String _newemail = '';

                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext context1) => SimpleDialog(
                                                  title: Center(
                                                    child: Text(textSettingsPage.strings[language]!['T35'] ?? 'Change email',
                                                      style: const TextStyle(fontSize: 20),),
                                                  ),
                                                  titlePadding: const EdgeInsets.all(10.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                  ),
                                                  children: <Widget>[

                                                    Form(
                                                      key: _formKey,
                                                      child: Column(
                                                        children: [
                                                          //########### NEW EMAIL ######
                                                          Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: TextFormField(
                                                              controller: emailNewController,
                                                              autovalidateMode: AutovalidateMode.always,
                                                              keyboardType: TextInputType.visiblePassword,
                                                              style: const TextStyle(
                                                                fontSize: 18.0,
                                                                //color: Colors.black,
                                                              ),
                                                              validator: (val) {
                                                                if (val!.isNotEmpty) {
                                                                  if (RegExp(r"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}").hasMatch(val)) {
                                                                    return null;//null for validation
                                                                  } else {
                                                                    return textSettingsPage.strings[language]!['T36'] ?? 'Please enter a valid email address';
                                                                  }
                                                                } else {
                                                                  return textSettingsPage.strings[language]!['T36'] ?? 'Please enter a valid email address';
                                                                }
                                                              },
                                                              decoration: InputDecoration(
                                                                hintText: textSettingsPage.strings[language]!['T37'] ?? 'New Email',
                                                                border: const OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(8.0),
                                                                  ),
                                                                  borderSide: BorderSide(
                                                                    width: 1.0,
                                                                    color: Colors.grey,//grey[200]
                                                                  ),
                                                                ),
                                                                errorBorder: OutlineInputBorder(
                                                                  borderRadius: const BorderRadius.all(
                                                                    Radius.circular(8.0),
                                                                  ),
                                                                  borderSide: BorderSide(
                                                                    color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,//deepOrangeAccent[400]
                                                                  ),
                                                                ),
                                                                focusedErrorBorder: const OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(8.0),
                                                                    ),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.grey,
                                                                    )
                                                                ),
                                                                focusedBorder: const OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(8.0),
                                                                    ),
                                                                    borderSide: BorderSide(
                                                                      width: 1.0,
                                                                      color: Colors.grey,//grey[500]
                                                                    )
                                                                ),
                                                              ),

                                                              onChanged: (val) async {
                                                                setState(() {
                                                                  _newemail = val;
                                                                });
                                                              },
                                                            ),
                                                          ),

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: <Widget>[
                                                              TextButton(
                                                                child: Row(
                                                                  children: [
                                                                    Text(textSettingsPage.strings[language]!['T25'] ?? 'Cancel',
                                                                      style: const TextStyle(fontSize: 18),
                                                                    ),
                                                                    const SizedBox(width: 2,),
                                                                    const Icon(Icons.clear),
                                                                  ],
                                                                ),//'Cancel'
                                                                onPressed: () {
                                                                  emailNewController.clear();
                                                                  Navigator.pop(context1);
                                                                  Navigator.pop(context0);
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: Row(
                                                                  children: [
                                                                    Text(textSettingsPage.strings[language]!['T66'] ?? 'Confirm',
                                                                      style: const TextStyle(fontSize: 18),
                                                                    ),
                                                                    const SizedBox(width: 2,),
                                                                    const Icon(Icons.check),
                                                                  ],
                                                                ),//'Done'
                                                                onPressed: () async {
                                                                  if (_formKey.currentState!.validate()) {
                                                                    /// -----------------------------
                                                                    bool? _result;
                                                                    String _message;
                                                                    try {
                                                                      await _user.verifyBeforeUpdateEmail(_newemail);
                                                                      //_user.updateEmail(_newemail);
                                                                      //_auth.signOutFunction();
                                                                      _result = true;
                                                                    } catch(e) {
                                                                      _result = null;
                                                                    }
                                                                    if(_result == true) {
                                                                      _message = textSettingsPage.strings[language]!['T38']
                                                                          ?? 'A confirmation link has been sent to your new email address. To complete the change, please follow the link and re-login to the app';
                                                                    } else {
                                                                      _message = textSettingsPage.strings[language]!['T39']
                                                                          ?? 'Could not change, please check internet connection or try again later';
                                                                    }

                                                                    showDialog(
                                                                      barrierDismissible: false,
                                                                      context: context,
                                                                      builder: (BuildContext context2) => SimpleDialog(
                                                                        title: Center(
                                                                          child: Text(textSettingsPage.strings[language]!['T40'] ?? 'Email change',
                                                                            style: const TextStyle(fontSize: 20),),
                                                                        ),
                                                                        titlePadding: const EdgeInsets.all(10.0),
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                        ),
                                                                        children: <Widget>[
                                                                          Center(
                                                                            child: Icon(
                                                                              _result == true ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                                                                              size: 40,
                                                                              color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                                                                            ),
                                                                          ),

                                                                          Padding(
                                                                            padding: const EdgeInsets.all(10.0),
                                                                            child: Center(
                                                                              child: Text(
                                                                                textSettingsPage.strings[language]![_message]
                                                                                    ?? _message,
                                                                                style: const TextStyle(fontSize: 20),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          ),

                                                                          TextButton(
                                                                            child: Text(textSettingsPage.strings[language]!['T41'] ?? 'Ok',
                                                                              style: const TextStyle(fontSize: 18),
                                                                            ),//'Cancel'
                                                                            onPressed: () {
                                                                              emailNewController.clear();
                                                                              Navigator.pop(context2);
                                                                              Navigator.pop(context1);
                                                                              Navigator.pop(context0);
                                                                            },
                                                                          ),

                                                                        ],
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    ///
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              );
                                            } else {
                                              emailNewController.clear();

                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext context1) => SimpleDialog(
                                                  title: Center(
                                                    child: Text(textSettingsPage.strings[language]!['T42'] ?? 'Error',
                                                      style: const TextStyle(fontSize: 20),),
                                                  ),
                                                  titlePadding: const EdgeInsets.all(10.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                  ),
                                                  children: <Widget>[

                                                    Center(
                                                      child: Icon(
                                                        Icons.warning_amber_outlined,
                                                        size: 40,
                                                        color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: Center(
                                                        child: Text(
                                                          textSettingsPage.strings[language]!['T43']
                                                              ?? 'An error occurred in the process. Check if the password you entered is correct or check your internet connection. If you forgot your password, try resetting it',
                                                          style: const TextStyle(fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: <Widget>[
                                                        TextButton(
                                                          child: Row(
                                                            children: [
                                                              Text(textSettingsPage.strings[language]!['T25'] ?? 'Cancel',
                                                                style: const TextStyle(fontSize: 18),
                                                              ),
                                                              const SizedBox(width: 2,),
                                                              const Icon(Icons.clear),
                                                            ],
                                                          ),//'Cancel'
                                                          onPressed: () {
                                                            Navigator.pop(context1);
                                                            Navigator.pop(context0);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Row(
                                                            children: [
                                                              Text(textSettingsPage.strings[language]!['T44'] ?? 'Retry',
                                                                style: const TextStyle(fontSize: 18),
                                                              ),
                                                              const SizedBox(width: 2,),
                                                              const Icon(Icons.arrow_back),
                                                            ],
                                                          ),//'Done'
                                                          onPressed: () {
                                                            Navigator.pop(context1);
                                                          },
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              );

                              /// #####################################
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(
              color: Colors.grey[700],
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),

            //----------------------- Change PASSWORD --------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Center(
                    child: Text(textSettingsPage.strings[language]!['T45'] ?? 'Password',
                      style: TextStyle(
                        color: Colors.grey[400], fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      SizedBox(
                        width: w2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              foregroundColor: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                            ),
                            child: Text(textSettingsPage.strings[language]!['T46'] ?? 'Reset',
                              style: TextStyle(
                                color: Colors.grey[900], fontSize: 16,
                              ),
                            ),
                            onPressed: () async {
                              /// &&&&&&&&&&&&& RESET PASSWORD &&&&&&&&&&&&&&&&&
                              ///
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => SimpleDialog(
                                  title: Center(
                                    child: Text(textSettingsPage.strings[language]!['T66'] ?? 'Confirm',
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
                                          textSettingsPage.strings[language]!['T49']
                                              ?? 'Send a reset link to your email address?',
                                          style: const TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        TextButton(
                                          child: Text(textSettingsPage.strings[language]!['T25'] ?? 'Cancel',
                                            style: const TextStyle(fontSize: 18),
                                          ),//'Cancel'
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                          child: Text(textSettingsPage.strings[language]!['T50'] ?? 'Send',
                                            style: const TextStyle(fontSize: 18),
                                          ),//'Cancel'
                                          onPressed: () {
                                            _auth.resetPasswordFunction(_user.email!, userSettings.name);

                                            showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (BuildContext context1) => SimpleDialog(
                                                title: Center(
                                                  child: Text(textSettingsPage.strings[language]!['T47'] ?? 'Password reset',
                                                    style: const TextStyle(fontSize: 20),),
                                                ),
                                                titlePadding: const EdgeInsets.all(10.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                ),
                                                children: <Widget>[
                                                  Center(
                                                    child: Icon(
                                                      Icons.check_circle_outline,
                                                      size: 40,
                                                      color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Center(
                                                      child: Text(
                                                        textSettingsPage.strings[language]!['T48']
                                                            ?? 'To reset your password, follow the link sent to your email address',
                                                        style: const TextStyle(fontSize: 20),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  ),

                                                  TextButton(
                                                    child: Text(textSettingsPage.strings[language]!['T41'] ?? 'Ok',
                                                      style: const TextStyle(fontSize: 18),
                                                    ),//'Cancel'
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context1);
                                                    },
                                                  ),

                                                ],
                                              ),
                                            );

                                          },
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              );

                              /// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        width: w2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              foregroundColor: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                            ),
                            //height: 20,
                            child: Text(textSettingsPage.strings[language]!['T31'] ?? 'Change',
                              style: TextStyle(
                                color: Colors.grey[900], fontSize: 16,
                              ),
                            ),
                            onPressed: () async {
                              /// %%%%%%%%%%%%%%%%%%%%%%%% CHANGE PASSWORD %%%%%%%%%%%%%%%%%%%%%%%%%%%5

                              String? _pass = '';
                              ///
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context0) => SimpleDialog(
                                  title: Center(
                                    child: Text(textSettingsPage.strings[language]!['T32'] ?? 'Authentication',
                                      style: const TextStyle(fontSize: 20),),
                                  ),
                                  titlePadding: const EdgeInsets.all(10.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  children: <Widget>[

                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: TextFormField(
                                        controller: passwordController,
                                        //maxLength: 100,
                                        //maxLengthEnforced: true,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          //color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: textSettingsPage.strings[language]!['T51'] ?? 'Current password',
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.0,
                                              color: Colors.grey,//grey[200]
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            borderSide: BorderSide(
                                              color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,//deepOrangeAccent[400]
                                            ),
                                          ),
                                          focusedErrorBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              )
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                              borderSide: BorderSide(
                                                width: 1.0,
                                                color: Colors.grey,//grey[500]
                                              )
                                          ),
                                        ),

                                        onChanged: (val) async {
                                          setState(() {
                                            _pass = val;
                                          });
                                        },
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        TextButton(
                                          child: Row(
                                            children: [
                                              Text(textSettingsPage.strings[language]!['T25'] ?? 'Cancel',
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                              const SizedBox(width: 2,),
                                              const Icon(Icons.clear),
                                            ],
                                          ),//'Cancel'
                                          onPressed: () {
                                            passwordController.clear();
                                            Navigator.pop(context0);
                                          },
                                        ),
                                        TextButton(
                                          child: Row(
                                            children: [
                                              Text(textSettingsPage.strings[language]!['T34'] ?? 'Continue',
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                              const SizedBox(width: 2,),
                                              const Icon(Icons.arrow_forward),
                                            ],
                                          ),
                                          onPressed: () async {

                                            /// authenticate
                                            UserCredential? _result;
                                            try {
                                              _result = await _user.reauthenticateWithCredential(EmailAuthProvider.credential(email: _user.email!, password: _pass!));
                                            } catch(e) {
                                              _result = null;
                                            }

                                            _pass = null;
                                            passwordController.clear();

                                            if(_result != null) {
                                              String _newpass = '';
                                              ///
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext context1) => SimpleDialog(
                                                  title: Center(
                                                    child: Text(textSettingsPage.strings[language]!['T52'] ?? 'Change password',
                                                      style: const TextStyle(fontSize: 20),),
                                                  ),
                                                  titlePadding: const EdgeInsets.all(10.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                  ),
                                                  children: <Widget>[

                                                    Form(
                                                      key: _formKey,
                                                      child: Column(
                                                        children: [
                                                          //########### NEW PASSWORD ######
                                                          Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: TextFormField(
                                                              controller: passwordNewController,
                                                              autovalidateMode: AutovalidateMode.always,
                                                              keyboardType: TextInputType.visiblePassword,
                                                              style: const TextStyle(
                                                                fontSize: 18.0,
                                                                //color: Colors.black,
                                                              ),
                                                              validator: (val) {
                                                                if (val!.isNotEmpty) {
                                                                  if (val.length > 7) {
                                                                    return null;//null for validation
                                                                  } else {
                                                                    return textSettingsPage.strings[language]!['T53']
                                                                        ?? 'Password must contain at least 8 characters';
                                                                  }
                                                                } else {
                                                                  return textSettingsPage.strings[language]!['T54'] ?? 'Enter a new password';
                                                                }
                                                              },
                                                              decoration: InputDecoration(
                                                                hintText: textSettingsPage.strings[language]!['T55'] ?? 'New Password',
                                                                border: const OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(8.0),
                                                                  ),
                                                                  borderSide: BorderSide(
                                                                    width: 1.0,
                                                                    color: Colors.grey,//grey[200]
                                                                  ),
                                                                ),
                                                                errorBorder: OutlineInputBorder(
                                                                  borderRadius: const BorderRadius.all(
                                                                    Radius.circular(8.0),
                                                                  ),
                                                                  borderSide: BorderSide(
                                                                    color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,//deepOrangeAccent[400]
                                                                  ),
                                                                ),
                                                                focusedErrorBorder: const OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(8.0),
                                                                    ),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.grey,
                                                                    )
                                                                ),
                                                                focusedBorder: const OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(8.0),
                                                                    ),
                                                                    borderSide: BorderSide(
                                                                      width: 1.0,
                                                                      color: Colors.grey,//grey[500]
                                                                    )
                                                                ),
                                                              ),

                                                              onChanged: (val) async {
                                                                setState(() {
                                                                  _newpass = val;
                                                                });
                                                              },
                                                            ),
                                                          ),

                                                          //########### REPEAT PASSWORD ######
                                                          Padding(
                                                            padding: const EdgeInsets.all(10.0),
                                                            child: TextFormField(
                                                              controller: passwordNewRepController,
                                                              autovalidateMode: AutovalidateMode.always,
                                                              keyboardType: TextInputType.visiblePassword,
                                                              style: const TextStyle(
                                                                fontSize: 18.0,
                                                                //color: Colors.black,
                                                              ),
                                                              validator: (val) {
                                                                if (val == _newpass) {
                                                                  return null;//null for validation
                                                                } else {
                                                                  return textSettingsPage.strings[language]!['T56']
                                                                      ?? 'The passwords do not match';
                                                                }
                                                              },
                                                              decoration: InputDecoration(
                                                                hintText: textSettingsPage.strings[language]!['T57'] ?? 'Repeat Password',
                                                                border: const OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(8.0),
                                                                  ),
                                                                  borderSide: BorderSide(
                                                                    width: 1.0,
                                                                    color: Colors.grey,//grey[200]
                                                                  ),
                                                                ),
                                                                errorBorder: OutlineInputBorder(
                                                                  borderRadius: const BorderRadius.all(
                                                                    Radius.circular(8.0),
                                                                  ),
                                                                  borderSide: BorderSide(
                                                                    color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()]!,//deepOrangeAccent[400]
                                                                  ),
                                                                ),
                                                                focusedErrorBorder: const OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(8.0),
                                                                    ),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.grey,
                                                                    )
                                                                ),
                                                                focusedBorder: const OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                      Radius.circular(8.0),
                                                                    ),
                                                                    borderSide: BorderSide(
                                                                      width: 1.0,
                                                                      color: Colors.grey,//grey[500]
                                                                    )
                                                                ),
                                                              ),

                                                              onChanged: (val) {
                                                                ///
                                                              },
                                                            ),
                                                          ),

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: <Widget>[
                                                              TextButton(
                                                                child: Row(
                                                                  children: [
                                                                    Text(textSettingsPage.strings[language]!['T25'] ?? 'Cancel',
                                                                      style: const TextStyle(fontSize: 18),
                                                                    ),
                                                                    const SizedBox(width: 2,),
                                                                    const Icon(Icons.clear),
                                                                  ],
                                                                ),//'Cancel'
                                                                onPressed: () {
                                                                  passwordNewController.clear();
                                                                  passwordNewRepController.clear();
                                                                  Navigator.pop(context1);
                                                                  Navigator.pop(context0);
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: Row(
                                                                  children: [
                                                                    Text(textSettingsPage.strings[language]!['T66'] ?? 'Confirm',
                                                                      style: const TextStyle(fontSize: 18),
                                                                    ),
                                                                    const SizedBox(width: 2,),
                                                                    const Icon(Icons.check),
                                                                  ],
                                                                ),//'Done'
                                                                onPressed: () async {
                                                                  if (_formKey.currentState!.validate()) {
                                                                    /// -----------------------------
                                                                    bool? _result;
                                                                    String _message;
                                                                    try {
                                                                      await _user.updatePassword(_newpass);
                                                                      _result = true;
                                                                    } catch(e) {
                                                                      _result = null;
                                                                    }
                                                                    if(_result == true) {
                                                                      _message = textSettingsPage.strings[language]!['T58']
                                                                          ?? 'Changed successfully, use your new password the next time you login';
                                                                    } else {
                                                                      _message = textSettingsPage.strings[language]!['T39']
                                                                          ?? 'Could not change, please check internet connection or try again later';
                                                                    }

                                                                    showDialog(
                                                                      barrierDismissible: false,
                                                                      context: context,
                                                                      builder: (BuildContext context2) => SimpleDialog(
                                                                        title: Center(
                                                                          child: Text(textSettingsPage.strings[language]!['T59'] ?? 'Password change',
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
                                                                                textSettingsPage.strings[language]![_message]
                                                                                    ?? _message,
                                                                                style: const TextStyle(fontSize: 20),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          ),

                                                                          TextButton(
                                                                            child: Text(textSettingsPage.strings[language]!['T41'] ?? 'Ok',
                                                                              style: const TextStyle(fontSize: 18),
                                                                            ),//'Cancel'
                                                                            onPressed: () {
                                                                              passwordNewController.clear();
                                                                              passwordNewRepController.clear();
                                                                              Navigator.pop(context2);
                                                                              Navigator.pop(context1);
                                                                              Navigator.pop(context0);

                                                                            },
                                                                          ),

                                                                        ],
                                                                      ),
                                                                    );

                                                                  } else {
                                                                    ///
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              );
                                            } else {
                                              passwordNewController.clear();
                                              passwordNewRepController.clear();

                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (BuildContext context1) => SimpleDialog(
                                                  title: Center(
                                                    child: Text(textSettingsPage.strings[language]!['T42'] ?? 'Error',
                                                      style: const TextStyle(fontSize: 20),),
                                                  ),
                                                  titlePadding: const EdgeInsets.all(10.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0),
                                                  ),
                                                  children: <Widget>[

                                                    Center(
                                                      child: Icon(
                                                        Icons.warning_amber_outlined,
                                                        size: 40,
                                                        color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: Center(
                                                        child: Text(
                                                          textSettingsPage.strings[language]!['T43']
                                                              ?? 'An error occurred in the process. Check if the password you entered is correct or check your internet connection. If you forgot your password, try resetting it',
                                                          style: const TextStyle(fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: <Widget>[
                                                        TextButton(
                                                          child: Row(
                                                            children: [
                                                              Text(textSettingsPage.strings[language]!['T25'] ?? 'Cancel',
                                                                style: const TextStyle(fontSize: 18),
                                                              ),
                                                              const SizedBox(width: 2,),
                                                              const Icon(Icons.clear),
                                                            ],
                                                          ),//'Cancel'
                                                          onPressed: () {
                                                            Navigator.pop(context1);
                                                            Navigator.pop(context0);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Row(
                                                            children: [
                                                              Text(textSettingsPage.strings[language]!['T44'] ?? 'Retry',
                                                                style: const TextStyle(fontSize: 18),
                                                              ),
                                                              const SizedBox(width: 2,),
                                                              const Icon(Icons.arrow_back),
                                                            ],
                                                          ),//'Done'
                                                          onPressed: () {
                                                            Navigator.pop(context1);
                                                          },
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              );

                              /// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            Divider(
              color: Colors.grey[700],
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),

            //---------------- LANGUAGE ------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(textSettingsPage.strings[language]!['T18'] ?? 'Language: ',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),

                  DropdownButton<String>(
                    value: selectedLanguage,
                    icon: Icon(Icons.keyboard_arrow_left, color: Colors.grey[600],),
                    iconSize: 18,
                    elevation: 0,
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(
                      color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                      fontSize: 18,
                    ),
                    underline: Container(
                      height: 2,
                      color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLanguage = newValue;
                        //userSettings.language = languageNames[selectedLanguage];
                        language = languageNames[selectedLanguage];
                        _reassignColorNames();
                      });
                    },
                    items: chartLanguages
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),

                  Icon(Icons.translate, size: 30, color: Colors.grey[700]),
                ],
              ),
            ),

            Divider(
              color: Colors.grey[700],
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),

            //---------------- VISUALS ------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Text(textSettingsPage.strings[language]!['T19'] ?? 'Set to default',
                      style: TextStyle(
                        color: Colors.deepOrangeAccent[400],
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _sliderColor = 2;
                        userSettings.colorNum = _sliderColor.round().toString();
                        _sliderShade = 1200;
                        userSettings.shadeNum = _sliderShade.round().toString();
                      });
                    },
                  ),
                  Icon(
                    Icons.palette,
                    size: 30,
                    color: Colors.grey[700],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text(textSettingsPage.strings[language]!['T20'] ?? 'Color: ',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  Text('${colorName[_sliderColor.round().toString()]}',
                    style: TextStyle(
                      color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              activeColor: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
              value: _sliderColor,
              min: 0,
              max: 16,
              divisions: 16,
              label: colorName[_sliderColor.round().toString()],
              onChanged: (double value) {
                setState(() {
                  _sliderColor = value;
                  userSettings.colorNum = _sliderColor.round().toString();
                });
              },
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text(textSettingsPage.strings[language]!['T21'] ?? 'Shade: ',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  Text(_sliderShade.round().toString(),
                    style: TextStyle(
                      color: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              activeColor: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()],
              value: _sliderShade,
              min: 100,
              max: 1300,
              divisions: 12,
              label: _sliderShade.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _sliderShade = value;
                  userSettings.shadeNum = _sliderShade.round().toString();
                });
              },
            ),

            Divider(
              color: Colors.grey[700],
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),

            //------------- SAVE BUTTON ----------------
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  //minimumSize: Size(88, 36),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  foregroundColor: ColorsMap().colors[_sliderColor.round().toString()]![_sliderShade.round().toString()], // foreground
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(textSettingsPage.strings[language]!['T22'] ?? 'Apply',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 20,
                    ),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isUploading = true;
                  });
                  //userSettings.language = languageNames[selectedLanguage];
                  await _upload();
                  DataHolder.of(widget.cont)?.refreshSettings();
                  Navigator.pop(context);
                  /*setState(() {
                    _isUploading = false;
                  });*/
                },
              ),
            ),

            Divider(
              color: Colors.grey[700],
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),

            const SizedBox(height: 20,),

            //------------- about APP ----------------
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Text(textSettingsPage.strings[language]!['T60'] ?? 'About App',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      ///

                      getAboutApp = getInfo();
                      //showAboutDialog(context: context);
                      //showLicensePage(context: context);


                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext context0) => SimpleDialog(
                          title: Center(
                            child: Text(textSettingsPage.strings[language]!['T60'] ?? 'About App',
                              style: const TextStyle(fontSize: 20),),
                          ),
                          titlePadding: const EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          children: <Widget>[

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  FutureBuilder(
                                      future: getAboutApp,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          snapshotData = snapshot.data;
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              //******** App Name ********
                                              Text(snapshotData.appName ?? 'Signmi App',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.deepOrangeAccent[400],
                                                ),
                                              ),
                                              const SizedBox(height: 20,),

                                              //******** Version ********
                                              Row(
                                                children: [
                                                  Text(textSettingsPage.strings[language]!['T61'] ?? 'version: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  Text(snapshotData.version ?? 'no data',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10,),
                                              //******** Build ********
                                              Row(
                                                children: [
                                                  Text(textSettingsPage.strings[language]!['T62'] ?? 'build: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  Text(snapshotData.buildNumber ?? 'no data',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          return SpinKitDualRing(
                                            size: 40,
                                            color: Colors.deepOrangeAccent[400]!,
                                          );
                                        }
                                        //return null;
                                      }
                                  ),
                                  const SizedBox(height: 20,),

                                  InkWell(
                                    child: Text(textSettingsPage.strings[language]!['T63'] ?? 'Privacy policy',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pushReplacementNamed('/terms',
                                          arguments: RouteArguments(
                                            link: language,
                                            cont: mainContext,
                                            //cont: context,
                                          )
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20,),

                                  InkWell(
                                    child: Text(textSettingsPage.strings[language]!['T64'] ?? 'Licenses',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    onTap: () {
                                      showLicensePage(context: context);
                                    },
                                  ),
                                  const SizedBox(height: 20,),

                                  Center(
                                    child: TextButton(
                                      child: Text(textSettingsPage.strings[language]!['T65'] ?? 'Close',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),

                                ],
                              ),
                            ),

                          ],
                        ),
                      );



                    },
                  ),
                  const SizedBox(width: 5,),
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[400]),
                ],
              ),
            ),

            //------------- SIGN OUT BUTTON ----------------
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(textSettingsPage.strings[language]!['T23'] ?? 'Sign out',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),

                  IconButton(
                    icon: const Icon(Icons.exit_to_app, size: 20, color: Colors.white),
                    onPressed: () async {
                      // TODO SHOW DIALOG==================!
                      await _auth.signOutFunction();
                      Navigator.pop(context);
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<PackageInfo> getInfo() async {
  return await PackageInfo.fromPlatform();
}