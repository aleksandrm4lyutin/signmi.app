import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_arguments.dart';
import '../models/short_card_own.dart';
import '../models/user_settings.dart';
import '../shared/max_numbers.dart';
import '../texts/text_home_page_main.dart';


class Main extends StatefulWidget {

  final List<ShortCardOwn>? ownList;
  final int? collectLength;
  final BuildContext cont;
  final UserSettings? userSettings;

  const Main({Key? key,
    required this.ownList,
    required this.collectLength,
    required this.cont,
    required this.userSettings
  }) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    language = widget.userSettings?.language;
    highlightColor = widget.userSettings?.color;

  }

  //CopyPasted code to control handler below carousel, better to leave as is
  List<T> map<T> (List list, Function handler) {
    List<T> result = [];
    for(var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }
  //

  Color? highlightColor = Colors.deepOrangeAccent[900];
  String? language = 'english';//TODO
  TextHomePageMain textHomePageMain = TextHomePageMain();

  final int _maxOwn = MaxNumbers().maxOwn;//max number of own cards
  final int _maxCollect = MaxNumbers().maxCollect;//max number of collect cards

  int _currentSlide = 0;
  late double w;
  late double h;
  late double _w;
  late double _h;
  //final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    //TODO UID is already pulled from Provider.of<User>(context) in DataLoader, should replace everywhere!
    final _user = Provider.of<User>(context);
    final _uid = _user.uid;
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    _w = (w*0.6);
    _h = (h/2.5) - (w*0.6);


    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //==================================== TOP BAR =========================
          Column(
            children: [
              SizedBox(
                height: 60,
                child: Row(
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
                                title: 'main',
                                language: language,
                              )
                          );

                        },
                      ),
                    ),
                    Container(
                      width: w / 3,
                      alignment: Alignment.center,
                      child: Text(textHomePageMain.strings[language]!['T00'] ?? 'Main',
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: w / 3,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          ///TODO
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              //_____________________________________________________________
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: w / 2,
                    height: 48,
                    alignment: Alignment.center,
                    child: TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(textHomePageMain.strings[language]!['T01'] ?? 'Awaiting: ',///TODO
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('0',//TODO: counter for pending cards
                            style: TextStyle(color: highlightColor, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        //TODO ADD OFFLINE CARDS====================!
                      },
                    ),
                  ),
                  Container(
                    width: w / 2,
                    height: 48,
                    alignment: Alignment.center,
                    child: TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(textHomePageMain.strings[language]!['T02'] ?? 'Create new',//'Cancel'
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 5,),
                          const Icon(Icons.create, color: Colors.white, size: 18,),
                        ],
                      ),
                      onPressed: () {
                        if (widget.ownList!.length < _maxOwn) {
                          Navigator.of(context).pushNamed('/editor_loader',
                              arguments: RouteArguments(
                                uid: _uid,
                                cid: '',
                                link: '',
                                cont: context,
                              )
                          );
                        } else {
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
                                  Center(
                                    child: Text('${textHomePageMain.strings[language]!['T04']}$_maxOwn',
                                      style: const TextStyle(fontSize: 20,),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      TextButton(
                                        child: Text(textHomePageMain.strings[language]!['T05'] ?? 'Ok',
                                          style: const TextStyle(fontSize: 20),),
                                        onPressed: () async {
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
                ],
              ),
            ],
          ),
          //==================================== CAROUSEL =========================
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CarouselSlider.builder(
                  options: CarouselOptions(
                    height: h/2.5,
                    disableCenter: true,
                    //aspectRatio: 16/9,
                    initialPage: _currentSlide,
                    viewportFraction: 0.6,
                    enableInfiniteScroll: widget.ownList!.length > 1 ? true : false,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentSlide = index;
                      });
                    },
                  ),
                  itemCount: widget.ownList!.isNotEmpty ? widget.ownList!.length : 1,
                  itemBuilder: (BuildContext context, int itemIndex, int realIndex) {
                    if (widget.ownList!.isNotEmpty) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Column(
                              children: <Widget>[
                                //TODO: check if there is an image, otherwise return placeholder asset
                                //TODO: replace Image.network with Cashed Image?
                                InkWell(
                                  child: widget.ownList![itemIndex].imgUrl.isNotEmpty
                                      ? Image.network(widget.ownList![itemIndex].imgUrl,
                                    height: _w,
                                    width: _w,)
                                      : Image.asset('assets/placeholder_1440.jpg',
                                    height: _w,
                                    width: _w,),
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/viewer_loader',
                                        arguments: RouteArguments(
                                          uid: _uid,
                                          cid: widget.ownList![_currentSlide].cid,
                                          link: widget.ownList![_currentSlide].link,
                                          cont: context,
                                          own: true,
                                        )
                                    );
                                  },
                                ),
                                Container(
                                  color: Colors.grey[800],
                                  //color: Colors.deepOrangeAccent[400],
                                  height: _h,
                                  width: _w,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0,),
                                          child: Text(widget.ownList![itemIndex].globalTitle,
                                            overflow: TextOverflow.fade,
                                            style: const TextStyle(
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.build,
                                          color: Colors.white,
                                          size: _h*0.4,
                                        ),
                                        onPressed: () async {
                                          //Navigator.of(context).pushNamed('/editor', arguments: 'empty param');
                                          Navigator.of(context).pushNamed('/editor_loader',
                                              arguments: RouteArguments(
                                                uid: _uid,
                                                cid: widget.ownList![_currentSlide].cid,
                                                link: widget.ownList![_currentSlide].link,
                                                cont: context,
                                              )
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            widget.ownList![itemIndex].private ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.lock_outline,
                                color: highlightColor,
                                size: 20,
                              ),
                            ) : Container(),
                          ],
                        ),
                      );
                    } else {
                      //TODO Problem with text length
                      return Container(
                        color: Colors.transparent,
                        child: Center(
                          child: InkWell(
                            child: Text(textHomePageMain.strings[language]!['T03'] ?? 'Create new card',
                              style: TextStyle(color: Colors.grey[300], fontSize: 20),
                              overflow: TextOverflow.fade,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed('/editor_loader',
                                  arguments: RouteArguments(
                                    uid: _uid,
                                    cid: '',
                                    link: '',
                                    cont: context,
                                  )
                              );
                            },
                          ),//'Create a new card'
                        ),
                      );
                    }
                  }
              ),
              const SizedBox(height: 20,),
              //------------------- indicators ---------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: map<Widget>(widget.ownList!, (index, url) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentSlide == index ? highlightColor : Colors.grey[800],
                    ),
                  );
                }),
              ),
            ],
          ),
          //==================================== BUTTONS =========================
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.playlist_add,//save_alt
                          size: 30.0,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        backgroundColor: highlightColor,
                        foregroundColor: Colors.white, // foreground
                      ),
                      onPressed: () async {
                        if (widget.collectLength! < _maxCollect) {
                          Navigator.of(context).pushNamed('/scan_module',
                              arguments: RouteArguments(
                                cont: widget.cont,
                                number: widget.collectLength,
                                //,
                              )
                          );
                        } else {
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
                                  Center(
                                    child: Text('${textHomePageMain.strings[language]!['T08']}$_maxCollect',
                                      style: const TextStyle(fontSize: 20,),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      TextButton(
                                        child: Text(textHomePageMain.strings[language]!['T05'] ?? 'Ok',
                                          style: const TextStyle(fontSize: 20),),
                                        onPressed: () async {
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(textHomePageMain.strings[language]!['T06'] ?? 'Add',
                          style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextButton(
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.share,
                          size: 30.0,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        backgroundColor: highlightColor,
                        foregroundColor: Colors.white, // foreground
                      ),
                      onPressed: () {
                        if(widget.ownList![_currentSlide].private) {
                          Navigator.of(context).pushNamed('/share_link_generator',
                              arguments: RouteArguments(
                                uid: _uid,
                                cid: widget.ownList![_currentSlide].cid,
                                title: widget.ownList![_currentSlide].globalTitle,
                                link: widget.ownList![_currentSlide].imgUrl,//here imgUrl passed as a link argument, actual link will be generated with key
                                cont: context,
                              )
                          );
                        } else {
                          Navigator.of(context).pushNamed('/share_module',
                              arguments: RouteArguments(
                                uid: _uid,
                                cid: widget.ownList![_currentSlide].cid,
                                title: widget.ownList![_currentSlide].globalTitle,
                                link: widget.ownList![_currentSlide].link,
                                cont: context,
                              )
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(textHomePageMain.strings[language]!['T07'] ?? 'Share',
                          style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
