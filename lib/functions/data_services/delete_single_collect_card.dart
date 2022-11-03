//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//                      Delete Single Collect Cards
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> deleteSingleCollectCard(String _uid, String _cid) async {
  try {

    var _snapshot = await FirebaseFirestore.instance.collection('short_cards_collection').doc(_uid).get();
    var _list = _snapshot.data()?['list'].cast<String>();
    _list.removeWhere((item) => item == _cid);
    Map<String, dynamic> _map = {};
    _map[_cid] = FieldValue.delete();
    _map['list'] = _list;
    await FirebaseFirestore.instance.collection('short_cards_collection').doc(_uid).update(_map);

    return true;
  } catch(e) {
    //print('ERROR DELETING COLLECTION CARDS LIST: $e');
    return false;
  }
}