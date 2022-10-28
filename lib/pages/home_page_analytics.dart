import 'package:flutter/cupertino.dart';

import '../models/card_model.dart';
import '../models/chart_0.dart';
import '../models/chart_1.dart';
import '../models/route_arguments.dart';
import '../models/short_card_own.dart';
import '../models/user_settings.dart';

import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../texts/text_analytics_page.dart';
import 'loading_page.dart';



class Analytics extends StatefulWidget {

  final List<ShortCardOwn>? ownList;
  final UserSettings? userSettings;

  const Analytics({Key? key,
    required this.ownList,
    required this.userSettings
  }) : super(key: key);

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {

  //CopyPasted code to control handler below carousel, better to leave as is
  List<T> map<T> (List list, Function handler) {
    List<T> result = [];
    for(var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }
  //

  Color? highlightColor = Colors.deepOrangeAccent[900]!;
  String? language = 'english';//TODO
  TextAnalyticsPage textAnalyticsPage = TextAnalyticsPage();

  late Future<DocumentSnapshot> result;

  late double _width;
  List<double> listD = [];//list of points for chart M
  List<double> listM = [];//list of points for chart Y
  double sSize = 120.0;//height of chart, true value calculates later
  late double maxNumD;//maximum number of transactions in a day in selected month
  late double minNumD;//minimum number of transactions in a day in selected month
  late double scaleD;//scale for chart M
  late double averageD;//average number of transactions in selected month
  late double maxNumM;//maximum number of transactions in a month in selected year
  late double minNumM;//minimum number of transactions in a month in selected year
  late double scaleM;//scale for chart Y
  late double averageM;//average number of transactions in selected year
  int countD = 31;//number of days
  int countM = 12;//number of months
  int total = 0;//total number of transactions for selected card
  late int year;//current year (max)
  late int month;//current month (max)

  //TODO Dispose maybe, cuz it will be initialized in initState
  //List of month's names TODO should be pulled from translating function
  List<String> chartStrings = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'];
  //textAnalyticsPage.strings[language]['Main'] ??

  //holds map of allowed months for each allowed year along with numeric values
  Map<String, Map<String, dynamic>> chartAllowedMonths = {};

  late String chartM;//selected month
  late String chartY;//selected year
  List<String> chartMonths = [];//for dropdown button
  List<String> chartYears = [];//for dropdown button

  //TODO replace initial values with current, needs to be generated based on card's data
  int origin = DateTime(2018, 4, 14, 33, 13, 21, 10, 0).millisecondsSinceEpoch;
  //int origin = DateTime.now().millisecondsSinceEpoch;



  @override
  void initState() {
    super.initState();

    language = widget.userSettings?.language;
    highlightColor = widget.userSettings?.color;

    chartStrings = [
      textAnalyticsPage.strings[language]!['T00'] ?? 'January',
      textAnalyticsPage.strings[language]!['T01'] ?? 'February',
      textAnalyticsPage.strings[language]!['T02'] ?? 'March',
      textAnalyticsPage.strings[language]!['T03'] ?? 'April',
      textAnalyticsPage.strings[language]!['T04'] ?? 'May',
      textAnalyticsPage.strings[language]!['T05'] ?? 'June',
      textAnalyticsPage.strings[language]!['T06'] ?? 'July',
      textAnalyticsPage.strings[language]!['T07'] ?? 'August',
      textAnalyticsPage.strings[language]!['T08'] ?? 'September',
      textAnalyticsPage.strings[language]!['T09'] ?? 'October',
      textAnalyticsPage.strings[language]!['T10'] ?? 'November',
      textAnalyticsPage.strings[language]!['T11'] ?? 'December',
    ];
  }

  int _currentSlide = 0;

  late double width;//screen width
  late double height;//screen height
  late double _w;//TODO
  late double _h;//TODO

  bool _shouldUpdate = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }


  @override
  Widget build(BuildContext context) {

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    _w = (width * 0.6);
    _h = (height / 2.5) - (width * 0.6);

    _width = width - 40;
    sSize = height * 0.14;
    //sSize = width * 0.3;

    final _user = Provider.of<User>(context);
    final _uid = _user.uid;


    if(_shouldUpdate && widget.ownList!.isNotEmpty) {
      findOrigin(widget.ownList![_currentSlide].origin);
      result = getChartsData(widget.ownList![_currentSlide].cid);
      _shouldUpdate = false;
    }


    return SingleChildScrollView(
      child: Container(
        color: Colors.grey[900],
        child: SafeArea(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 60,//60
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width / 3,
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: Icon(Icons.help_outline, color: Colors.grey[500]),
                            onPressed: () async {
                              Navigator.of(context).pushNamed('/help_page',
                                  arguments: RouteArguments(
                                    title: 'analytics',
                                    language: language,
                                  )
                              );

                            },
                          ),
                        ),

                        Container(
                          width: width / 3,
                          alignment: Alignment.center,
                          child: Text(textAnalyticsPage.strings[language]!['T12'] ?? 'Analytics',
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        /*Container(
                          width: width / 3,
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              *//*IconButton(
                                icon: Icon(Icons.refresh, size: 20, color: Colors.white),
                                onPressed: () async {
                                  //TODO: refresh
                                  //////////////////////////////////////////
                                },
                              ),*//*
                            ],
                          ),
                        ),*/

                      ],
                    ),
                  ),
                ],
              ),
              (widget.ownList!.isNotEmpty) ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CarouselSlider.builder(
                      options: CarouselOptions(
                        height: width * 0.375,
                        disableCenter: true,
                        initialPage: _currentSlide,
                        viewportFraction: 1,
                        enableInfiniteScroll: widget.ownList!.length > 1 ? true : false,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _shouldUpdate = true;
                            _currentSlide = index;
                          });
                        },
                      ),
                      itemCount: widget.ownList!.isNotEmpty ? widget.ownList!.length : 1,
                      itemBuilder: (BuildContext context, int itemIndex, int realIndex) {
                        return CardModel(
                            color: highlightColor,
                            image: widget.ownList![_currentSlide].imgUrl,
                            title: widget.ownList![_currentSlide].globalTitle,
                            subtitle: widget.ownList![_currentSlide].author,
                            icon: const Icon(
                              Icons.share,//TODO CHANGE TO SHARE
                              color: Colors.white,
                            ),
                            privateIcon: widget.ownList![_currentSlide].private,
                            onTapIcon: () {
                              ///
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
                            onTapImage: () {
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
                          dark: false,
                          updated: false,
                        );
                      }
                  ),


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

                  //======================= Charts ==============================
                  FutureBuilder(
                      future: result,
                      builder: (context, snapshot) {

                        if (snapshot.connectionState == ConnectionState.done) {
                          dynamic snapshotData = snapshot.data;
                          prepareChartsM(year - 2000, month, snapshotData.data());
                          prepareChartsY(year - 2000, snapshotData.data());

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,//TODO
                            children: [
                              //===========================
                              //SizedBox(height: 2,),
                              Center(
                                child: TextButton(
                                  child: Text(textAnalyticsPage.strings[language]!['T13'] ?? 'View transactions',
                                    style: TextStyle(color: highlightColor, fontSize: 18),),
                                  onPressed: () {
                                    /// open transactions
                                    Navigator.of(context).pushNamed('/transactions',
                                        arguments: RouteArguments(
                                          uid: _uid,
                                          cid: widget.ownList![_currentSlide].cid,
                                          title: widget.ownList![_currentSlide].globalTitle,
                                          cont: context,
                                        )
                                    );
                                  },
                                ),
                              ),

                              //SizedBox(height: 0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text((textAnalyticsPage.strings[language]!['T14'] ?? 'Shared in total: ')+'$total',
                                        style: const TextStyle(color: Colors.white, fontSize: 16)
                                    ),
                                  ),
                                ],
                              ),

                              //Chart 0===================================
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text((textAnalyticsPage.strings[language]!['T15'] ?? 'Maximum: ')+'${maxNumD.toInt()}',
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    DropdownButton<String>(
                                      value: chartM,
                                      icon: Icon(Icons.keyboard_arrow_left, color: Colors.grey[600],),
                                      iconSize: 18,
                                      elevation: 0,
                                      dropdownColor: Colors.grey[800],
                                      style: TextStyle(color: highlightColor, fontSize: 18),
                                      underline: Container(
                                        height: 2,
                                        color: highlightColor,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          //TODO
                                          for(var i = 0; i < chartStrings.length; i++) {
                                            if(newValue == chartStrings[i]) {
                                              month = i + 1;
                                            }
                                          }
                                          chartM = newValue!;
                                        });
                                      },
                                      items: chartMonths
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: CustomPaint(
                                  size: Size(_width, sSize),
                                  painter: ChartPainter0(
                                    list: listD,
                                    average: averageD * scaleD,
                                    count: countD,
                                    color: highlightColor!,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text((textAnalyticsPage.strings[language]!['T16'] ?? 'Minimum: ')+'${minNumD.toInt()}',
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    Text((textAnalyticsPage.strings[language]!['T17'] ?? 'Average: ')+averageD.toStringAsFixed(1),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),

                              //Chart 1================================
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text((textAnalyticsPage.strings[language]!['T15'] ?? 'Maximum: ')+'${maxNumM.toInt()}',
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    DropdownButton<String>(
                                      value: chartY,
                                      icon: Icon(Icons.keyboard_arrow_left, color: Colors.grey[600],),
                                      iconSize: 18,
                                      elevation: 0,
                                      dropdownColor: Colors.grey[800],
                                      style: TextStyle(color: highlightColor, fontSize: 18),
                                      underline: Container(
                                        height: 2,
                                        color: highlightColor,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          //TODO
                                          year = int.parse(newValue!);
                                          chartY = newValue;
                                          adjustMonths(newValue);
                                        });
                                      },
                                      items: chartYears
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: CustomPaint(
                                  size: Size(_width, sSize),
                                  painter: ChartPainter1(
                                    list: listM,
                                    average: averageM * scaleM,
                                    count: countM,
                                    color: highlightColor!,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text((textAnalyticsPage.strings[language]!['T16'] ?? 'Minimum: ')+'${minNumM.toInt()}',
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    Text((textAnalyticsPage.strings[language]!['T17'] ?? 'Average: ')+averageM.toStringAsFixed(1),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          );
                        } else {
                          return Center(child: Loading(color: highlightColor!));
                        }
                      }
                  ),
                ],
              ) : Container(
                height: MediaQuery.of(context).size.height * 0.8,
                color: Colors.transparent,
                child: Center(
                  child: InkWell(
                    child: Text(textAnalyticsPage.strings[language]!['T18'] ?? 'Create new card',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  //******************* FUNCTIONS *******************

  //Determine minimum year and month
  findOrigin(int origin) {
    if(origin == null) {
      origin =  DateTime.now().millisecondsSinceEpoch;
    }
    chartYears = [];
    var minY = DateTime.fromMillisecondsSinceEpoch(origin).year;
    var maxY = DateTime.now().year;
    var minM = DateTime.fromMillisecondsSinceEpoch(origin).month;
    var maxM = DateTime.now().month;
    int min;
    int max;
    List<String> list = [];
    for(var iy = minY; iy <= maxY; iy++) {
      chartYears.add(iy.toString());
      min = iy == minY ? minM : 1;
      max = iy == maxY ? maxM : 12;
      for(var im = min; im <= max; im++) {
        list.add(chartStrings[im - 1]);
      }
      chartAllowedMonths[iy.toString()] = {
        'list': list,
        'min': min,
        'max': max,
      };
      list = [];
    }
    maxY = DateTime.now().year;
    maxM = DateTime.now().month;
    chartMonths = chartAllowedMonths[maxY.toString()]!['list'];
    chartY = maxY.toString();
    chartM = chartStrings[maxM - 1];
    year = maxY;
    month = maxM;
  }

  Future<DocumentSnapshot> getChartsData(String cid) async {
    var snapshot = await FirebaseFirestore.instance.collection('stats').doc(cid).get();
    //get total
    if(snapshot.data() != null) {
      total = snapshot.data()!['total'];
    } else {
      total = 0;
    }
    return snapshot;
  }

  prepareChartsM(int y, int m, Map<String, dynamic> snapshot) async {

    if (snapshot.isNotEmpty) {
      //get list of days
      listD = [];
      for(var d = 1; d < 32; d++) {
        if(snapshot['$y/$m/$d'] != null) {
          listD.add(snapshot['$y/$m/$d'].toDouble());
        } else {
          listD.add(0.0);
        }
      }
      //sort list
      sortChartsList(listD, 'D');
    } else {
      //populate with zero values
      listD = [];
      for(var d = 1; d < 32; d++) {
        listD.add(sSize);
      }
      scaleD = 1;
      averageD = 0;
      maxNumD = 0;
      minNumD = 0;
    }
  }

  prepareChartsY(int y, Map<String, dynamic> snapshot) async {

    if (snapshot.isNotEmpty) {
      //get list of months
      listM = [];
      var mc;
      for(var m = 1; m < 13; m++) {
        mc = 0.0;
        for(var d = 1; d < 32; d++) {
          if(snapshot['$y/$m/$d'] != null) {
            mc += snapshot['$y/$m/$d'].toDouble();
          }
        }
        listM.add(mc);
      }
      //sort lists
      sortChartsList(listM, 'M');
    } else {
      //populate with zero values
      listM = [];
      for(var m = 1; m < 13; m++) {
        listM.add(sSize);
      }
      scaleM = 1;
      averageM = 0;
      maxNumM = 0;
      minNumM = 0;
    }
  }

  sortChartsList(List<double> list, String n) {

    var scale = 1.0;
    var average = 0.0;
    var maxNum = 0.0;
    var minNum = 0.0;

    //copy and sort list
    List<double> l = [];
    list.forEach((num) {
      l.add(num);
    });
    //sort list to define the max number
    l.sort((a, b) => b.compareTo(a));
    //get max and min numbers
    maxNum = l[0];
    minNum = l[l.length - 1];
    //calculate average
    var i = list.reduce((a, b) => a + b);
    average = (i / list.length);
    //determine scale
    if(maxNum > sSize) {
      scale = sSize / maxNum;
    } else {
      if(maxNum > 0) {
        scale = (sSize / maxNum) * (0.4 + (maxNum / (sSize  * 2)));
      } else {
        scale = 1;
      }
    }
    //apply scale factor
    l = [];
    list.forEach((num) {
      l.add(num * scale);
    });
    list = l;
    //reverse values
    l = [];
    list.forEach((num) {
      l.add(sSize - num);
    });
    list = l;

    //apply to corresponding values
    switch(n) {
      case 'D':
        listD = list;
        scaleD = scale;
        averageD = average;
        maxNumD = maxNum;
        minNumD = minNum;
        break;
      case 'M':
        listM = list;
        scaleM = scale;
        averageM = average;
        maxNumM = maxNum;
        minNumM = minNum;
        break;
    }
  }

  adjustMonths(String newValue) {

    if(month < chartAllowedMonths[newValue]!['min']) {
      month = chartAllowedMonths[newValue]!['min'];
      chartM = chartStrings[month - 1];
    } else if(month > chartAllowedMonths[newValue]!['max']) {
      month = chartAllowedMonths[newValue]!['max'];
      chartM = chartStrings[month - 1];
    }
    chartMonths = chartAllowedMonths[newValue]!['list'];
  }

//*************************************************
}




Future<dynamic> _call(String _cid) async {
  try {

    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'getTransactions',
    );
    var result = await callable.call({
      'cid': _cid,
    });
    return result.data;
  } catch (e) {
    throw Future.error('error: $e');
  }
}
