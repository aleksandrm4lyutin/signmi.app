//#####################################################################
//                     Update Single Collect Card
//#####################################################################
//function for loading collection from firestore
//
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/public_card.dart';

Future<bool> updateSingleCollectCard(String _uid, PublicCard _card, String _link) async {
  try {
    await FirebaseFirestore.instance.collection('short_cards_collection').doc(_uid).update({
      _card.cid: {
        'author': _card.author,
        'cid': _card.cid,
        'link': _link,
        'globalTitle': _card.globalTitle,
        'imgUrl': _card.imgUrl,
        'lastEdit': _card.lastEdit,//TODO delete from collect card model?
        'updated': false,
        'private': _card.private,
      },
    });
    return true;
  } catch(e) {
    //print('ERROR UPDATING COLLECTION CARDS LIST: $e');
    return false;
  }
}