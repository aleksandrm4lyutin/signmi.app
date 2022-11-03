//**********************************************************************
//                      Delete Public Card
//**********************************************************************
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<bool> deletePublicCard(String _uid, String _cid, String _imgUrl) async {
  //TODO check internet connection

  try {

    await FirebaseFirestore.instance.collection('public_cards').doc(_cid).delete();

    if(_imgUrl.isNotEmpty && _imgUrl != null) {
      var myPath = 'card_images/$_cid.jpg';

      FirebaseStorage.instance.ref('gs://dejitarumeishiapp.appspot.com').child(myPath).delete();
    }


    var snapshot = await FirebaseFirestore.instance.collection('short_cards_own').doc(_uid).get();

    var _listOwn = snapshot.data()!['list'].cast<String>();

    _listOwn.removeWhere((c) => c == _cid);

    await FirebaseFirestore.instance.collection('short_cards_own').doc(_uid).update({
      "list": _listOwn,
    });

    await FirebaseFirestore.instance.collection('short_cards_own').doc(_uid).update({
      _cid: FieldValue.delete()
    });

    //all done
    return true;
  } catch(e) {

    return false;
  }
}
//