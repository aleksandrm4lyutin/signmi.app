import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/short_card_own.dart';
import 'generate_link.dart';


//function for loading user's cards from firestore
//
Future<List<ShortCardOwn>?> getUserCards(String uid) async {
  try {
    var snapshot = await FirebaseFirestore.instance.collection('short_cards_own').doc(uid).get();

    if (snapshot.data() != null) {
      //get list of cid from snapshot
      var _l = snapshot.data()!['list'].cast<String>() ?? [];
      if(_l != null) {
        if(_l.isNotEmpty) {
          //Update data
          List<String> _l0 = [];
          Map<String, dynamic> _m = {};

          for(var i = 0; i < _l.length; i++) {
            var _cid = _l[i];
            var snapshot0 = await FirebaseFirestore.instance.collection('public_cards').doc(_cid).get();

            if (snapshot0.data() != null) {
              var _link;
              if((snapshot0.data()!['private']) == false) {
                var _key = 'public_cards_keyless';
                if(snapshot.data()![_cid] != null) {
                  if(snapshot.data()![_cid]['link'] != null && snapshot.data()![_cid]['link'].isNotEmpty) {
                    _link = snapshot.data()![_cid]['link'];
                  } else {
                    _link = await generateLink(_cid, _key, uid, snapshot0.data()!['globalTitle'], snapshot0.data()!['author'], snapshot0.data()!['imgUrl']);
                  }
                } else {
                  _link = await generateLink(_cid, _key, uid, snapshot0.data()!['globalTitle'], snapshot0.data()!['author'], snapshot0.data()!['imgUrl']);
                }
              } else {
                _link = '';
              }

              _l0.add(_cid);
              _m[_cid] = {
                'cid': _cid,
                'link': _link,
                'globalTitle': snapshot0.data()!['globalTitle'],
                'author': snapshot0.data()!['author'],
                'imgUrl': snapshot0.data()!['imgUrl'],
                'private': snapshot0.data()!['private'],
                'origin': snapshot0.data()!['origin'],
              };
            }
          }
          _m['list'] = _l0;
          _l = _l0;
          await FirebaseFirestore.instance.collection('short_cards_own').doc(uid).set(_m);
          //iterate through _l and map each 'cid' from snapshot to _list as ShortCardOwn
          List<ShortCardOwn> _list = _l.map((cid) {
            //return snapshot.data()[cid];
            return _m[cid];
          }).toList().map((field) {
            return ShortCardOwn(
              cid: field['cid'],
              link: field['link'],
              globalTitle: field['globalTitle'],
              author: field['author'],
              imgUrl: field['imgUrl'],
              private: field['private'],
              origin: field['origin'],
            );
          }).toList().cast<ShortCardOwn>();
          return _list;
        } else {
          return <ShortCardOwn>[];
        }
      } else {
        await FirebaseFirestore.instance.collection('short_cards_own').doc(uid).set({ 'list': <String>[] });
        return <ShortCardOwn>[];
      }
    } else {
      await FirebaseFirestore.instance.collection('short_cards_own').doc(uid).set({ 'list': <String>[] });
      return <ShortCardOwn>[];
    }
  } catch(e) {
    print('40404error: $e');
    //TODO: some error occurred during process, RETRY MAYBE?
    //throw Future.error('error');
    return null;
  }
}