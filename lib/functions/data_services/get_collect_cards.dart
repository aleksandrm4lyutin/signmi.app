//function for loading collection from firestore
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../models/short_card_collect.dart';
import 'generate_link.dart';

Future<List<ShortCardCollect>?> getCollectCards(String uid) async {
  try {
    var snapshot = await FirebaseFirestore.instance.collection('short_cards_collection').doc(uid).get();

    if (snapshot.data() != null) {
      //get list of cid from snapshot
      var _l = snapshot.data()!['list'].cast<String>() ?? [];
      if(_l != null) {
        if(_l.isNotEmpty) {
          //check if user have access to cards in the list
          /*List<String> _l1 = [];//list to preserve
            List<String> _l2 = [];//list to delete
            for(var i = 0; i < _l.length; i++) {
              var _h = await FirebaseFirestore.instance.collection('card_holders').doc(_l[i]).get();
              if(_h.data()['$uid'] == true) {
                _l1.add(_l[i]);
              } else if(_h.data()['$uid'] == false){
                _l2.add(_l[i]);
              }
            }*/
          //return checked list
          //_l=_l1;
          //now update the list at DB
          /*await FirebaseFirestore.instance.collection('short_cards_collection').doc(uid).update({
              'list': _l,
            });*/
          //check if list _l2 has any values after checking
          /*if(_l2.isNotEmpty) {
              //and delete all restricted fields
              //print('_L2 is: $_l2');
              for(var i = 0; i < _l2.length; i++) {
                String _del = _l2[i];
                //print('ATTEMPTING TO DELETE FIELD: uid: $uid , cid: $_del');
                await FirebaseFirestore.instance.collection('short_cards_collection').doc(uid).update({
                  "$_del": FieldValue.delete()
                });
              }
            }*/
          //now ready to retrieve the objects
          //TODO: INVESTIGATE THIS
          //Update data()
          List<String> _l0 = [];
          Map<String, dynamic> _m = {};
          bool _u;
          for(var i = 0; i < _l.length; i++) {
            var _cid = _l[i];
            var snapshot0;
            if(snapshot.data()![_cid]['private'] == false) {
              try {
                var _s = await FirebaseFirestore.instance.collection('public_cards').doc(_cid).get();
                snapshot0 = _s.data();
              } catch(e) {
                // if (e.code == 'permission-denied') {
                //   snapshot0 = null;
                // } else {
                //   print('30303ZZZerror $e');
                //   return null;
                // }
                snapshot0 = null;
                return null;
              }
            } else {
              final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('loadPublicCard');
              var _s = await callable.call({'cid': _cid});
              snapshot0 = _s.data;
            }
            ///snapshot0.data()
            if (snapshot0 != null) {
              //check if card is being updated
              if(snapshot.data()![_cid] != null) {
                if((snapshot0['lastEdit'] ?? 1) > (snapshot.data()![_cid]['lastEdit'] ?? 1)) {
                  _u = true;
                } else {
                  _u = snapshot.data()![_cid]['updated'] ?? false;
                }
              } else {
                _u = true;
              }
              var _link;
              var _key;
              if(snapshot0['private'] == false) {
                _key = 'public_cards_keyless';
                if(snapshot.data()![_cid] != null) {
                  if(snapshot.data()![_cid]['link'] != null && snapshot.data()![_cid]['link'].isNotEmpty) {
                    _link = snapshot.data()![_cid]['link'];
                  } else {
                    _link = await generateLink(_cid, _key, uid, snapshot0['globalTitle'], snapshot0['author'], snapshot0['imgUrl']);
                  }
                } else {
                  _link = await generateLink(_cid, _key, uid, snapshot0['globalTitle'], snapshot0['author'], snapshot0['imgUrl']);
                }
              } else {
                _link = '';
              }
              _l0.add(_cid);
              _m[_cid] = {
                'author': snapshot0['author'],
                'cid': _cid,
                'link': _link,
                'globalTitle': snapshot0['globalTitle'],
                'imgUrl': snapshot0['imgUrl'],
                'lastEdit': snapshot0['lastEdit'],
                'private': snapshot0['private'],
                'updated': _u,//_u
              };
            }
          }
          _m['list'] = _l0;
          _l = _l0;
          await FirebaseFirestore.instance.collection('short_cards_collection').doc(uid).update(_m);
          //iterate through _l and map each 'cid' from snapshot to _list as ShortCardOwn
          List<ShortCardCollect> _list = _l.map((cid) {
            return _m[cid];
            //return snapshot.data()[cid];
          }).toList().map((field) {
            return ShortCardCollect(
              cid: field['cid'],
              link: field['link'],
              author: field['author'],
              globalTitle: field['globalTitle'],
              imgUrl: field['imgUrl'],
              lastEdit: field['lastEdit'],
              private: field['private'],
              updated: field['updated'],
              selected: false,///this value is local use only
            );
          }).toList().cast<ShortCardCollect>();
          return _list.reversed.toList();//return reversed list
        } else {
          //list is empty, return empty list
          return <ShortCardCollect>[];
        }
      } else {
        await FirebaseFirestore.instance.collection('short_cards_collection').doc(uid).set({ 'list': <String>[] });
        return <ShortCardCollect>[];
      }
    } else {
      await FirebaseFirestore.instance.collection('short_cards_collection').doc(uid).set({ 'list': <String>[] });
      return <ShortCardCollect>[];
    }
  } catch(e) {
    //print('30303error: $e');
    //TODO: some error occurred during process, RETRY MAYBE?
    //throw Future.error('error');
    return null;
  }
}