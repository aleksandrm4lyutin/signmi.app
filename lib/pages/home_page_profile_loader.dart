import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../texts/text_profile_page_loader.dart';
import 'data_holder.dart';
import 'home_page_profile_other.dart';
import 'loading_page.dart';


class ProfilePageLoader extends StatefulWidget {

  final BuildContext cont;
  final String target;
  final String cid;

  const ProfilePageLoader({Key? key,
    required this.cont,
    required this.target,
    required this.cid
  }) : super(key: key);

  @override
  _ProfilePageLoaderState createState() => _ProfilePageLoaderState();
}

class _ProfilePageLoaderState extends State<ProfilePageLoader> {

  late Future<dynamic> profile;
  late Future<bool> blocked;

  late UserSettings? userSettings;
  UserSettings compositeSettings = UserSettings(name: '', photoUrl: '', about: '', language: '', colorNum: '', shadeNum: '', color: Colors.deepOrangeAccent[900]!);
  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';//TODO
  TextProfilePageLoader textProfilePageLoader = TextProfilePageLoader();
  dynamic _snapshotData;


  @override
  void initState() {
    super.initState();

    userSettings = DataHolder.of(widget.cont)?.userSettings;
    language = userSettings?.language ?? 'english';
    highlightColor = userSettings?.color;

    profile = loadProfile(widget.target);
    blocked = isBlocked(widget.cid, widget.target);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([profile, blocked]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _snapshotData = snapshot.data;
            if(_snapshotData[0] != null) {
              ////////////////////////////////////////////////////////
              compositeSettings.language = language!;
              compositeSettings.color = highlightColor!;
              compositeSettings.photoUrl = _snapshotData[0]['photoUrl'];
              compositeSettings.name = _snapshotData[0]['name'];
              compositeSettings.about = _snapshotData[0]['about'];

              return ProfileOther(
                target: widget.target,
                cid: widget.cid,
                userSettings: compositeSettings,
                blocked: _snapshotData[1],
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
                            Text(textProfilePageLoader.strings[language]!['T00'] ?? 'Could not load the data',
                              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Wrap(
                          children: <Widget>[
                            Text(textProfilePageLoader.strings[language]!['T01']
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
                                  Text(textProfilePageLoader.strings[language]!['T02'] ?? 'Back',
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
                                  Text(textProfilePageLoader.strings[language]!['T03'] ?? 'Retry',
                                    style: const TextStyle(fontSize: 25, color: Colors.white),
                                  ),//'Retry'
                                  const Icon(Icons.refresh, color: Colors.white, size: 25,),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  profile = loadProfile(widget.target);
                                  blocked = isBlocked(widget.cid, widget.target);
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

Future<dynamic> loadProfile(String target) async {

  var connectivityResult = await (Connectivity().checkConnectivity());

  if(connectivityResult != ConnectivityResult.none) {
    try {

      var result = await FirebaseFirestore.instance.collection('user_profiles').doc(target).get();
      // final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      //   functionName: 'openUserProfile',
      // );
      // var result = await callable.call({
      //   'uid': target,
      // });
      //return result.data;
      return result.data();
    } catch (e) {
      throw Future.error('error: $e');
    }
  } else {
    throw Future.error('error');
  }

}

Future<bool> isBlocked(String cid, String target) async {

  try {
    var path = '$cid??$target';
    var result = await FirebaseFirestore.instance.collection('blacklists').doc(path).get();
    if(result.data() != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Future.error('error: $e');
  }

}