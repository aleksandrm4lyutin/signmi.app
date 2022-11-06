import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/card_model.dart';
import '../shared/max_numbers.dart';
import '../texts/text_adding_card.dart';
import 'data_holder.dart';
import 'loading_page.dart';


class AddingCard extends StatefulWidget {
  final String uid;
  final String source;//here it carries source
  final String cid;
  final String link;//here it carries key
  final BuildContext cont;
  final int collectCardNum;//how many cards in collection

  const AddingCard({Key? key,
    required this.uid,
    required this.source,
    required this.cid,
    required this.link,
    required this.cont,
    required this.collectCardNum
  }) : super(key: key);

  @override
  _AddingCardState createState() => _AddingCardState();
}

class _AddingCardState extends State<AddingCard> {

  String _cid = '';
  String _key = '';
  String _source = '';

  bool _exceedCollection = false;

  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';//TODO
  TextAddingCard textAddingCard = TextAddingCard();

  final int _maxCollect = MaxNumbers().maxCollect;//max number of collect cards

  dynamic snapshotData;

  @override
  void initState() {
    super.initState();

    _cid = widget.cid;
    _key = widget.link;
    _source = widget.source;

    //check collection length and add if less then max
    if(widget.collectCardNum < _maxCollect) {
      _exceedCollection = false;
      _transaction = approveTransaction(_cid, _key, _source, widget.uid);
    } else {
      _exceedCollection = true;
    }

    language = DataHolder.of(widget.cont)?.userSettings.language ?? 'english';
    highlightColor = DataHolder.of(widget.cont)?.userSettings.color ?? Colors.deepOrangeAccent[700];
  }

  late Future<dynamic> _transaction;

  //TODO: this function must be at homepage main in awaiting approval section
  Future<List<String>> readOfflineTransactions() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/offline_transactions.txt');
      String contents = await file.readAsString();
      final list = contents.split('/');
      return list;
    } catch(e) {
      return [];
    }
  }
  //add new request data to list of offline pending requests
  Future<bool> writeOfflineTransactions(String _data) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/offline_transactions.txt');
    String contents = await file.readAsString();
    contents = contents +'/'+ _data;
    file.writeAsString(contents);
    /*List<String> list;
    list = contents.split('/');
    list.add(_data);
    contents = list.join('/');*/
    return true;
  }


  @override
  Widget build(BuildContext context) {

    return _exceedCollection != false ? Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.report_problem, color: highlightColor, size: 100,),
              const SizedBox(height: 10,),
              Wrap(
                children: <Widget>[
                  Text(textAddingCard.strings[language]!['T02'] ?? 'Could not add card',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Wrap(
                children: <Widget>[
                  Text('${textAddingCard.strings[language]!['T07']}$_maxCollect',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Center(
                child: TextButton(
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.arrow_back, color: Colors.white, size: 25,),
                      Text(textAddingCard.strings[language]!['T04'] ?? 'Back',
                        style: const TextStyle(fontSize: 25, color: Colors.white),
                      ),//'Return'
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ) : FutureBuilder(
        future: _transaction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              snapshotData = snapshot.data;
              return Scaffold(
                backgroundColor: Colors.grey[900],
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    CardModel(
                      color: highlightColor,
                      image: snapshotData.data['imgUrl'],
                      title: snapshotData.data['globalTitle'],
                      subtitle: snapshotData.data['author'],
                      icon: snapshotData.data['private'] ? Icon(
                        Icons.lock, color: Colors.grey[600],
                      ) : Icon(
                        Icons.share, color: Colors.grey[600],
                      ),
                      onTapIcon: null,
                      dark: false,
                      onTapImage: null,
                      updated: false,
                      privateIcon: false,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              Text(textAddingCard.strings[language]!['T00'] ?? 'Card successfully added',//'Could not retrieve data'
                                style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),

                          Icon(Icons.check_circle_outline, color: highlightColor, size: 100,),
                          const SizedBox(height: 10,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              TextButton(
                                child: Row(
                                  children: <Widget>[
                                    const Icon(Icons.arrow_back, color: Colors.white, size: 25,),
                                    Text(textAddingCard.strings[language]!['T01'] ?? 'Ok',
                                      style: const TextStyle(fontSize: 25, color: Colors.white),
                                    ),//'Return'
                                  ],
                                ),
                                onPressed: () async {
                                  //TODO: untested!!!!
                                  await DataHolder.of(widget.cont)?.refreshCollect();
                                  setState(() {
                                    //DataHolder.of(widget.cont).refreshCollect();
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: Colors.grey[900],
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.report_problem, color: highlightColor, size: 100,),
                        const SizedBox(height: 10,),
                        Wrap(
                          children: <Widget>[
                            Text(textAddingCard.strings[language]!['T02'] ?? 'Could not add card',//'Could not retrieve data'
                              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Wrap(
                          children: <Widget>[
                            Text(textAddingCard.strings[language]!['T03']
                                ?? 'Please check internet connection or try again later',//'Please, make sure your device have internet connection or try again later'
                              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            TextButton(
                              child: Row(
                                children: <Widget>[
                                  const Icon(Icons.arrow_back, color: Colors.white, size: 25,),
                                  Text(textAddingCard.strings[language]!['T04'] ?? 'Back',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),//'Return'
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Row(
                                children: <Widget>[
                                  Text(textAddingCard.strings[language]!['T05'] ?? 'Retry',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),
                                  const Icon(Icons.refresh, color: Colors.white, size: 25,),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  _transaction = approveTransaction(_cid, _key, _source, widget.uid);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              child: Row(
                                children: <Widget>[
                                  const Icon(Icons.arrow_back, color: Colors.white, size: 25,),
                                  Text(textAddingCard.strings[language]!['T06'] ?? 'Save',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),//'Return'
                                ],
                              ),
                              onPressed: () async {
                                var _data = _cid+'/'+_key+'/'+_source;
                                await writeOfflineTransactions(_data);
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return Loading(color: highlightColor!);
          }
        }
    );
  }
}

Future<dynamic> approveTransaction(String _cid, String _key, String _source, String _uid) async {

  var connectivityResult = await (Connectivity().checkConnectivity());
  if(connectivityResult != ConnectivityResult.none) {
    var _path = '$_cid??$_uid';
    var _pass = await FirebaseFirestore.instance.collection('blacklists').doc(_path).get();
    if(_pass.data() != null) {
      throw Future.error('error: access denied');
    } else {
      try {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'approveTransaction',
        );
        String date = '${(DateTime.now().year - 2000).toString()}/${DateTime.now().month.toString()}/${DateTime.now().day.toString()}';
        return await callable.call({
          'cid': _cid,
          'key': _key,
          'source': _source,
          'day': DateTime.now().day.toString(),
          'month': DateTime.now().month.toString(),
          'year': DateTime.now().year.toString(),
          'date': date,
        });
      } catch (e) {
        throw Future.error('error: $e');
      }
    }
  } else {
    throw Future.error('error: no internet connection');
  }

}