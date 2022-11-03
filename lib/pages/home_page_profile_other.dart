import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/user_settings.dart';
import '../texts/text_profile_page.dart';


class ProfileOther extends StatefulWidget {

  final UserSettings? userSettings;
  final String target;//enables settings TODO DISPOSE
  final String cid;
  final bool blocked;

  const ProfileOther({Key? key,
    required this.target,
    required this.cid,
    required this.userSettings,
    required this.blocked
  }) : super(key: key);

  @override
  _ProfileOtherState createState() => _ProfileOtherState();
}

class _ProfileOtherState extends State<ProfileOther> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    language = widget.userSettings!.language;
    highlightColor = widget.userSettings!.color;

    _blocked = widget.blocked;

  }

  Color? highlightColor = Colors.deepOrangeAccent[900]!;
  String? language = 'english';//TODO
  TextProfilePage textProfilePage = TextProfilePage();

  late double w;

  double x = 0;
  double y = 0;
  double z = 0;

  late bool _blocked;

  late Future<dynamic> blacklisting;

  String _title = '';
  String _message0 = '';
  String _message = '';


  @override
  Widget build(BuildContext context) {

    w = MediaQuery.of(context).size.width;

    //final _user = Provider.of<User>(context);
    //final _uid = _user.uid;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        centerTitle: true,
        title: Text(textProfilePage.strings[language]!['T00'] ?? 'Profile'),
        actions: [
          IconButton(
              icon: Icon(
                Icons.vpn_key,
                color: _blocked == true ? highlightColor : Colors.white,
              ),
              onPressed: () async {

                if(_blocked == false) {
                  //blacklisting = addToBlacklist('${widget.cid}', '${widget.target}', true);
                  _title = textProfilePage.strings[language]!['T01'] ?? 'Blocking';
                  _message0 = textProfilePage.strings[language]!['T12'] ?? 'Block ';
                } else {
                  //blacklisting = addToBlacklist('${widget.cid}', '${widget.target}', false);
                  _title = textProfilePage.strings[language]!['T02'] ?? 'Unblocking';
                  _message0 = textProfilePage.strings[language]!['T04'] ?? 'Unblock ';
                }

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Center(
                      child: Text(_title,
                        style: const TextStyle(fontSize: 20),),
                    ),
                    titlePadding: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    children: <Widget>[

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            Center(
                              child: Icon(
                                _blocked == false ? Icons.vpn_key_outlined : Icons.vpn_key,
                                size: 40,
                                color: _blocked == false ? highlightColor: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 10,),

                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(_message0,
                                    style: const TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(widget.userSettings?.name ?? '',
                                    style: TextStyle(fontSize: 20, color: highlightColor),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Text(' ?',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: Text(textProfilePage.strings[language]!['T05'] ?? 'Cancel',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                ),

                                const SizedBox(width: 5,),

                                TextButton(
                                  child: Text(textProfilePage.strings[language]!['T06'] ?? 'Yes',
                                    style: const TextStyle(fontSize: 18),
                                  ),//'Cancel'
                                  onPressed: () async {

                                    if(_blocked == false) {
                                      blacklisting = addToBlacklist(widget.cid, widget.target, true);
                                    } else {
                                      blacklisting = addToBlacklist(widget.cid, widget.target, false);
                                    }

                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context1) => SimpleDialog(
                                        title: Center(
                                          child: Text(_title,
                                            style: const TextStyle(fontSize: 20),),
                                        ),
                                        titlePadding: const EdgeInsets.all(10.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        children: <Widget>[

                                          FutureBuilder(
                                              future: blacklisting,
                                              builder: (context1, snapshot) {
                                                bool _r;
                                                if (snapshot.connectionState == ConnectionState.done) {
                                                  if(snapshot.data != null) {
                                                    _blocked = !_blocked;
                                                    if(_blocked == true) {
                                                      _message = textProfilePage.strings[language]!['T08']
                                                          ?? 'User is blocked and no longer have access to your card until unblocked';
                                                    } else {
                                                      _message = textProfilePage.strings[language]!['T07']
                                                          ?? 'User is unblocked and can access your card';
                                                    }
                                                    _r = true;
                                                  } else {
                                                    _message = textProfilePage.strings[language]!['T09']
                                                        ?? 'Error has occurred. Could not perform operation. Please try again later';
                                                    _r = false;
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: Column(
                                                      children: [
                                                        Center(
                                                          child: Icon(
                                                            _r == false ? Icons.block : _blocked == true ? Icons.phonelink_lock_outlined : Icons.phonelink_ring_outlined,
                                                            size: 40,
                                                            color: highlightColor,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10,),

                                                        Center(
                                                          child: Text(_message,
                                                            style: const TextStyle(fontSize: 20),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10,),

                                                        TextButton(
                                                          child: Text(textProfilePage.strings[language]!['T10'] ?? 'Ok',
                                                            style: const TextStyle(fontSize: 18),
                                                          ),//'Cancel'
                                                          onPressed: () {
                                                            setState(() {
                                                              Navigator.pop(context1);
                                                              Navigator.pop(context);
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return SpinKitDualRing(
                                                    size: 40,
                                                    color: highlightColor!,
                                                  );
                                                }
                                                //return null;
                                              }
                                          ),

                                        ],
                                      ),
                                    );

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

                ///


              }
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 60,),

            GestureDetector(
              onPanUpdate: _onDragUpdateHandler,
              dragStartBehavior: DragStartBehavior.start,
              behavior: HitTestBehavior.translucent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    x = 0;
                    y = 0;
                    z = 0;
                  });
                },
                child: SizedBox(
                  height: w - 120,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [

                      Transform(
                        transform: Matrix4(
                          1,0,0,0,
                          0,1,0,0,
                          0,0,1,0.003,
                          0,0,0,1,
                        )..rotateX(x)..rotateY(y)..rotateZ(z),
                        alignment: FractionalOffset.center,
                        child: Center(
                          child: widget.userSettings!.photoUrl.isNotEmpty ?
                            CircleAvatar(
                              radius: (w - 120) / 2,
                              backgroundColor: Colors.grey[800],
                              child: (widget.userSettings!.photoUrl.isNotEmpty) ? Container() : Icon(
                                Icons.person,
                                size: w - 160,
                                color: Colors.grey[700],
                              ),
                              backgroundImage: NetworkImage(widget.userSettings!.photoUrl),
                            ) : CircleAvatar(
                            radius: (w - 120) / 2,
                            backgroundColor: Colors.grey[800],
                            child: (widget.userSettings!.photoUrl.isNotEmpty) ? Container() : Icon(
                              Icons.person,
                              size: w - 160,
                              color: Colors.grey[700],
                            ),
                            backgroundImage: const AssetImage('assets/empty.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60,),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(widget.userSettings?.name ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

            //SizedBox(height: 30,),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Wrap(
                  children: [
                    Text(widget.userSettings?.about ?? '',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),

            Center(
              child: _blocked == true ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(textProfilePage.strings[language]!['T11'] ?? 'Blocked',
                  style: TextStyle(fontSize: 20, color: highlightColor),
                ),
              ) : Container(),
            ),

          ],
        ),
      ),
    );
  }

  void _onDragUpdateHandler(DragUpdateDetails details) {
    setState(() {
      y = y - (details.delta.dx.floorToDouble() * 0.1) / 250;
      x = x + (details.delta.dy.floorToDouble() * 0.1) / 250;
    });
  }
}

Future<bool> addToBlacklist(String _cid, String _target, bool block) async {
  try {
    var _path = '$_cid??$_target';
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('addToBlacklist');
    var result = await callable.call({'path': _path, 'cid': _cid, 'block': block});
    return result.data;
  } catch(e) {
    throw Future.error('error: $e');
  }
}
