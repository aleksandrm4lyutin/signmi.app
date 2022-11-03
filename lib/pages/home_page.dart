
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import '../models/route_arguments.dart';
import '../models/short_card_collect.dart';
import '../models/short_card_own.dart';
import '../models/user_settings.dart';
import '../texts/text_home_page.dart';
import 'data_holder.dart';
import 'home_page_analytics.dart';
import 'home_page_collection.dart';
import 'home_page_main.dart';
import 'home_page_profile.dart';

class HomePage extends StatefulWidget {

  final int currentPage;//current selected page index pulled from data_loader
  final bool withLink;//true if already processed pending link, pulled from data_loader
  final String userUID;

  const HomePage({Key? key,
    required this.currentPage,
    required this.userUID,
    required this.withLink,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  List<ShortCardOwn>? _ownCardList = [];
  List<ShortCardCollect>? _collectCardList = [];
  late UserSettings? _userSettings;

  //int _selectedPage = 0;
  //int _notifications = 0;

  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';
  TextHomePage textHomePage = TextHomePage();

  @override
  void initState() {
    super.initState();

    initDynamicLinks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //Here data is pulled from DataHolder
    _ownCardList = DataHolder.of(context)?.ownCardList;
    _collectCardList = DataHolder.of(context)?.collectCardList;
    _userSettings = DataHolder.of(context)?.userSettings;

    language = _userSettings?.language;
    highlightColor = _userSettings?.color;
  }

  @override
  void dispose() {

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    //final _user = Provider.of<User>(context);
    //final _uid = _user.uid;
    //double _w = (MediaQuery.of(context).size.width*0.6);
    //double _h = (MediaQuery.of(context).size.height/2.5) - (MediaQuery.of(context).size.width*0.6);


    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: widget.currentPage == 0 ? Main(
        ownList: _ownCardList,
        collectLength: _collectCardList?.length,
        userSettings: _userSettings,
        cont: context,
      ) : widget.currentPage == 1 ? Collection(
        collectList: _collectCardList,
        userSettings: _userSettings,
      ) : widget.currentPage == 2 ? Analytics(
        ownList: _ownCardList, userSettings: _userSettings,
      ) : Profile(
        userSettings: _userSettings, settings: true,
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        elevation: 0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 30.0,
          selectedFontSize: 16.0,
          showUnselectedLabels: true,
          //unselectedFontSize: 14.0,
          backgroundColor: Colors.grey[900],
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: const Color(0xFF212121),
              icon: const Icon(Icons.view_carousel),
              label: textHomePage.strings[language]!['T00'] ?? 'Main',//'Home'
            ),
            BottomNavigationBarItem(
              backgroundColor: const Color(0xFF212121),
              icon: const Icon(Icons.view_list),
              label: textHomePage.strings[language]!['T01'] ?? 'Collection',//'Collection'
            ),
            BottomNavigationBarItem(
              backgroundColor: const Color(0xFF212121),
              icon: const Icon(Icons.equalizer),
              label: textHomePage.strings[language]!['T02'] ?? 'Analytics',//
            ),
            BottomNavigationBarItem(
              backgroundColor: const Color(0xFF212121),
              icon: const Icon(Icons.person),
              label: textHomePage.strings[language]!['T03'] ?? 'Profile',//'Add'
            ),
          ],

          //currentIndex: _selectedPage,//old implementation
          currentIndex: widget.currentPage,
          selectedItemColor: highlightColor,
          unselectedItemColor: Colors.white,
          onTap: (_i) {
            setState(() {
              switch (_i) {
                case 0:
                  return DataHolder.of(context)?.switch2Home();
                case 1:
                  return DataHolder.of(context)?.switch2Collection();
                case 2:
                  return DataHolder.of(context)?.switch2Feed();
                case 3:
                  return DataHolder.of(context)?.switch2Manage();
                default: DataHolder.of(context)?.switch2Home();
              }
              //_selectedPage = _i;//old implementation
            });
          },
        ),
      ),
    );
  }


  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //                         INITIALIZE LINK
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      final Uri? deepLink = dynamicLink.link;
      final queryParams = deepLink?.queryParameters;
      if (queryParams!.isNotEmpty) {
        final _param = queryParams['link'];
        final _split = _param?.split('??');
        if(_split?[0].length == 20 && _split?[1].length == 20 && _split?[2].length == 28) {
          Navigator.of(context).pushNamed('/adding_card',
              arguments: RouteArguments(
                uid: _split![2], //here it carries source
                cid: _split[0], //it carries cid
                link: _split[1], //here it carries key
                cont: context,
                title: widget.userUID,//it carries uid
                number: _collectCardList!.length,
              )
          );
        } else {
          //TODO Show message about wrong params in link
        }
      }
    }).onError((error) {
      //print('onLink error');
      //print(error.message);
    });

    if(!widget.withLink) {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        final queryParams = deepLink.queryParameters;
        if (queryParams.isNotEmpty) {
          final _param = queryParams['link'];
          final _split = _param?.split('??');
          if(_split?[0].length == 20 && _split?[1].length == 20 && _split?[2].length == 28) {
            DataHolder.of(context)?.linkHandler();
            Navigator.of(context).pushNamed('/adding_card',
                arguments: RouteArguments(
                  uid: _split![2], //here it carries source
                  cid: _split[0], //it carries cid
                  link: _split[1], //here it carries key
                  cont: context,
                  title: widget.userUID,//it carries uid
                  number: _collectCardList!.length,
                ),
            );
          } else {
            //TODO Show message about wrong params in link
          }
        }
      }
    }

  }
}
