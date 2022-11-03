import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/route_arguments.dart';
import '../texts/text_share_module.dart';
import 'data_holder.dart';


class SharingModule extends StatefulWidget {

  final String uid;
  final String cid;
  final String link;
  final String title;
  final BuildContext cont;
  final String generatedKey;
  final Color colorE;
  final String languageE;

  const SharingModule({Key? key,
    required this.uid,
    required this.cid,
    required this.title,
    required this.link,
    required this.cont,
    required this.generatedKey,
    required this.colorE,
    required this.languageE
  }) : super(key: key);


  @override
  _SharingModuleState createState() => _SharingModuleState();
}

class _SharingModuleState extends State<SharingModule> {

  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';
  TextShareModule textShareModule = TextShareModule();

  String _qrData = '';

  bool _nfc = false;
  bool _nfcActive = false;
  //bool _ready = true;
  bool _copied = false;

  //StreamSubscription<NDEFMessage> _stream;

  @override
  void initState() {
    super.initState();

    //check if key is present and combine data
    if(widget.generatedKey != null && widget.generatedKey.isNotEmpty) {
      _qrData = '${widget.cid}??${widget.generatedKey}??${widget.uid}';
    } else {
      _qrData = '${widget.cid}??public_cards_keyless??${widget.uid}';
    }

    //check if nfc available
    // NFC.isNDEFSupported
    //     .then((bool _isSupported) {
    //   setState(() {
    //     _nfc = _isSupported;
    //     _nfc = false;//TODO: DELETE Line
    //   });
    // });

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

    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(textShareModule.strings[language]!['T00'] ?? 'Share',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          widget.generatedKey != null
              ? Icon(Icons.lock_outline, color: highlightColor)
              : Container(),

          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey[500]),
            onPressed: () {

              Navigator.of(context).pushNamed('/help_page',
                  arguments: RouteArguments(
                    title: 'share',
                    language: language,
                  )
              );

            },
          ),

          const SizedBox(width: 10,),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(widget.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              /*child: Text('$_qrData' ?? '',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 8,//16
                ),
              ),*/
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: AnimatedSwitcher(
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: _nfcActive ?  Container(
                  color: Colors.transparent,
                  height: w - 20,
                  width: w - 20,
                  child: _nfc ? Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SpinKitRipple(
                        color: highlightColor,
                        size: w - 40,
                      ),
                      Icon(
                        Icons.nfc,
                        color: highlightColor,
                        size: w / 3,
                      ),
                    ],
                  ) : Container(
                    height: w - 40,
                    width: w - 40,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.nfc,
                          color: Colors.grey[600],
                          size: w / 3,
                        ),
                        Wrap(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(textShareModule.strings[language]!['T05']
                                  ?? 'NFC support will be added soon. Until then, please use the QR-code or the link',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: highlightColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ) : Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: w - 20,
                      width: w - 20,
                      //color: highlightColor,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: highlightColor,
                      ),
                    ),
                    // Container(
                    //   height: w,
                    //   width: w,
                    //   color: highlightColor,
                    //   // decoration: BoxDecoration(
                    //   //   borderRadius: BorderRadius.circular(30),
                    //   //   color: highlightColor,
                    //   // ),
                    // ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: QrImage(
                        padding: const EdgeInsets.all(20.0),
                        backgroundColor: Colors.white,
                        size: w - 40,
                        data: _qrData,
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                title: Text(widget.link, style: TextStyle(color: _copied ? highlightColor : Colors.white),),
                trailing: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.content_copy, color: Colors.white),
                    iconSize: 30,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.link));
                      if(!_copied) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 1490),
                              backgroundColor: highlightColor,
                              content: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(textShareModule.strings[language]!['T02'] ?? 'Copied to clipboard',
                                  style: TextStyle(color: Colors.grey[900], fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                        );
                      }
                      setState(() {
                        _copied = true;
                      });
                    },
                  ),
                ),
              ),
            ),
            InkWell(
              child: AnimatedContainer(
                decoration: BoxDecoration(
                  //color: _nfc ? _nfcActive ? Colors.grey[900] : Colors.grey : Colors.grey[300],
                  color: _nfcActive ? highlightColor : Colors.grey[800],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(_nfcActive ? 0 : 30.0),
                ),
                width: _nfcActive ? MediaQuery.of(context).size.width - 40 : 110.0,
                height: 55.0,
                //color: _nfcActive ? Colors.blue : Colors.grey[800],
                alignment: Alignment.center,
                duration: const Duration(seconds: 1),
                curve: Curves.elasticOut,
                child: const Icon(Icons.nfc,
                  color: Colors.white, size: 30,),
              ),
              onTap: () {
                //TODO

                setState(() {
                  _nfcActive ? _nfcActive = false : _nfcActive = true;
                });
              },
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: _nfc ? Text(_nfcActive ? textShareModule.strings[language]!['T03'] ?? 'NFC module is inactive'
                    : textShareModule.strings[language]!['T04'] ?? 'Enable NFC module',
                  style: TextStyle(
                      fontSize: 16, color: _nfcActive ? highlightColor : Colors.white
                  ),
                ) : Text(textShareModule.strings[language]!['T06'] ?? 'NFC module is unavailable',
                  style: const TextStyle(
                      fontSize: 16, color:Colors.white
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.arrow_back_ios,
                        size: 20.0,
                        color: Colors.white,
                      ),
                      Text(textShareModule.strings[language]!['T07'] ?? 'Back',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
