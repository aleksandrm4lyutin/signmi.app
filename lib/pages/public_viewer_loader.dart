import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signmi_app/pages/public_viewer.dart';
import '../functions/data_services/delete_single_collect_card.dart';
import '../functions/data_services/get_private_card.dart';
import '../functions/data_services/get_public_card.dart';
import '../functions/data_services/update_single_collect_card.dart';
import '../models/public_card.dart';
import '../models/short_card_collect.dart';
import '../texts/text_public_viewer_loader.dart';
import 'data_holder.dart';
import 'loading_page.dart';



class ViewerLoader extends StatefulWidget {

  final String uid;
  final String cid;
  final String link;
  final BuildContext cont;
  final ShortCardCollect? cardData;
  final bool own;
  final bool updated;//TODO Dispose


  const ViewerLoader({Key? key,
    required this.uid,
    required this.cid,
    required this.link,
    required this.cont,
    required this.cardData,
    required this.own,
    required this.updated
  }) : super(key: key);

  @override
  _ViewerLoaderState createState() => _ViewerLoaderState();
}

class _ViewerLoaderState extends State<ViewerLoader> {

  late Future<PublicCard?>? _card;
  late Future<bool> _delete;
  late Future<bool> _update;

  late bool? _isPrivate;
  dynamic _snapshotData;



  @override
  void initState() {
    super.initState();

    language = DataHolder.of(widget.cont)?.userSettings.language ?? 'english';
    highlightColor = DataHolder.of(widget.cont)?.userSettings.color ?? Colors.deepOrangeAccent[900];

    widget.own == true ? _isPrivate = false : _isPrivate = widget.cardData?.private;

    if(widget.cid.isNotEmpty) {
      _card = loadCard(widget.uid, widget.cid, widget.own, _isPrivate!);
    } else {
      _card = null;//maybe some errors, should check
    }
  }

  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';
  TextPublicViewerLoader textPublicViewerLoader = TextPublicViewerLoader();


  @override
  Widget build(BuildContext context) {

    final uid = Provider.of<User>(context).uid;

    return FutureBuilder(
        future: _card,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _snapshotData = snapshot.data;
            if (_snapshotData != null) {
              //check if card is being successfully pulled by data service
              //if card is no longer present in database result contains empty card with keywords
              if (_snapshotData.owner == 'delete' && _snapshotData.globalTitle == 'delete') {
                //delete card from short list
                _delete = deleteCard(uid, widget.cid);
                return FutureBuilder(
                    future: _delete,
                    builder: (context, snapshot0) {
                      if (snapshot0.connectionState == ConnectionState.done) {
                        return Scaffold(
                          backgroundColor: Colors.grey[900],
                          body: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.delete_forever,
                                    color: Colors.deepOrangeAccent[400],
                                    size: 50,),
                                  const SizedBox(height: 10,),
                                  Wrap(
                                    children: <Widget>[
                                      Text(textPublicViewerLoader
                                          .strings[language]!['T00'] ??
                                          'Could not load the data',
                                        style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    children: <Widget>[
                                      Text(textPublicViewerLoader
                                          .strings[language]!['T01'] ??
                                          'Card has been deleted by its owner',
                                        style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceAround,
                                    children: <Widget>[
                                      TextButton(
                                        child: Row(
                                          children: <Widget>[
                                            const Icon(Icons.arrow_back,
                                              color: Colors.white, size: 25,),
                                            Text(textPublicViewerLoader
                                                .strings[language]!['T04'] ??
                                                'Ok',
                                              style: const TextStyle(fontSize: 25, color: Colors.white),
                                            ), //'Return'
                                          ],
                                        ),
                                        onPressed: () async {
                                          await DataHolder.of(widget.cont)?.refreshCollect();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Loading(color: highlightColor!);
                      }
                    }
                );
              } else if(_snapshotData.owner == 'denied' && _snapshotData.globalTitle == 'denied') {

                return Scaffold(
                  backgroundColor: Colors.grey[900],
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.delete_forever,
                            color: Colors.deepOrangeAccent[400],
                            size: 50,),
                          const SizedBox(height: 10,),
                          Wrap(
                            children: <Widget>[
                              Text(textPublicViewerLoader
                                  .strings[language]!['T00'] ??
                                  'Could not load the data',
                                style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          Wrap(
                            children: <Widget>[
                              Text(textPublicViewerLoader
                                  .strings[language]!['T02'] ??
                                  'You are denied access to the card by its owner',
                                style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceAround,
                            children: <Widget>[
                              TextButton(
                                child: Row(
                                  children: <Widget>[
                                    const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 25,),
                                    Text(textPublicViewerLoader
                                        .strings[language]!['T04'] ??
                                        'Ok',
                                      style: const TextStyle(fontSize: 25, color: Colors.white),
                                    ), //'Return'
                                  ],
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Row(
                                  children: <Widget>[
                                    Text(textPublicViewerLoader
                                        .strings[language]!['T03'] ??
                                        'Delete',
                                      style: const TextStyle(fontSize: 25, color: Colors.white),
                                    ),
                                    const Icon(Icons.delete_forever,
                                      color: Colors.white, size: 25,),//'Return'
                                  ],
                                ),
                                onPressed: () async {
                                  await deleteCard(uid, widget.cid);
                                  await DataHolder.of(widget.cont)?.refreshCollect();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              } else {

                //Check if card's data is equal to short list data and if updated bool is true
                //First check if card data is being provided, otherwise it means we opening own card, return Viewer immediately
                if(widget.cardData != null) {
                  if(_snapshotData.globalTitle != widget.cardData?.globalTitle ||
                      _snapshotData.author != widget.cardData?.author ||
                      _snapshotData.imgUrl != widget.cardData?.imgUrl ||
                      _snapshotData.private != widget.cardData?.private ||
                      widget.cardData?.updated == true
                  ) {
                    //Update short card collect
                    _update = updateCard(Provider.of<User>(context).uid, _snapshotData, widget.link, widget.cont);

                    return FutureBuilder(
                        future: _update,
                        builder: (context, snapshot1) {
                          if (snapshot1.connectionState == ConnectionState.done) {
                            return Viewer(
                              card: _snapshotData,
                              link: _snapshotData.private == false ? widget.link : '',
                              cont: widget.cont,
                              color: highlightColor!,
                              language: language ?? 'english',
                              own: widget.own,
                              preview: false,
                              preImg: File(''),//TODO
                            );
                          } else {
                            return Loading(color: highlightColor!);
                          }
                        }
                    );
                  }
                }

                return Viewer(
                  card: _snapshotData,
                  link: widget.link,
                  cont: widget.cont,
                  color: highlightColor!,
                  language: language ?? 'english',
                  own: widget.own,
                  preview: false,
                  preImg: File(''),//TODO
                );
              }
            } else {
              return Scaffold(
                backgroundColor: Colors.grey[900],
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.report_problem, color: Colors.deepOrangeAccent[400], size: 50,),
                        const SizedBox(height: 10,),
                        Wrap(
                          children: <Widget>[
                            Text(textPublicViewerLoader.strings[language]!['T00'] ?? 'Could not load the data',
                              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Wrap(
                          children: <Widget>[
                            Text(textPublicViewerLoader.strings[language]!['T05']
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
                                  Text(textPublicViewerLoader.strings[language]!['T06'] ?? 'Back',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Row(
                                children: <Widget>[
                                  Text(textPublicViewerLoader.strings[language]!['T07'] ?? 'Retry',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),
                                  const Icon(Icons.refresh, color: Colors.white, size: 25,),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  _card = loadCard(uid, widget.cid, widget.own, _isPrivate!);
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

Future<PublicCard?> loadCard(String _uid, String _cid, bool _own, bool _private) async {

  try {
    if(_own == true || _private == false) {
      return await getPublicCard(_uid, _cid, _own);
    } else {
      return await getPrivateCard(_uid, _cid);
    }
  } catch(e) {
    throw Future.error('error');
  }
}

Future<bool> deleteCard(String _uid, String _cid) async {
  try {
    return await deleteSingleCollectCard(_uid, _cid);
  } catch(e) {
    throw Future.error('error');
  }
}

Future<bool> updateCard(String _uid, PublicCard _card, String _link, BuildContext _context) async {
  try {
    var _result = await updateSingleCollectCard(_uid, _card, _link);
    if(_result) {
      await DataHolder.of(_context)?.refreshCollect();
    }
    return _result;
  } catch(e) {
    throw Future.error('error');
  }
}
