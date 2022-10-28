import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dejitarumeishiapp/functions/data_service.dart';
import 'package:dejitarumeishiapp/models/editor_arguments.dart';
import 'package:dejitarumeishiapp/models/public_card.dart';
import 'package:dejitarumeishiapp/pages/loadingpage.dart';
import 'package:dejitarumeishiapp/shared/launch_prefs.dart';
import 'package:dejitarumeishiapp/texts/text_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dejitarumeishiapp/functions/pick_image.dart';
import 'package:dejitarumeishiapp/pages/data_holder.dart';
import 'package:flutter/services.dart';

import '../models/public_card.dart';
import '../models/route_arguments.dart';
import '../texts/text_editor.dart';
import 'data_holder.dart';
import 'loading_page.dart';


class Editor extends StatefulWidget {

  //TODO change it to something useful
  final String uid;
  final PublicCard card;
  final String link;
  final BuildContext cont;//context

  const Editor({Key? key,
    this.uid,
    this.card,
    this.link,
    this.cont
  }) : super(key: key);



  @override
  _EditorState createState() => _EditorState();
}

//*********************************************************************//
//******************************* STATE *******************************//
//*********************************************************************//
class _EditorState extends State<Editor> {

  //DataService dataService = DataService();//TODO: delete??
  late PublicCard _tempCard;
  late PublicCard _previewCard;
  bool _isUploading = false;
  String _uploadMessage = '';
  //
  late Future<PublicCard> _card;

  late String _owner;//uid
  late String _author;//name given
  late String _cid;
  late String _globalTitle;
  late String _imgUrl;
  late List<Map> _fields;
  late bool _private;
  late int _origin;
  //
  File? _imgPick;

  bool _isNew = false;
  //fail safe for situation in witch user tapes on back button
  // instead of Ok and gets back to Editor after DataHolder refresh was triggered
  bool _refreshed = false;

  Color highlightColor = Colors.deepOrangeAccent[900]!;
  String language = 'english';
  TextEditor textEditor = TextEditor();

  //String lengths for text fields
  final int _authorTxtLength = 40;
  final int _titleTxtLength = 90;
  final int _textTxtLength = 2000;
  final int _fieldTxtLength = 100;

  @override
  void initState() {
    super.initState();

    _owner = widget.card.owner;
    _cid = widget.card.cid;
    _author = widget.card.author;
    _globalTitle = widget.card.globalTitle;
    _imgUrl = widget.card.imgUrl;
    _fields = widget.card.fields;
    _private = widget.card.private;
    _origin = widget.card.origin;

    _imgPick = null;

    if (_cid.isEmpty) {
      _isNew = true;
    }

    language = DataHolder.of(widget.cont)!.userSettings.language;
    highlightColor = DataHolder.of(widget.cont)!.userSettings.color;
  }


  //String _linkMessage = '';
//TODO Check this things
  final String _typeCheck3 = 'assets/text.jpg';
  final String _typeCheck2 = 'assets/phone.jpg';
  final String _typeCheck1 = 'assets/email.jpg';
  //String _typeCheck0 = 'assets/link.jpg';

  final txtControllerData = TextEditingController();
  final txtController1 = TextEditingController();
  final txtController = TextEditingController();
  final txtControllerAuthor = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtControllerData.dispose();
    txtController1.dispose();
    txtController.dispose();
    txtControllerAuthor.dispose();

    super.dispose();
  }


  //final pickImage = PickImage(userSettings: DataHolder.of(widget.cont).userSettings.color);

  final Map<String, String> prefixes = LaunchPrefs().prefs;

  /*final Map<String, String> prefixes = {
    'email': '',
    'link': 'https://',
    'phone': '',
    'text': '',
    'facebook': 'https://www.facebook.com/',
    'instagram': 'https://www.instagram.com/',
    'youtube': 'https://youtube.com/',
    'vk': 'https://vk.com/',
    'twitter': 'https://twitter.com/',
    'whatsapp': 'https://www.whatsapp.com/',
    'viber': 'https://www.viber.com/',
    'telegram': 'https://telegram.org/',
    'snapchat': 'https://www.snapchat.com/',
    'reddit': 'https://www.redditinc.com/',
    'pinterest': 'https://www.pinterest.com/',
    'discord': 'https://discord.com/',
    'steam': 'https://steamcommunity.com/id/',
    'twitch': 'https://www.twitch.tv/',
    'patreon': 'https://patreon.com/',
    'kickstarter': 'https://kickstarter.com/',
  };*/

  //################################################################
  //                         ASSEMBLE FOR PREVIEW
  //################################################################
  void _assembleForPreview() {
    //Pack all data to PublicCard object
    _previewCard.owner = _owner;
    _previewCard.author = _author;
    _previewCard.cid = _cid;
    _previewCard.globalTitle = _globalTitle;
    _previewCard.imgUrl = _imgUrl;
    _previewCard.fields = _fields;
    _previewCard.private = _private;
    _previewCard.lastEdit = DateTime.now().millisecondsSinceEpoch;
    _previewCard.origin = _origin;
  }

  //################################################################
  //                         UPLOAD CARD
  //################################################################
  void _uploadCard(BuildContext contextEditor) async {
    //Pack all data to PublicCard object
    _tempCard.owner = _owner;
    _tempCard.author = _author;
    _tempCard.cid = _cid;
    _tempCard.globalTitle = _globalTitle;
    _tempCard.imgUrl = _imgUrl;
    _tempCard.fields = _fields;
    _tempCard.private = _private;
    _tempCard.lastEdit = DateTime.now().millisecondsSinceEpoch;
    _tempCard.origin = _origin;

    //Try to upload
    var _r = await dataService.updatePublicCard(widget.uid, _cid, _tempCard, _imgPick, widget.link);
    //_isUploading = false;
    if(_r != null) {
      _uploadMessage = textEditor.strings[language]!['T00'] ?? 'Successfully uploaded!';//'Upload successful!'
      DataHolder.of(widget.cont)!.refreshOwn();
      _refreshed = true;
    } else {
      _uploadMessage = textEditor.strings[language]!['T01'] ?? 'Upload failed!';//'Upload failed!'
    }
    setState(() {
      _cid = _r;
      _isUploading = false;
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            //
          ],
        ),
        titlePadding: EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        children: <Widget>[
          Center(
              child: _r != null
                  ? Icon(Icons.check_circle, color: highlightColor, size: 50,)
                  : Icon(Icons.report_problem, color: highlightColor, size: 50,)
          ),
          Center(child: Text(_uploadMessage, style: const TextStyle(fontSize: 20),)),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text(textEditor.strings[language]['T02'] ?? 'Ok', style: TextStyle(fontSize: 20),),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(contextEditor);
                },
              ),
            ],
          ),
        ],
      ),
    );
    //
  }

  //################################################################
  //                         DELETE CARD
  //################################################################
  void _deleteCard(BuildContext contextEditor) async {
    //Try to delete
    var _d = await dataService.deletePublicCard(widget.uid, _cid, widget.card.imgUrl);
    //_isUploading = false;
    if(_d) {
      _uploadMessage = textEditor.strings[language]!['T03'] ?? 'Successfully deleted!';//'Delete successful!'
      DataHolder.of(widget.cont)!.refreshOwn();
      _refreshed = true;
    } else {
      _uploadMessage = textEditor.strings[language]!['T04'] ?? 'Deletion failed!';//'Delete failed!'
    }
    setState(() {
      _isUploading = false;
    });

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => SimpleDialog(
          //TODO: remove title? (unused)
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              /*Text(
                'Upload result:', textAlign: TextAlign.center,
              ),*/
            ],
          ),
          titlePadding: const EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          children: <Widget>[
            Center(
                child: _d
                    ? Icon(Icons.check_circle, color: highlightColor, size: 50,)
                    : Icon(Icons.report_problem, color: highlightColor, size: 50,)
            ),
            Center(child: Text(_uploadMessage, style: const TextStyle(fontSize: 20),)),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  child: Text(textEditor.strings[language]!['T02'] ?? 'Ok', style: const TextStyle(fontSize: 20),),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(contextEditor);
                    /*setState(() {
                      _isUploading = false;
                      Navigator.pop(context);
                      Navigator.pop(contextEditor);
                    });*/
                  },
                ),
              ],
            ),
          ],
        )
    );
    //
  }

  String _txtData ='';//stores text of Data TextField
  String _txtInfo ='';//stores text of Information TextField
  String _txtTitle = '';//stores text of globalTitle TextField
  String _txtAuthor = '';//stores text of Author TextField


  _reorder(int _oldIndex, int _newIndex) {
    if (_newIndex > _oldIndex) {
      _newIndex -= 1;
    }
    var _item = _fields.removeAt(_oldIndex);
    _fields.insert(_newIndex, _item);
  }



  //*********************************************************************//
  //**************************** STATE BUILD ****************************//
  //*********************************************************************//
  @override
  Widget build(BuildContext context) {

    double _w = MediaQuery.of(context).size.width;

    return _isUploading ? Loading(color: highlightColor) : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            height: 48.0,
            alignment: Alignment.center,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    width: _w / 2 - 20,
                    child: _isNew ? InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _private ? Icons.lock_outline : Icons.lock_open,
                            color: _private ? highlightColor: Colors.white,
                            //size: (_w/2)/4 - 10,
                          ),
                          const SizedBox(width: 5,),
                          Text(_private ? textEditor.strings[language]!['T05'] ?? 'Confidential'
                              : textEditor.strings[language]!['T06'] ?? 'Opened',
                            style: TextStyle(color: Colors.grey[300], fontSize: 15),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _private = !_private;
                        });
                        ///Show about card type
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) => SimpleDialog(
                              title: Center(
                                child: Text(
                                  textEditor.strings[language]!['T24'] ?? 'Card type',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              titlePadding: const EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              children: <Widget>[

                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_private ? textEditor.strings[language]!['T05'] ?? 'Confidential'
                                          : textEditor.strings[language]!['T06'] ?? 'Opened',
                                        style: TextStyle(color: Colors.grey[900], fontSize: 21),
                                      ),
                                      const SizedBox(width: 5,),
                                      Icon(
                                        _private ? Icons.lock_outline : Icons.lock_open,
                                        color: _private ? highlightColor: Colors.grey[600],
                                        size: 21,
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(child: Text(textEditor.strings[language]!['T25']
                                      ?? 'Please note that this attribute cannot be changed after uploading the card',
                                    style: const TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(child: Text(textEditor.strings[language]!['T26']
                                      ?? 'For more information address the help page',
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  ),
                                ),

                                const SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    TextButton(
                                      child: Row(
                                        children: [
                                          Text(textEditor.strings[language]!['T02'] ?? 'Ok',
                                            style: TextStyle(fontSize: 20, color: highlightColor,),
                                          ),
                                          // SizedBox(width: 2,),
                                          // Icon(Icons.done, color: highlightColor,),
                                        ],
                                      ),//'Cancel'
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),

                                  ],
                                ),
                              ],
                            )
                        );
                      },
                    ) : Container(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    width: _w / 2 - 20,
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(textEditor.strings[language]['T07'] ?? 'Apply',
                            style: TextStyle(color: Colors.grey[300], fontSize: 15),
                          ),
                          const SizedBox(width: 5,),
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      onTap: () async {
                        if (!_refreshed) {
                          var connectivityResult = await (Connectivity().checkConnectivity());
                          if(connectivityResult != ConnectivityResult.none) {
                            //Ask if ready to upload
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context0) => SimpleDialog(
                                  title: Center(child: Text(textEditor.strings[language]!['T09'] ?? 'Upload card?')),
                                  titlePadding: const EdgeInsets.all(20.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  children: <Widget>[
                                    Center(child:
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Text(textEditor.strings[language]!['T10']
                                          ?? 'Please make sure that you do not share sensitive information that could harm you or others',
                                        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        TextButton(
                                          child: Row(
                                            children: [
                                              Text(textEditor.strings[language]!['T11'] ?? 'Cancel',
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                              const SizedBox(width: 2,),
                                              const Icon(Icons.clear),
                                            ],
                                          ),//'Cancel'
                                          onPressed: () {
                                            Navigator.pop(context0);
                                          },
                                        ),
                                        TextButton(
                                          child: Row(
                                            children: [
                                              Text(textEditor.strings[language]!['T08'] ?? 'Upload',
                                                style: TextStyle(fontSize: 18, color: highlightColor),
                                              ),
                                              const SizedBox(width: 2,),
                                              Icon(Icons.file_upload, color: highlightColor,),
                                            ],
                                          ),//'Upload'
                                          onPressed: () async {
                                            setState(() {
                                              _isUploading = true;
                                            });
                                            _uploadCard(context);
                                            Navigator.pop(context0);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                            );
                          } else {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => SimpleDialog(
                                  //TODO: remove title? (unused)
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const <Widget>[
                                      //
                                    ],
                                  ),
                                  titlePadding: const EdgeInsets.all(10.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  children: <Widget>[
                                    Center(
                                        child: Icon(Icons.report_problem, color: Colors.deepOrangeAccent[400], size: 50,)
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Center(child:
                                      Text(textEditor.strings[language]!['T12']
                                          ?? 'Please check internet connection or try again later',
                                        style: const TextStyle(fontSize: 20,),
                                        textAlign: TextAlign.center,
                                      ),
                                      ),
                                    ),
                                    const SizedBox(height: 20,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        TextButton(
                                          child: Text(textEditor.strings[language]!['T02'] ?? 'Ок',
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              _isUploading = false;
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                            );
                          }
                        } else {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context0) => SimpleDialog(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const <Widget>[
                                    //
                                  ],
                                ),
                                titlePadding: const EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                children: <Widget>[
                                  Center(
                                    child: Icon(Icons.check_circle, color: highlightColor, size: 50,),
                                  ),
                                  Center(child: Text(_uploadMessage, style: const TextStyle(fontSize: 20),)),
                                  const SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      TextButton(
                                        child: Text(textEditor.strings[language]!['T02'] ?? 'Ok',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context0);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              )
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        //centerTitle: true,
        title: Text(textEditor.strings[language]!['T13'] ?? 'Editor',
          style: const TextStyle(color: Colors.white),
        ),//'Edit card'
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.visibility,
              color: Colors.white,
              //size: (_w/2)/4 - 10,
            ),
            onPressed: () async {
              _assembleForPreview();
              Navigator.of(context).pushNamed('/preview_viewer',
                  arguments: RouteArguments(
                    cid: language,//here language passed as a cid argument
                    color: highlightColor,
                    cont: widget.cont,
                    cardDataPreview: _previewCard,
                    preview: true,
                    file: _imgPick,
                  )
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: Colors.grey[500],
              //size: (_w/2)/4 - 10,
            ),
            onPressed: () async {

              Navigator.of(context).pushNamed('/help_page',
                  arguments: RouteArguments(
                    title: 'editor',
                    language: language,
                  )
              );

            },
          ),
          IconButton(
            disabledColor: Colors.transparent,
            icon: const Icon(
              Icons.delete_forever,
              //size: (_w/2)/4 - 10,
            ),
            color: Colors.white,
            onPressed: !_isNew ? () async {
              if (!_refreshed) {
                var connectivityResult = await (Connectivity().checkConnectivity());
                if(connectivityResult != ConnectivityResult.none) {
                  //Ask if ready to delete
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context0) => SimpleDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            //Title row
                          ],
                        ),
                        titlePadding: const EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        children: <Widget>[
                          Center(
                              child: Icon(Icons.delete_forever, color: highlightColor, size: 50,)
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(child: Text(textEditor.strings[language]!['T14']
                                ?? 'Do you really want to delete card?',
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              TextButton(
                                child: Row(
                                  children: [
                                    Text(textEditor.strings[language]!['T11'] ?? 'Cancel',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 2,),
                                    const Icon(Icons.clear),
                                  ],
                                ),//'Cancel'
                                onPressed: () {
                                  Navigator.pop(context0);
                                },
                              ),
                              TextButton(
                                child: Row(
                                  children: [
                                    Text(textEditor.strings[language]!['T15'] ?? 'Delete',
                                      style: TextStyle(fontSize: 18, color: highlightColor),
                                    ),
                                    const SizedBox(width: 2,),
                                    Icon(Icons.delete_forever, color: highlightColor,),
                                  ],
                                ),//'Delete'
                                onPressed: () async {
                                  setState(() {
                                    _isUploading = true;
                                  });
                                  _deleteCard(context);
                                  Navigator.pop(context0);
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                  );
                } else {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => SimpleDialog(
                        //TODO: remove title? (unused)
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            //
                          ],
                        ),
                        titlePadding: const EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        children: <Widget>[
                          Center(
                              child: Icon(Icons.report_problem, color: highlightColor, size: 50,)
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(child:
                            Text(textEditor.strings[language]!['T12']
                                ?? 'Please check internet connection or try again later',//'Please, make sure your device have internet connection or try again later'
                              style: const TextStyle(fontSize: 20,),
                              textAlign: TextAlign.center,
                            ),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              TextButton(
                                child: Text(textEditor.strings[language]!['T02'] ?? 'Ok',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isUploading = false;
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                  );
                }
              } else {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context0) => SimpleDialog(
                      //TODO: remove title? (unused)
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                        ],
                      ),
                      titlePadding: const EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      children: <Widget>[
                        Center(
                          child: Icon(Icons.check_circle_outline, color: highlightColor, size: 50,),
                        ),
                        Center(child: Text(_uploadMessage, style: const TextStyle(fontSize: 20),)),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            TextButton(
                              child: Text(textEditor.strings[language]!['T02'] ?? 'Ok',
                                style: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () {
                                Navigator.pop(context0);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                );
              }
            } : null,
          ),
        ],
      ),
      body: ReorderableListView(
        header: Column(
          children: [
            //=============================================================//
            //                       IMAGE BLOCK
            //=============================================================//
            SizedBox(
              width: _w,
              height: _w/2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _imgPick != null ? Image.file(_imgPick!, width: _w/2, height: _w/2,) :
                  _imgUrl.isNotEmpty
                      ? Image.network(_imgUrl,
                    width: _w/2, height: _w/2,)
                      : Image.asset('assets/placeholder_1440.jpg',
                    width: _w/2, height: _w/2,),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      //TODO: here should be a premium Image Editor (with support for GIFs?)
                      IconButton(
                        disabledColor: Colors.grey[300],//TODO: remove
                        icon: Icon(Icons.architecture, size: (_w/2)/4 - 10),
                        onPressed: null,
                      ),
                      IconButton(
                        icon: Icon(Icons.photo, size: (_w/2)/4 - 10,
                            color: Colors.grey[600]),
                        onPressed: () async {
                          _imgPick = await PickImage(userSettings: DataHolder.of(widget.cont)?.userSettings).gallery();
                          if(_imgPick != null) {
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.clear, size: (_w/2)/4 - 10,
                            color: Colors.grey[600]),
                        onPressed: () {
                          _imgPick = null;
                          _imgUrl = '';
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.photo_camera, size: (_w/2)/4 - 10,
                            color: Colors.grey[600]),
                        onPressed: () async {
                          _imgPick = await PickImage(userSettings: DataHolder.of(widget.cont)?.userSettings).camera();
                          if(_imgPick != null) {
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
            ),

            //=============================================================//
            //                   AUTHOR BLOCK
            //=============================================================//
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: InkWell(
                child: ListTile(
                  title: Text(_author ?? '',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.fade,
                  ),
                  trailing: Icon(Icons.edit, color: Colors.grey[600]),
                ),
                onTap: () {
                  txtController.text = _author;
                  _txtAuthor = _author;
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => SimpleDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              textEditor.strings[language]!['T16'] ?? 'Signature',
                              textAlign: TextAlign.center,
                            ),
                            IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () {
                                txtController.clear();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        titlePadding: const EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        children: <Widget>[
                          //=============AUTHOR TEXTFIELD==================
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              maxLength: _authorTxtLength,//TODO: adjust
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              controller: txtController,
                              decoration: InputDecoration(
                                //hintText: 'Hint Text',
                                //helperText: 'Helper Text',

                                labelText: textEditor.strings[language]!['T16'] ?? 'Signature',
                                labelStyle: const TextStyle(color: Colors.grey),

                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  borderSide: BorderSide(
                                    width: 1.0,
                                    color: Colors.grey,//grey[200]
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: highlightColor,//deepOrangeAccent[400]
                                  ),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    )
                                ),
                                focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                      width: 1.0,
                                      color: Colors.grey,//grey[500]
                                    )
                                ),

                              ),
                              keyboardType: TextInputType.text,
                              //textInputAction: TextInputAction.newline,
                              minLines: 2,
                              maxLines: 2,
                              onChanged: (val) {
                                setState(() {
                                  _txtAuthor = val;
                                });
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              TextButton(
                                child: Row(
                                  children: [
                                    Text(textEditor.strings[language]!['T11'] ?? 'Cancel',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 2,),
                                    const Icon(Icons.clear),
                                  ],
                                ),//'Cancel'
                                onPressed: () {
                                  txtController.clear();
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Row(
                                  children: [
                                    Text(textEditor.strings[language]!['T17'] ?? 'Done',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 2,),
                                    const Icon(Icons.check),
                                  ],
                                ),//'Done'
                                onPressed: () {
                                  //Store _textVal
                                  setState(() {
                                    _author = _txtAuthor;
                                  });
                                  txtController.clear();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ));
                },
              ),
            ),
            //SizedBox(height: 2,),

            //=============================================================//
            //                   TITLE BLOCK
            //=============================================================//

            //SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: InkWell(
                child: ListTile(
                  title: Text(_globalTitle,
                    style: const TextStyle(fontSize: 25),
                    overflow: TextOverflow.fade,
                  ),
                  trailing: Icon(Icons.edit, color: Colors.grey[600]),
                ),
                onTap: () {
                  txtController.text = _globalTitle;
                  _txtTitle = _globalTitle;
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => SimpleDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              textEditor.strings[language]!['T18'] ?? 'Edit',//'Edit the title'//TODO: PROBLEM WITH SIZE
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () {
                                txtController.clear();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        titlePadding: const EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        children: <Widget>[
                          //=============TITLE TEXTFIELD==================
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              maxLength: _titleTxtLength,//TODO: adjust
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              controller: txtController,
                              decoration: InputDecoration(
                                //hintText: 'Hint Text',
                                //helperText: 'Helper Text',

                                labelText: textEditor.strings[language]['T19'] ?? 'Title',//'Title'
                                labelStyle: const TextStyle(color: Colors.grey),

                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  borderSide: BorderSide(
                                    width: 1.0,
                                    color: Colors.grey,//grey[200]
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: highlightColor,//deepOrangeAccent[400]
                                  ),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    )
                                ),
                                focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                      width: 1.0,
                                      color: Colors.grey,//grey[500]
                                    )
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              //textInputAction: TextInputAction.newline,
                              minLines: 2,
                              maxLines: 2,
                              onChanged: (val) {
                                setState(() {
                                  _txtTitle = val;
                                });
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              TextButton(
                                child: Row(
                                  children: [
                                    Text(textEditor.strings[language]!['T11'] ?? 'Cancel',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 2,),
                                    const Icon(Icons.clear),
                                  ],
                                ),//'Cancel'
                                onPressed: () {
                                  txtController.clear();
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Row(
                                  children: [
                                    Text(textEditor.strings[language]!['T17'] ?? 'Done',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 2,),
                                    const Icon(Icons.check),
                                  ],
                                ),//'Done'
                                onPressed: () {
                                  //Store _textVal
                                  setState(() {
                                    _globalTitle = _txtTitle;
                                  });
                                  txtController.clear();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ));
                },
              ),
            ),
            const SizedBox(height: 5,),
            //=============================================================//
            //                   SELECT FIELD TYPE DIALOG
            //=============================================================//
            TextButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, size: (_w/2)/4 - 10, color: Colors.grey[600],),
                  Text(textEditor.strings[language]!['T20'] ?? 'Add field'),//'Add field'
                ],
              ),
              onPressed: () {
                setState(() {
                  /// ////////////////////////////////////////////////////////////////////////////
                  //_addField(context);
                  _addFieldAlt(context);
                });
              },
            ),
            const Divider(
              height: 30,
              thickness: 2,
              endIndent: 20,
              indent: 20,
            ),
          ],
        ),

        scrollDirection: Axis.vertical,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            _reorder(oldIndex, newIndex);
          });
        },

        //======================FIELDS==========================

        children: _fields.isNotEmpty ? List.generate(_fields.length, (index) {
          return ListTile(
            key: Key('$index'),
            title: Text(_fields[index]['data'].isNotEmpty ?
            (prefixes[_fields[index]['prefix']] ?? '') + _fields[index]['data']
                : textEditor.strings[language]!['T21'] ?? 'Tap to edit',
            ),//TODO: questionable ? :
            subtitle: Text(_fields[index]['info'] ?? ''),//TODO: questionable ? :
            //TODO Replace with icons or not???
            leading: CircleAvatar(
              backgroundImage: AssetImage(_fields[index]['icon'] ?? 'assets/text.jpg',),
            ),
            //
            trailing: IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[600]),
              onPressed: () {
                setState(() {
                  if(_fields.isNotEmpty) {
                    _fields.removeAt(index);
                    //_textList.removeAt(index);
                  }
                });
              },
            ),
            onTap: () {
              //temporary
              txtController.text = _fields[index]['data'];
              txtController1.text = _fields[index]['info'];
              _txtData = _fields[index]['data'];
              _txtInfo = _fields[index]['info'];
              //=============================================================//
              //                   TEXT DIALOG TODO
              //=============================================================//
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          textEditor.strings[language]!['T22'] ?? 'Edit the field',//'Edit the field'
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            txtController.clear();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    titlePadding: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    children: <Widget>[
                      //=============DATA TEXTFIELD==================
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          maxLength: _fields[index]['icon'] == _typeCheck3 ? _textTxtLength : _fieldTxtLength,//TODO: adjust
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          controller: txtController,
                          decoration: InputDecoration(
                            //hintText: 'Hint Text',
                            //helperText: 'Helper Text',

                            //labelText: 'Данные',//'Information'
                            labelText: prefixes[_fields[index]['prefix']] ?? '',
                            labelStyle: const TextStyle(color: Colors.grey),

                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide(
                                width: 1.0,
                                color: Colors.grey,//grey[200]
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide(
                                color: highlightColor,//deepOrangeAccent[400]
                              ),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                )
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey,//grey[500]
                                )
                            ),
                          ),
                          //TODO Remake and clean up
                          keyboardType: _fields[index]['icon'] != _typeCheck2
                              ? _fields[index]['icon'] != _typeCheck3
                              ? _fields[index]['icon'] != _typeCheck1
                              ? TextInputType.url
                              : TextInputType.emailAddress
                              : TextInputType.multiline
                              : TextInputType.phone,
                          //textInputAction: TextInputAction.newline,
                          minLines: 1,
                          maxLines: _fields[index]['icon'] == _typeCheck3 ? 5 : 2,//TODO: adjust
                          onChanged: (val) {
                            setState(() {
                              _txtData = val;
                            });
                          },
                        ),
                      ),
                      //=============INFO TEXTFIELD==================
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: txtController1,
                          maxLength: _fieldTxtLength,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration: InputDecoration(
                            //hintText: 'Hint Text',
                            //helperText: 'Helper Text',
                            //border: OutlineInputBorder(),

                            labelText: textEditor.strings[language]!['T23'] ?? 'Description',//'Description'
                            labelStyle: const TextStyle(color: Colors.grey),

                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide(
                                width: 1.0,
                                color: Colors.grey,//grey[200]
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide(
                                color: highlightColor,//deepOrangeAccent[400]
                              ),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                )
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey,//grey[500]
                                )
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          //textInputAction: TextInputAction.newline,
                          minLines: 1,
                          maxLines: 2,
                          onChanged: (val) {
                            setState(() {
                              _txtInfo = val;
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          TextButton(
                            child: Row(
                              children: [
                                Text(textEditor.strings[language]!['T11'] ?? 'Cancel',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 2,),
                                const Icon(Icons.clear),
                              ],
                            ),//'Cancel'
                            onPressed: () {
                              txtController.clear();
                              txtController1.clear();
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Row(
                              children: [
                                Text(textEditor.strings[language]!['T17'] ?? 'Done',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 2,),
                                const Icon(Icons.check),
                              ],
                            ),//'Done'
                            onPressed: () {
                              //Store _textVal
                              setState(() {
                                _fields[index]['data'] = _txtData;
                                _fields[index]['info'] = _txtInfo;
                              });
                              txtController.clear();
                              txtController1.clear();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ));
            },
          );
        }) : [
          Container(
            key: const ValueKey('!'),
          ),
        ],
      ),
    );
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //                            ADD FIELD ALT
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  void _addFieldAlt(BuildContext context) {

    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext context) {
          return GridView.extent(
            maxCrossAxisExtent: (MediaQuery.of(context).size.width / 4),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            physics: const BouncingScrollPhysics(),
            children: <Widget>[

              /// ///////// ROW 1
              Column(
                children: <Widget>[
                  const SizedBox(height: 20,),
                  TextButton(
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/email.jpg',),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/email.jpg',
                        'info': '',
                        'data': '',
                        'prefix': 'email',
                        'type': 1,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Email'),
                ],
              ),

              Column(
                children: <Widget>[
                  const SizedBox(height: 20,),
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/link.jpg',),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/link.jpg',
                        'info': '',
                        'data': '',
                        'prefix': 'link',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Link'),
                ],
              ),

              Column(
                children: <Widget>[
                  const SizedBox(height: 20,),
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/phone.jpg',),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/phone.jpg',
                        'info': '',
                        'data': '',
                        'prefix': 'phone',//TODO
                        'type': 2,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Phone'),
                ],
              ),

              Column(
                children: <Widget>[
                  const SizedBox(height: 20,),
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/text.jpg',),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/text.jpg',
                        'info': '',
                        'data': '',
                        'prefix': 'text',
                        'type': 3,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Text'),
                ],
              ),

              /// ///////// ROW 2
              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/facebook.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/facebook.png',
                        'info': '',
                        'data': '',
                        'prefix': 'facebook',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Facebook'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/instagram.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/instagram.png',
                        'info': '',
                        'data': '',
                        'prefix': 'instagram',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Instagram'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/twitter.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/twitter.png',
                        'info': '',
                        'data': '',
                        'prefix': 'twitter',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Twitter'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/youtube.png',),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/youtube.png',
                        'info': '',
                        'data': '',
                        'prefix': 'youtube',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('YouTube'),
                ],
              ),

              /// ///////// ROW 3
              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/messenger.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/messenger.png',
                        'info': '',
                        'data': '',
                        'prefix': 'messenger',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Messenger'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/whatsapp.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/whatsapp.png',
                        'info': '',
                        'data': '',
                        'prefix': 'whatsapp',//TODO + change keyboard to number?
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('WhatsApp'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/telegram.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/telegram.png',
                        'info': '',
                        'data': '',
                        'prefix': 'telegram',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Telegram'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/viber.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/viber.png',
                        'info': '',
                        'data': '',
                        'prefix': 'viber',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Viber'),
                ],
              ),

              /// ///////// ROW 4
              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/reddit.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/reddit.png',
                        'info': '',
                        'data': '',
                        'prefix': 'reddit',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Reddit'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/pinterest.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/pinterest.png',
                        'info': '',
                        'data': '',
                        'prefix': 'pinterest',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Pinterest'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/linkedin.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/linkedin.png',
                        'info': '',
                        'data': '',
                        'prefix': 'linkedin',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('LinkedIn'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/vk.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/vk.png',
                        'info': '',
                        'data': '',
                        'prefix': 'vk',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('VK'),
                ],
              ),

              /// ///////// ROW 5
              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/tiktok.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/tiktok.png',
                        'info': '',
                        'data': '',
                        'prefix': 'tiktok',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('TikTok'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/snapchat.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/snapchat.png',
                        'info': '',
                        'data': '',
                        'prefix': 'snapchat',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Snapchat'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/likee.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/likee.png',
                        'info': '',
                        'data': '',
                        'prefix': 'likee',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Likee'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/twitch.png',),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/twitch.png',
                        'info': '',
                        'data': '',
                        'prefix': 'twitch',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Twitch'),
                ],
              ),

              /// ///////// ROW 6
              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/discord.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/discord.png',
                        'info': '',
                        'data': '',
                        'prefix': 'discord',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Discord'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/steam.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/steam.png',
                        'info': '',
                        'data': '',
                        'prefix': 'steam',
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Steam'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/patreon.png'),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/patreon.png',
                        'info': '',
                        'data': '',
                        'prefix': 'patreon',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Patreon'),
                ],
              ),

              Column(
                children: <Widget>[
                  TextButton(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: const AssetImage('assets/kickstarter.png',),
                    ),
                    onPressed: () {
                      _fields.add({
                        'icon': 'assets/kickstarter.png',
                        'info': '',
                        'data': '',
                        'prefix': 'kickstarter',//TODO
                        'type': 0,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Text('Kickstarter'),
                ],
              ),

              /// ///////// ROW 7

            ],
          );
        }
    );
  }

}
