//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//                  Get Public Card
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

//method to get Public Card
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/public_card.dart';

Future<PublicCard?> getPublicCard(String uid, String cid, bool own) async {
  try {

    if(own != true) {
      var path = '$cid??$uid';
      var pass;
      pass = await FirebaseFirestore.instance.collection('blacklists').doc(path).get();
      if(pass?.data() != null) {
        //if card couldn't be accessed due to user being blacklisted then return empty PublicCard with keyword 'denied' witch will block access
        return PublicCard(
          owner: 'denied',
          globalTitle: 'denied',
          cid: cid,
          //TODO this part is temp, to DELETE
          author: '',
          imgUrl: '',
          private: false,
          fields: [],
          lastEdit: 0,
          origin: 0,
        );
      } else {
        var snapshot;
        try {
          snapshot = await FirebaseFirestore.instance.collection('public_cards').doc(cid).get();
        } catch(e) {
          // if (e.code == 'permission-denied') {
          //   snapshot = null;
          // } else {
          //   //print('70707ZZZerror: $e');
          //   return null;
          // }
          return null;
        }

        if (snapshot?.data() != null) {
          return PublicCard(
            owner: snapshot.data()['owner'],
            author: snapshot.data()['author'],
            cid: cid,
            //link: _link,
            globalTitle: snapshot.data()['globalTitle'],
            imgUrl: snapshot.data()['imgUrl'],
            private: snapshot.data()['private'],
            fields: snapshot.data()['fields'].cast<Map>(),
            lastEdit: snapshot.data()['lastEdit'],
            origin: snapshot.data()['origin'],
            //
          );
        } else {
          //if card couldn't be accessed then return empty PublicCard with keyword 'delete' witch will trigger deletion
          return PublicCard(
            owner: 'delete',
            globalTitle: 'delete',
            cid: cid,
            //TODO this part is temp, to DELETE
            author: '',
            imgUrl: '',
            private: false,
            fields: [],
            lastEdit: 0,
            origin: 0,
          );
          //return null;
        }
      }
    } else {
      var snapshot;
      snapshot = await FirebaseFirestore.instance.collection('public_cards').doc(cid).get();
      if (snapshot?.data() != null) {
        return PublicCard(
          owner: snapshot.data()['owner'],
          author: snapshot.data()['author'],
          cid: cid,
          //link: _link,
          globalTitle: snapshot.data()['globalTitle'],
          imgUrl: snapshot.data()['imgUrl'],
          private: snapshot.data()['private'],
          fields: snapshot.data()['fields'].cast<Map>(),
          lastEdit: snapshot.data()['lastEdit'],
          origin: snapshot.data()['origin'],
          //
        );
      } else {
        return null;
      }
    }
    //

  } catch(e) {
    //print('70707error: $e');
    return null;
  }
}