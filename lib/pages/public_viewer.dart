import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/public_card.dart';
import '../models/route_arguments.dart';
import '../shared/launch_prefs.dart';
import '../texts/text_public_viewer.dart';


class Viewer extends StatefulWidget {

  final PublicCard card;
  final String link;
  final BuildContext cont;//context
  final Color color;
  final String language;
  final bool preview;
  final bool own;
  final File preImg;

  const Viewer({Key? key,
    required this.card,
    required this.link,
    required this.cont,
    required this.color,
    required this.language,
    required this.preview,
    required this.own,
    required this.preImg
  }) : super(key: key);

  //TODO: implement didChangeDepen... and initState
  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {


  @override
  void initState() {
    super.initState();

    /*language = DataHolder.of(widget.cont).userSettings.language ?? 'english';
    highlightColor = DataHolder.of(widget.cont).userSettings.color ?? Colors.deepOrangeAccent[900];*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    language = widget.language;
    highlightColor = widget.color;

    _launched = _launchInBrowser('');
  }

  @override
  void dispose() {

    super.dispose();
  }

  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';
  TextPublicViewer textPublicViewer = TextPublicViewer();

  String _launchMsg = '';
  IconData _launchIcon = Icons.launch;

  //%%%%%%%%%%%%%%%%%%%%%%%% Launchers %%%%%%%%%%%%%%%%%%%%%%%%%
  late Future<void> _launched;


  Future<void> _launchInBrowser(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String url) async {
    var _url = 'tel:$url';
    if (await canLaunchUrlString(_url)) {
      await launchUrlString(_url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _writeEmail(String url) async {
    final Uri _emailUri = Uri(
        scheme: 'mailto',
        path: url,
        queryParameters: {
          'subject': 'Sent from the Signmi App'//TODO CHANGE
        }
    );
    var _url = _emailUri.toString();
    if (await launchUrlString(_url)) {
      await launchUrlString(_url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}', style: TextStyle(color: highlightColor),);
    } else {
      return const Text('');
    }
  }
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  final Map<String, String> prefixes = LaunchPrefs().prefs;


  @override
  Widget build(BuildContext context) {

    final _user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.preview != true ? textPublicViewer.strings[language]!['T00'] ?? 'Viewer'
            : textPublicViewer.strings[language]!['T01'] ?? 'Preview',
          style: TextStyle(color: Colors.grey[900]),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.grey[900],
        ),
        actions: <Widget>[
          widget.preview != true ? IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey[700]),
            onPressed: () {

              Navigator.of(context).pushNamed('/help_page',
                  arguments: RouteArguments(
                    title: 'viewer',
                    language: language,
                  )
              );

            },
          ) : Container(),

          (widget.preview != true && widget.own == true) ? _user.uid == widget.card.owner ? IconButton(
            icon: Icon(Icons.build, color: Colors.grey[900],),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/editor_loader',
                  arguments: RouteArguments(
                    uid: _user.uid,
                    cid: widget.card.cid,
                    link: widget.link,
                    cont: widget.cont,
                    color: highlightColor,
                    language: language,
                    cardDataPreview: widget.card,
                  )
              );
            },
          ) : Container() : Container() ,

          widget.preview != true ? (_user.uid == widget.card.owner && widget.own == true) ? widget.card.private ? IconButton(
            icon: Icon(Icons.share, color: Colors.grey[900],),
            onPressed: () {
              Navigator.of(context).pushNamed('/share_link_generator',
                  arguments: RouteArguments(
                    uid: _user.uid,
                    cid: widget.card.cid,
                    title: widget.card.globalTitle,
                    link: widget.card.imgUrl,//here imgUrl passed as a link argument
                    //cont: context,
                    cont: widget.cont,
                    color: highlightColor,
                    language: language,
                  )
              );
            },
          ) : IconButton(
            icon: Icon(Icons.share, color: Colors.grey[900],),
            onPressed: () {
              Navigator.of(context).pushNamed('/share_module',
                  arguments: RouteArguments(
                    uid: _user.uid,
                    cid: widget.card.cid,
                    title: widget.card.globalTitle,
                    link: widget.link,
                    //cont: context,
                    cont: widget.cont,
                    color: highlightColor,
                    language: language,
                  )
              );
            },
          ) : widget.card.private ? IconButton(
            icon: Icon(Icons.lock, color: Colors.grey[400],),
            onPressed: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: const Text(''),
                    titlePadding: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    children: <Widget>[
                      Center(
                        child: Icon(
                          Icons.lock_outline,
                          color: highlightColor,
                          size: 50,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(textPublicViewer.strings[language]!['T02'] ??
                              'Private card can be shared only by its owner',
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
                            child: Text(textPublicViewer.strings[language]!['T03'] ?? 'Ok',
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
            },
          ) : IconButton(
            icon: Icon(Icons.share, color: Colors.grey[900],),
            onPressed: () {
              Navigator.of(context).pushNamed('/share_module',
                  arguments: RouteArguments(
                    uid: _user.uid,
                    cid: widget.card.cid,
                    title: widget.card.globalTitle,
                    link: widget.link,
                    cont: widget.cont,
                    color: highlightColor,
                    language: language,
                  )
              );
            },
          ) : Container(),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: false,
            pinned: false,
            expandedHeight: MediaQuery.of(context).size.width,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.all(0.0),
              collapseMode: CollapseMode.parallax,
              //centerTitle: true,
              //title: Image.asset('assets/placeholder_1440.jpg',),
              // background: Container(color: Colors.grey[700]),
              background: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,//??
                children: <Widget>[
                  SpinKitDualRing(color: Colors.grey[600]!, size: MediaQuery.of(context).size.width / 3,),
                  //========================= IMAGE ======================
                  widget.preImg == null ?
                  widget.card.imgUrl.isNotEmpty
                      ? Image.network(widget.card.imgUrl, fit: BoxFit.cover,)
                      : Image.asset('assets/placeholder_1440.jpg', fit: BoxFit.cover,)
                      : Image.file(widget.preImg, fit: BoxFit.cover,),
                ],
              ),
            ),
          ),

          //========================= Launcher Status ===============================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: FutureBuilder<void>(future: _launched, builder: _launchStatus),
            ),
          ),

          //========================= Last Edit ===============================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(textPublicViewer.strings[language]!['T04'] ??
                      'Edited: ',
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  ),
                  Text(
                    DateFormat.yMMMMd(textPublicViewer.strings[language]!['intl_local'] ?? 'en_EN').add_Hm()
                        .format(DateTime.fromMillisecondsSinceEpoch(widget.card.lastEdit)),
                    style: TextStyle(color: Colors.grey[900], fontSize: 14),

                  ),
                ],
              ),
            ),
          ),

          //========================= spacer ===============================
          const SliverToBoxAdapter(
            child: SizedBox(height: 10,),
          ),

          //========================= Author ===============================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Wrap(
                alignment: WrapAlignment.end,
                children: [
                  Text(widget.card.author,//'author:
                    //textAlign: TextAlign.end,
                    style: TextStyle(color: Colors.grey[800], fontSize: 18),
                    overflow: TextOverflow.fade,
                  )
                ],
              ),
            ),
          ),
          //========================= Title ===============================
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Divider(
                  height: 25,
                  thickness: 2,
                  endIndent: 15,
                  indent: 15,
                ),
                //SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Wrap(
                    children: <Widget>[
                      Text(widget.card.globalTitle,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                //SizedBox(height: 20,),
                const Divider(
                  height: 25,
                  thickness: 2,
                  endIndent: 15,
                  indent: 15,
                ),
              ],
            ),
          ),
          //========================= Fields ===============================

          ///prefixes[_fields[index]['prefix']]

          SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              if(widget.card.fields.isNotEmpty) {
                if(widget.card.fields[index]['prefix'] == 'text') {
                  return ListTile(
                    title: Text(widget.card.fields[index]['data'] ?? ''),
                    subtitle: Text(widget.card.fields[index]['info'] ?? ''),
                  );
                } else {
                  return ListTile(
                    title: Text(
                        (prefixes[widget.card.fields[index]['prefix']] ?? '') +
                            widget.card.fields[index]['data'] ?? ''
                    ),
                    subtitle: Text(widget.card.fields[index]['info'] ?? ''),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(widget.card.fields[index]['icon'] ?? 'assets/text.jpg',),
                    ),
                    onTap: () {
                      switch(widget.card.fields[index]['type']) {
                        case 0: {
                          _launchMsg = textPublicViewer.strings[language]!['T06'] ?? 'Open';
                          _launchIcon = Icons.launch;
                        }
                        break;
                        case 1: {
                          _launchMsg = textPublicViewer.strings[language]!['T07'] ?? 'Write';
                          _launchIcon = Icons.alternate_email;
                        }
                        break;
                        case 2: {
                          _launchMsg = textPublicViewer.strings[language]!['T08'] ?? 'Call';
                          _launchIcon = Icons.phone_in_talk;
                        }
                        break;
                        default: {
                          _launchMsg = textPublicViewer.strings[language]!['T06'] ?? 'Open';
                          _launchIcon = Icons.launch;
                        }
                        break;
                      }
                      showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context1) => SimpleDialog(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(textPublicViewer.strings[language]!['T05'] ?? 'Choose an action',
                                  style: TextStyle(color: Colors.grey[700]),
                                  textAlign: TextAlign.center,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    Navigator.pop(context1);
                                  },
                                ),
                              ],
                            ),
                            titlePadding: const EdgeInsets.all(20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            children: <Widget>[

                              //TODO Replace condition with something more robust
                              _launchMsg == textPublicViewer.strings[language]!['T06'] ? Center(child:
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(textPublicViewer.strings[language]!['T09']
                                    ?? 'Please be careful, open links only if you trust the source',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ) : Container(),
                              _launchMsg == textPublicViewer.strings[language]!['T06'] ? const SizedBox(height: 20,
                              ) : Container(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  TextButton(
                                    child: Column(
                                      children: [
                                        Text(_launchMsg, style: const TextStyle(fontSize: 18),),
                                        const SizedBox(height: 5,),
                                        Icon(_launchIcon, color: highlightColor),
                                      ],
                                    ),//'Cancel'
                                    onPressed: () {
                                      switch(widget.card.fields[index]['type']) {
                                        case 0: {
                                          setState(() {
                                            _launched = _launchInBrowser(
                                                (prefixes[widget.card.fields[index]['prefix']] ?? '') +
                                                    widget.card.fields[index]['data']
                                            );
                                          });
                                        }
                                        break;
                                        case 1: {
                                          setState(() {
                                            _launched = _writeEmail(
                                                (prefixes[widget.card.fields[index]['prefix']] ?? '') +
                                                    widget.card.fields[index]['data']
                                            );
                                          });
                                        }
                                        break;
                                        case 2: {
                                          setState(() {
                                            _launched = _makePhoneCall(
                                                (prefixes[widget.card.fields[index]['prefix']] ?? '') +
                                                    widget.card.fields[index]['data']
                                            );
                                          });
                                        }
                                        break;
                                        default: {
                                          //statements;
                                        }
                                        break;
                                      }
                                      Navigator.pop(context1);
                                    },
                                  ),
                                  TextButton(
                                    child: Column(
                                      children: [
                                        Text(textPublicViewer.strings[language]!['T10'] ?? 'Copy',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(height: 5,),
                                        Icon(Icons.content_copy, color: highlightColor,),
                                      ],
                                    ),//'Upload'
                                    onPressed: () async {
                                      //Clipboard.setData(ClipboardData(text: widget.link));
                                      Clipboard.setData(ClipboardData(
                                          text: (prefixes[widget.card.fields[index]['prefix']] ?? '') +
                                              widget.card.fields[index]['data']));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            duration: const Duration(milliseconds: 1490),
                                            backgroundColor: highlightColor,
                                            content: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                                              child: Text(textPublicViewer.strings[language]!['T11'] ?? 'Copied to clipboard',
                                                style: TextStyle(color: Colors.grey[900], fontSize: 18),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                      );
                                      Navigator.pop(context1);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                      );

                      ///
                    },
                  );
                }
              } else {
                return Center(child: Text(textPublicViewer.strings[language]!['T12'] ?? 'No fields'),
                );//'No fields'
              }
            },
              childCount: widget.card.fields.isNotEmpty ? widget.card.fields.length : 1,
            ),
          ),
          //========================= end divider ===============================
          SliverToBoxAdapter(
            child: Column(
              children: const <Widget>[
                Divider(
                  height: 25,
                  thickness: 2,
                  endIndent: 15,
                  indent: 15,
                ),
                SizedBox(height: 30,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}