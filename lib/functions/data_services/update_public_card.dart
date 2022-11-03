//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//                           Update Public Card
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//method to get Public Card
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/public_card.dart';
import 'generate_link.dart';

Future<String?> updatePublicCard(String _uid, String _cid, PublicCard _card, File _imgPick, String _link) async {
  var _isNew = false;
  var _listOwn = [];
  //var _link = '';

  try {
    //If _cid empty need to create new DocumentReference first
    if(_cid.isEmpty) {
      _isNew = true;
      DocumentReference _docRef = FirebaseFirestore.instance.collection('public_cards').doc();
      _cid = _docRef.id.toString();
      //and add this card to the list of own short cards
      var snapshot = await FirebaseFirestore.instance.collection('short_cards_own').doc(_uid).get();
      if(snapshot.data()!['list'] != null) {
        _listOwn = snapshot.data()!['list'].cast<String>();
      }
      _listOwn.add(_cid);
    }
    //
    if(_imgPick != null) {
      //compress image stage
      Directory _tempDir = await getTemporaryDirectory();
      String _tempPath = '${_tempDir.path}/${Random().nextInt(100000000)}.jpg';// prone to error
      //TODO: check the possibility of deleting temp file, if needed
      var _result = await FlutterImageCompress.compressAndGetFile(
        _imgPick.path, _tempPath,
        quality: 80,
        minWidth: 800,
        minHeight: 800,
      );

      //Upload image stage
      //var myPath = 'card_images/$_cid.jpg';
      var myPath = 'card_images/$_uid/$_cid.jpg';
      UploadTask _myTask;
      Reference _myStorage = FirebaseStorage.instance.ref('gs://dejitarumeishiapp.appspot.com');
      _myTask = _myStorage.child(myPath).putFile(_result!);
      await _myTask;
      var _url = await _myStorage.child(myPath).getDownloadURL();
      _card.imgUrl = _url;
    }

    //Generate link with cid
    if(_card.private == false) {
      if(_isNew || _link == null || _link.isEmpty) {
        var _key = 'public_cards_keyless';
        _link = await generateLink(_cid, _key, _uid, _card.globalTitle, _card.author, _card.imgUrl);
      }
    } else {
      _link = '';
    }

    //Upload card's data() to Firebase
    await FirebaseFirestore.instance.collection('public_cards')
        .doc(_cid)
        .set({
      'owner': _card.owner is String ? _card.owner : _card.owner.toString(),
      'author': _card.author is String ? _card.author : _card.author.toString(),
      'cid': _cid,
      //'link': _link,
      'globalTitle': _card.globalTitle is String ? _card.globalTitle : _card.globalTitle.toString(),
      'imgUrl': _card.imgUrl is String ? _card.imgUrl : _card.imgUrl.toString(),
      'fields': _card.fields is List ? _card.fields : [],
      'private': _card.private is bool ? _card.private : false,
      'lastEdit': _card.lastEdit is int ? _card.lastEdit : DateTime.now().millisecondsSinceEpoch,
      'origin': _card.origin is int ? _card.origin : DateTime.now().millisecondsSinceEpoch,
    });
    //update own list of short cards
    if(_isNew) {
      await FirebaseFirestore.instance.collection('short_cards_own').doc(_uid).update({
        "list": _listOwn,
      });
    }
    //all done
    return _cid;
  } catch(e) {
    //print('UNABLE TO UPLOAD CARD\'S DATA: $e');
    return null;
  }
}