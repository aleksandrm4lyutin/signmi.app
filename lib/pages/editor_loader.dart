import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../functions/data_services/get_public_card.dart';
import '../models/public_card.dart';
import '../texts/text_editor_loader.dart';
import 'data_holder.dart';
import 'editor.dart';
import 'loading_page.dart';


class EditorLoader extends StatefulWidget {

  final String uid;
  final String cid;
  final String link;
  final BuildContext cont;
  final Color colorE;
  final String languageE;
  final PublicCard cardE;

  const EditorLoader({Key? key,
    required this.uid,
    required this.cid,
    required this.cont,
    required this.link,
    required this.colorE,
    required this.languageE,
    required this.cardE
  }) : super(key: key);

  @override
  _EditorLoaderState createState() => _EditorLoaderState();
}

class _EditorLoaderState extends State<EditorLoader> {

  late Future<PublicCard?> _card;

  Color highlightColor = Colors.deepOrangeAccent[700]!;
  String language = 'english';//TODO
  TextEditorLoader textEditorLoader = TextEditorLoader();

  @override
  void initState() {
    super.initState();

    if(widget.colorE != null) {
      highlightColor = widget.colorE;
    } else {
      highlightColor = DataHolder.of(widget.cont)!.userSettings.color;
    }
    if(widget.languageE != null) {
      language = widget.languageE;
    } else {
      language = DataHolder.of(widget.cont)!.userSettings.language;
    }

    if(widget.cardE != null) {
      _card = Future.value(widget.cardE);
    } else {
      if(widget.cid.isNotEmpty) {
        _card = loadCard(widget.uid, widget.cid);
      } else {
        _card = newCard(widget.uid, language);
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: _card,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //print('${snapshot.data}');
            if(snapshot.data != null) {
              ////////////////////////////////////////////////////////
              return Editor(
                uid: widget.uid,// TODO: REPLACE ALL!! UID PASSED AS PARAM TO AUTH.USER.UID!!
                card: snapshot.data as PublicCard,
                link: widget.link,
                cont: widget.cont,
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
                        Icon(Icons.report_problem, color: highlightColor, size: 50,),
                        const SizedBox(height: 10,),
                        Wrap(
                          children: <Widget>[
                            Text(textEditorLoader.strings[language]!['T00'] ?? 'Could not load the data',
                              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Wrap(
                          children: <Widget>[
                            Text(textEditorLoader.strings[language]!['T01']
                                ?? 'Please check internet connection or try again later',
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
                                  Text(textEditorLoader.strings[language]!['T02'] ?? 'Back',
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
                                  Text(textEditorLoader.strings[language]!['T03'] ?? 'Retry',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),//'Retry'
                                  const Icon(Icons.refresh, color: Colors.white, size: 25,),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  _card = loadCard(widget.uid, widget.cid);
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
            return Loading(color: highlightColor);
          }
        }
    );
  }
}

Future<PublicCard?> loadCard(String uid, String cid) async {
  //
  var connectivityResult = await (Connectivity().checkConnectivity());

  if(connectivityResult != ConnectivityResult.none) {
    try {
      return await getPublicCard(uid, cid, true);
    } catch(e) {
      throw Future.error('error');
    }
  } else {
    throw Future.error('error');
  }
}

Future<PublicCard> newCard(String uid, String language) async {
  return PublicCard(
    owner: uid,
    cid: '',
    author: TextEditorLoader().strings[language]!['T04'] ?? 'Signature',//TODO: import user name
    globalTitle: TextEditorLoader().strings[language]!['T05'] ?? 'New card',//TODO: Change
    imgUrl: '',
    private: false,
    fields: [],
    //lastEdit: ,
    origin: DateTime.now().millisecondsSinceEpoch,
    lastEdit: DateTime.now().millisecondsSinceEpoch,
    //
  );
}
