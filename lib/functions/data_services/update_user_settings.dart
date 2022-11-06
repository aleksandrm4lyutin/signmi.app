//#####################################################################
//                     Update Settings
//#####################################################################
//function for updating user's settings
//
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/user_settings.dart';

Future<bool> updateUserSettings(String uid, UserSettings userSettings, File? imgPick) async {

  if(imgPick != null) {
    //compress image stage
    Directory _tempDir = await getTemporaryDirectory();
    String _tempPath = '${_tempDir.path}/${Random().nextInt(100000000)}.jpg';// prone to error
    //TODO: check the possibility of deleting temp file, if needed
    var _result = await FlutterImageCompress.compressAndGetFile(
      imgPick.path, _tempPath,
      quality: 80,
      minWidth: 800,
      minHeight: 800,
    );

    //Upload image stage
    var myPath = 'profile_photos/$uid/$uid.jpg';
    UploadTask _myTask;
    Reference _myStorage = FirebaseStorage.instance.ref('gs://dejitarumeishiapp.appspot.com');
    _myTask = _myStorage.child(myPath).putFile(_result!);
    await _myTask;
    var _url = await _myStorage.child(myPath).getDownloadURL();
    userSettings.photoUrl = _url;

  }

  try {
    await FirebaseFirestore.instance.collection('user_profiles').doc(uid).set({
      'name': userSettings.name,
      'photoUrl': userSettings.photoUrl,
      'about': userSettings.about,
      'language': userSettings.language,
      'colorNum': userSettings.colorNum,
      'shadeNum': userSettings.shadeNum,
    }, SetOptions(merge: true));
    return true;
  } catch(e) {
    //print('11011011error: $e');
    //TODO: some error occurred during process, RETRY MAYBE?
    //throw Future.error('error');
    return false;
  }
}