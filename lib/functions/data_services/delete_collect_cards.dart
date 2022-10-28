//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//                      Delete Collect Cards
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> deleteCollectCards(String _uid, List<String> _toDelete, List<String> _toKeep) async {
  try {
    if(_toDelete.isNotEmpty) {
      //and delete all selected cards
      //Old
      /*for(var i = 0; i < _toDelete.length; i++) {
          //TODO: MAKE IT BATCH WRITE?
          String _del = _toDelete[i];
          await FirebaseFirestore.instance.collection('short_cards_collection').doc(_uid).update({
            "$_del": FieldValue.delete()
          });
        }*/
      Map<String, dynamic> _m = {};
      for(var i = 0; i < _toDelete.length; i++) {
        _m[_toDelete[i]] = FieldValue.delete();
      }
      _m['list'] = _toKeep;
      await FirebaseFirestore.instance.collection('short_cards_collection').doc(_uid).update(_m);
    }
    return true;
  } catch(e) {
    //print('ERROR DELETING COLLECTION CARDS LIST: $e');
    return false;
  }
}