import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import '../pages/data_holder.dart';
import '../pages/loading_page.dart';
import '../pages/sharing_module.dart';
import '../shared/web_info.dart';
import '../texts/text_share_link_generator.dart';


class ShareLinkGenerator extends StatefulWidget {

  final String uid;
  final String cid;
  final String link;//here it carries imgUrl
  final String title;
  final BuildContext cont;
  final Color colorE;
  final String languageE;

  const ShareLinkGenerator({Key? key,
    required this.uid,
    required this.cid,
    required this.cont,
    required this.link,
    required this.title,
    required this.colorE,
    required this.languageE
  }) : super(key: key);

  @override
  _ShareLinkGeneratorState createState() => _ShareLinkGeneratorState();
}

class _ShareLinkGeneratorState extends State<ShareLinkGenerator> {

  late Future<String> _link;

  String _key = '';

  Color? highlightColor = Colors.deepOrangeAccent[900]!;
  String? language = 'english';
  TextShareLinkGenerator textShareLinkGenerator = TextShareLinkGenerator();


  //textShareLinkGenerator.strings[language][''] ??
  @override
  void initState() {
    super.initState();

    _link = _generateLink(widget.cid, widget.uid, widget.title, widget.link);

    if(widget.colorE != null) {
      highlightColor = widget.colorE;
    } else {
      highlightColor = DataHolder.of(widget.cont)?.userSettings.color ?? Colors.deepOrangeAccent[900];
    }
    if(widget.languageE != null) {
      language = widget.languageE;
    } else {
      language = DataHolder.of(widget.cont)?.userSettings.language ?? 'english';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _link,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //print('${snapshot.data}');
            if (snapshot.data != null) {
              return SharingModule(
                uid: widget.uid,
                cid: widget.cid,
                link: snapshot.data as String,
                title: widget.title,
                cont: widget.cont,
                generatedKey: _key,
                colorE: highlightColor!,
                languageE: language!,
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
                        Icon(Icons.report_problem,
                          color: highlightColor, size: 50,),
                        const SizedBox(height: 10,),
                        Wrap(
                          children: <Widget>[
                            Text(textShareLinkGenerator.strings[language]!['T00'] ?? 'Cannot generate private key',
                              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Wrap(
                          children: <Widget>[
                            Text(textShareLinkGenerator.strings[language]!['T01']
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
                                  const Icon(Icons.arrow_back, color: Colors.white,
                                    size: 25,),
                                  Text(textShareLinkGenerator.strings[language]!['T02'] ?? 'Back',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),
                                  //'Return'
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    textShareLinkGenerator.strings[language]!['T03'] ?? 'Retry',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),
                                  //'Retry'
                                  const Icon(Icons.refresh, color: Colors.white,
                                    size: 25,),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  _link = _generateLink(widget.cid, widget.uid, widget.title,widget.link);
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

  //TODO Maybe combine this func with the one in Data_Service?
  Future<String> _generateLink(String _cid, String _uid, String _title, String _imgUrl) async {
    //CHECKING FOR INTERNET HERE
    var connectivityResult = await (Connectivity().checkConnectivity());

    if(connectivityResult != ConnectivityResult.none) {
      try {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'generateKey',
        );
        dynamic resp = await callable.call(<String, dynamic>{
          'cid': _cid,
        });
        _key = resp.data;
        /*DocumentReference _docRef = Firestore.instance.collection('transactions').document();
        var _key = _docRef.documentID.toString();*/
        /*await Firestore.instance.collection('transactions').document(_key).setData({
          'source': _uid,
          'target': '',
          'cid': _cid,
          'timeStamp': '',
        });*/

        var _link;
        final DynamicLinkParameters parameters = DynamicLinkParameters(
          uriPrefix: WebInfo().uriPrefix,
          //link: Uri.parse('${WebInfo().website}/sharedlink?link=$_cid??$_key??$_uid'),
          link: Uri.parse('${WebInfo().website}/?link=$_cid??$_key??$_uid'),
          androidParameters: const AndroidParameters(
            packageName: 'sssl4yer.dejitarumeishiapp',
            minimumVersion: 0, //TODO-----------------------------------------
          ),
          // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          //   shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
          // ),
          iosParameters: const IOSParameters(
            bundleId: '', //TODO----------------------------------------------
            minimumVersion: '0', //TODO---------------------------------------
          ),
          socialMetaTagParameters: SocialMetaTagParameters(
            title: _title,
            description: '',
            imageUrl: Uri.parse(_imgUrl),
          ),
        );
        Uri _uri;
        final ShortDynamicLink _shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
        _uri = _shortLink.shortUrl;
        _link = _uri.toString();
        return _link;
      } catch(e) {
        throw Future.error('error: $e');
      }
    } else {
      throw Future.error('error. No Internet connection');
    }

  }
}