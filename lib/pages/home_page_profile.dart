import 'package:flutter/material.dart';
import '../models/route_arguments.dart';
import '../models/user_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../texts/text_profile_page.dart';


class Profile extends StatefulWidget {

  final UserSettings? userSettings;
  final bool settings;//enables settings TODO DISPOSE

  const Profile({Key? key,
    required this.settings,
    required this.userSettings
  }) : super(key: key);


  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    language = widget.userSettings?.language;
    highlightColor = widget.userSettings?.color;
  }

  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';//TODO
  TextProfilePage textProfilePage = TextProfilePage();

  late double w;

  double x = 0;
  double y = 0;
  double z = 0;

  @override
  Widget build(BuildContext context) {

    w = MediaQuery.of(context).size.width;

    final _user = Provider.of<User>(context);
    final _uid = _user.uid;

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: w / 3,
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey[500]),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/help_page',
                          arguments: RouteArguments(
                            title: 'profile',
                            language: language,
                          )
                      );

                    },
                  ),
                ),
                SizedBox(
                  width: w / 3,
                  height: 60,
                  child: Center(
                    child: Text(textProfilePage.strings[language]!['T00'] ?? 'Profile',//TODO
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

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
                          child: widget.userSettings!.photoUrl.isNotEmpty ? CircleAvatar(
                            radius: (w - 120) / 2,
                            backgroundColor: Colors.grey[800],
                            child: (widget.userSettings!.photoUrl.isNotEmpty) ? Container() : Icon(
                              Icons.person,
                              size: w - 160,
                              color: Colors.grey[700],
                            ),
                            //backgroundImage: widget.userSettings.photoUrl.isNotEmpty ? NetworkImage(widget.userSettings.photoUrl) : AssetImage('assets/empty.png'),
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

                      widget.settings == true ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: IconButton(
                          icon: Icon(Icons.settings,
                            color: highlightColor,
                            size: 40,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/settings',
                                arguments: RouteArguments(
                                  uid: _uid,
                                  //cid: '',
                                  //link: '',
                                  cont: context,
                                )
                            );
                          },
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60,),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(widget.userSettings!.name,
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
                    Text(widget.userSettings!.about,
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
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

