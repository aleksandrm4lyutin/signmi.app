
//function for loading user's settings from firestore
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../models/user_settings.dart';
import '../../shared/colors_map.dart';

Future<UserSettings?> getUserSettings(String uid, BuildContext cont) async {
  try {
    var snapshot = await FirebaseFirestore.instance.collection('user_profiles').doc(uid).get();
    print('!@#!@#!@#!@#!@#!@#!@# uid: ${snapshot.data()}');
    if (snapshot.data() != null) {
      return UserSettings(
        name: snapshot.data()!['name'] ?? '',
        photoUrl: snapshot.data()!['photoUrl'] ?? '',
        about: snapshot.data()!['about'] ?? '',
        language: snapshot.data()!['language'] ?? 'english',
        color: ColorsMap().colors[snapshot.data()!['colorNum']]![snapshot.data()!['shadeNum']]!,
        colorNum: snapshot.data()!['colorNum'] ?? '2',
        shadeNum: snapshot.data()!['shadeNum'] ?? '1200',
      );
    } else {

      var locale = Localizations.localeOf(cont).languageCode;
      var language;
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
        default: language = 'english';
      }

      return UserSettings(
        name: '',
        photoUrl: '',
        about: '',
        language: language,
        color: ColorsMap().colors['2']!['1200']!,
        colorNum: '2',
        shadeNum: '1200',
      );
    }
  } catch(e) {
    print('90909!!!error: $e');
    //TODO: some error occurred during process, RETRY MAYBE?
    //throw Future.error('error');
    return null;
  }
}