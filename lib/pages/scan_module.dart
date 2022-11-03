import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/route_arguments.dart';
import '../texts/text_scan_module.dart';
import 'data_holder.dart';
import 'loading_page.dart';


class ScanQR extends StatefulWidget {

  final BuildContext cont;
  final int collectLength;

  const ScanQR({Key? key,
    required this.cont,
    required this.collectLength
  }) : super(key: key);

  //ScanQR({Key key,}) : super(key: key);

  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {

  @override
  void initState() {
    super.initState();

    _loading = false;
    _nfcActive = false;

    language = DataHolder.of(widget.cont)?.userSettings.language ?? 'english';
    highlightColor = DataHolder.of(widget.cont)?.userSettings.color ?? Colors.deepOrangeAccent[900];


    //check if nfc available
    // NFC.isNDEFSupported
    //     .then((bool _isSupported) {
    //   setState(() {
    //     _nfc = _isSupported;
    //     _nfc = false;//TODO TEMPORARY
    //   });
    // });
  }

  @override
  void dispose() {
    qrController.dispose();
    // _NFCstream?.cancel();

    super.dispose();
  }


  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';
  TextScanModule textScanModule = TextScanModule();

  /// TODO MAKE NFC WORK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
  bool _loading = false;
  bool _nfc = false;
  bool _nfcActive = false;
  String nfcData = '';

  String qrText = '';

  late QRViewController qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return !_loading ? Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(textScanModule.strings[language]!['T00'] ?? 'Add',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey[500]),
            onPressed: () {

              Navigator.of(context).pushNamed('/help_page',
                  arguments: RouteArguments(
                    title: 'add',
                    language: language,
                  )
              );

            },
          ),

          const SizedBox(width: 10,),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              _nfcActive ?  Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: _nfc ? Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SpinKitRipple(
                      color: highlightColor,
                      size: MediaQuery.of(context).size.width - 40,
                    ),
                    Icon(
                      Icons.nfc,
                      color: highlightColor,
                      size: MediaQuery.of(context).size.width / 3,
                    ),
                  ],
                ) : Container(
                  height: MediaQuery.of(context).size.width - 40,
                  width: MediaQuery.of(context).size.width - 40,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.nfc,
                        color: Colors.grey[600],
                        size: MediaQuery.of(context).size.width / 3,
                      ),
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(textScanModule.strings[language]!['T04']
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
              ) : SizedBox(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: highlightColor!,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: MediaQuery.of(context).size.width / 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              InkWell(
                child: AnimatedContainer(
                  decoration: BoxDecoration(
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
                onTap: () async {
                  //TODO HERE ACTIVATE NFC TRANSMITTER
                  // if(_nfc) {
                  //   _readNFC(context);
                  //   if(_nfcActive) {
                  //     setState(() {
                  //       _nfcActive = false;
                  //       _stopReading();
                  //     });
                  //   } else {
                  //     _nfcActive = true;
                  //     _readNFC(context);
                  //   }
                  // } else {
                  //   setState(() {
                  //     _nfcActive ? _nfcActive = false : _nfcActive = true;
                  //   });
                  // }
                  setState(() {
                    _nfcActive ? _nfcActive = false : _nfcActive = true;
                  });
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: _nfc ? Text(_nfcActive ? textScanModule.strings[language]!['T02'] ?? 'NFC module is active'
                      : textScanModule.strings[language]!['T03'] ?? 'Enable NFC module',
                    style: TextStyle(
                        fontSize: 16, color: _nfcActive ? highlightColor : Colors.white
                    ),
                  ) : Text(textScanModule.strings[language]!['T05'] ?? 'NFC module is unavailable',
                    style: const TextStyle(
                        fontSize: 16, color:Colors.white
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 90,),
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
                        Text(textScanModule.strings[language]!['T06'] ?? 'Back',
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
      ),
    ) : Loading(color: highlightColor!);
  }

//TODO: MAKE FLIP BUTTON WITH qrController.flipCamera
  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    if(!_loading) {
      controller.scannedDataStream.listen((scanData) {
        if(scanData.toString().isNotEmpty) {
          setState(() {
            _loading = true;
          });
          _validateData(scanData.toString());
        }
      });
    }
  }

  void _validateData(String _data) {

    var _split = _data.split('??');
    if(_split[0].length == 20 && _split[1].length == 20 && _split[2].length == 28) {
      setState(() {
        Navigator.of(context).pushReplacementNamed('/adding_card',
            arguments: RouteArguments(
                uid: _split[2],//here it carries source
                cid: _split[0],//it carries cid
                link: _split[1],//here it carries key
                cont: widget.cont,
                number: widget.collectLength
            )
        );
      });
    } else {
      //TODO: change to proper dialog
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) => SimpleDialog(
            title: const Text(''),
            titlePadding: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            children: <Widget>[
              Text('0: ${_split[0]}',
                style: const TextStyle(fontSize: 20,),
                textAlign: TextAlign.center,
              ),
              Text('1: ${_split[1]}',
                style: const TextStyle(fontSize: 20,),
                textAlign: TextAlign.center,
              ),
              Text('2: ${_split[2]}',
                style: const TextStyle(fontSize: 20,),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton(
                    child: Text(textScanModule.strings[language]!['T07'] ?? 'Ok',
                      style: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          )
      );
      setState(() {
        _loading = false;
      });
    }
  }
}
