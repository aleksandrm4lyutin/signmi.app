import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../functions/data_services/delete_collect_cards.dart';
import '../models/card_model.dart';
import '../models/route_arguments.dart';
import '../models/short_card_collect.dart';
import '../models/user_settings.dart';
import '../texts/text_home_page_collection.dart';
import 'data_holder.dart';


class Collection extends StatefulWidget {

  final List<ShortCardCollect>? collectList;
  final UserSettings? userSettings;//TODO replace with color and language?

  const Collection({Key? key,
    this.collectList,
    this.userSettings
  }) : super(key: key);


  @override
  _CollectionState createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {




  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _txtController = TextEditingController();
    _scrollController0 = ScrollController();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    //TODO try to add tab controller to remember selected tab
    _runOnce = true;

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //Update lists for Collection Page only when needed
    if(_runOnce) {
      _source_0 = [];
      _source_1 = [];
      _source_2 = [];
      readFavorites().then((List<String> list) {
        _temp_1 = list;
      });
      readArchive().then((List<String> list) {
        _temp_2 = list;
      });

      initLists();

      _search_0 = _source_0;
      _search_1 = _source_1;
      _search_2 = _source_2;

      setState(() {
        refreshLists();
        _runOnce = false;
      });

      language = widget.userSettings?.language ?? 'english';
      highlightColor = widget.userSettings?.color ?? Colors.deepOrangeAccent[900];
    }
  }

  @override
  void dispose() {

    _focusNode.dispose();
    _txtController.dispose();
    _scrollController0.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();

    super.dispose();
  }

  late FocusNode _focusNode;
  late TextEditingController _txtController;
  late ScrollController _scrollController0;
  late ScrollController _scrollController1;
  late ScrollController _scrollController2;

  bool _runOnce = false;

  bool _isSearch = false;
  bool _isSelect = false;
  bool _isAllSelected = false;
  bool _isShuffle = false;

  int _tabIndex = 0;

  List<String> _initialList = [];

  List<String> _temp_1 = [];
  List<String> _temp_2 = [];
  //List.generate(500, (i) => '$i${100 * (i % 9)}');
  List<ShortCardCollect> _source_0 = [];
  List<ShortCardCollect> _source_1 = [];
  List<ShortCardCollect> _source_2 = [];

  List<ShortCardCollect> _search_0 = [];
  List<ShortCardCollect> _search_1 = [];
  List<ShortCardCollect> _search_2 = [];
  List<ShortCardCollect> _list_0 = [];
  List<ShortCardCollect> _list_1 = [];
  List<ShortCardCollect> _list_2 = [];

  int _offset_0 = 0;
  int _offset_1 = 0;
  int _offset_2 = 0;

  final int _buffer = 300;//How many cards can be shown at a time in collection page//TODO!

  List<String> _selected = [];

  Color? highlightColor = Colors.deepOrangeAccent[400];
  String? language = 'english';//TODO
  TextHomePageCollection textHomePageCollection = TextHomePageCollection();

  //READ AND WRITE TO FILE
  Future<List<String>> readFavorites() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/favorites.txt');
      String contents = await file.readAsString();
      final list = contents.split('/');
      return list;
    } catch(e) {
      return [];
    }
  }

  Future<List<String>> readArchive() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/archive.txt');
      String contents = await file.readAsString();
      final list = contents.split('/');
      return list;
    } catch(e) {
      return [];
    }
  }

  //TODO REMAKE THIS IF IT DOESNT WORK

  Future<File> writeFavorites() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/favorites.txt');
    List<String> list;
    list = _source_1.map((card) => card.cid).toList();
    final contents = list.join('/');
    return file.writeAsString(contents);
  }

  Future<File> writeArchive() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/archive.txt');
    List<String> list;
    list = _source_2.map((card) => card.cid).toList();
    final contents = list.join('/');
    return file.writeAsString(contents);
  }

  selectSingle(String _cid, int _index) {
    if (_index == 0) {
      _source_0.forEach((card) {
        if (card.cid == _cid) {
          if (card.selected) {
            card.selected = false;
            _selected.removeWhere((e) => e == card.cid);
          } else {
            card.selected = true;
            _selected.add(card.cid);
          }
        }
      });
    } else if (_index == 1) {
      _source_1.forEach((card) {
        if (card.cid == _cid) {
          if (card.selected) {
            card.selected = false;
            _selected.removeWhere((e) => e == card.cid);
          } else {
            card.selected = true;
            _selected.add(card.cid);
          }
        }
      });
    } else {
      _source_2.forEach((card) {
        if (card.cid == _cid) {
          if (card.selected) {
            card.selected = false;
            _selected.removeWhere((cid) => cid == card.cid);
          } else {
            card.selected = true;
            _selected.add(card.cid);
          }
        }
      });
    }
  }

  selectAll(bool _bool, int _index) {
    _selected = [];
    if(_index == 0) {
      if(_bool) {
        _search_0.forEach((card) {
          card.selected = true;
          _selected.add(card.cid);
        });
      } else {
        _search_0.forEach((card) {
          card.selected = false;
        });
      }
    } else if(_index == 1) {
      if(_bool) {
        _search_1.forEach((card) {
          card.selected = true;
          _selected.add(card.cid);
        });
      } else {
        _search_1.forEach((card) {
          card.selected = false;
        });
      }
    } else {
      if(_bool) {
        _search_2.forEach((card) {
          card.selected = true;
          _selected.add(card.cid);
        });
      } else {
        _search_2.forEach((card) {
          card.selected = false;
        });
      }
    }
    _isAllSelected = _bool;
  }

  deleteSelected(int _index, String _uid, BuildContext cont) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => SimpleDialog(
          //TODO: remove title? (unused)
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[

            ],
          ),
          titlePadding: const EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          children: <Widget>[
            Center(
                child: Icon(Icons.delete, color: highlightColor, size: 50,)
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(child: Text((textHomePageCollection.strings[language]!['T00']
                  ?? 'Do you really want to delete selected cards? ')+'(${_selected.length})',
                style: const TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  child: Row(
                    children: [
                      Text(textHomePageCollection.strings[language]!['T01'] ?? 'Cancel',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 2,),
                      const Icon(Icons.clear),
                    ],
                  ),
                  onPressed: () async {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  child: Row(
                    children: [
                      Text(textHomePageCollection.strings[language]!['T02'] ?? 'Delete',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 2,),
                      const Icon(Icons.delete),
                    ],
                  ),
                  onPressed: () async {
                    if(_index == 0) {
                      _selected.forEach((cid) {
                        _source_0.removeWhere((card) => card.cid == cid);
                        _list_0.removeWhere((card) => card.cid == cid);
                        _initialList.removeWhere((c) => c == cid);
                      });
                    } else if(_index == 1) {
                      _selected.forEach((cid) {
                        _source_1.removeWhere((card) => card.cid == cid);
                        _list_1.removeWhere((card) => card.cid == cid);
                        _initialList.removeWhere((c) => c == cid);
                      });
                    } else {
                      _selected.forEach((cid) {
                        _source_2.removeWhere((card) => card.cid == cid);
                        _list_2.removeWhere((card) => card.cid == cid);
                        _initialList.removeWhere((c) => c == cid);
                      });
                    }

                    await deleteCollectCards(_uid, _selected, _initialList);
                    DataHolder.of(cont)?.refreshCollect();
                    _selected = [];
                    refreshLists();
                    _isSelect = false;

                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ],
        )
    );
  }


  refreshLists() {
    if(_search_0.length > _buffer) {
      _list_0 = _search_0.getRange(0, _buffer).toList();
      _offset_0 = _buffer;
    } else {
      _list_0 = _search_0;
      _offset_0 = _search_0.length;
    }

    if(_search_1.length > _buffer) {
      _list_1 = _search_1.getRange(0, _buffer).toList();
      _offset_1 = _buffer;
    } else {
      _list_1 = _search_1;
      _offset_1 = _search_1.length;
    }

    if(_search_2.length > _buffer) {
      _list_2 = _search_2.getRange(0, _buffer).toList();
      _offset_2 = _buffer;
    } else {
      _list_2 = _search_2;
      _offset_2 = _search_2.length;
    }
  }
  dismissSearch() {
    _txtController.clear();
    _search_0 = _source_0;
    _search_1 = _source_1;
    _search_2 = _source_2;
    _isSearch = false;
    refreshLists();
    FocusScope.of(context).unfocus();
  }

  applySearch(String val) {
    if(val.isNotEmpty) {
      _search_0 = _source_0.where((card) => card.globalTitle.toLowerCase().contains(val.toLowerCase()) || card.author.toLowerCase().contains(val.toLowerCase())).toList();
      _search_1 = _source_1.where((card) => card.globalTitle.toLowerCase().contains(val.toLowerCase()) || card.author.toLowerCase().contains(val.toLowerCase())).toList();
      _search_2 = _source_2.where((card) => card.globalTitle.toLowerCase().contains(val.toLowerCase()) || card.author.toLowerCase().contains(val.toLowerCase())).toList();
    } else {
      _search_0 = _source_0;
      _search_1 = _source_1;
      _search_2 = _source_2;
    }
    refreshLists();
  }

  initLists() {
    widget.collectList?.forEach((card) {
      _initialList.add(card.cid);
      if(_temp_1.contains(card.cid)) {
        _source_1.add(card);
      } else if(_temp_2.contains(card.cid)) {
        _source_2.add(card);
      } else {
        _source_0.add(card);
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    final _user = Provider.of<User>(context);
    final _uid = _user.uid;

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            //==================================== TOP BAR =========================
            Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.help_outline,
                            color: Colors.grey[500],),
                          onPressed: () {

                            Navigator.of(context).pushNamed('/help_page',
                                arguments: RouteArguments(
                                  title: 'collection',
                                  language: language,
                                )
                            );

                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.search,
                            color: _isSearch ? highlightColor : Colors.white,),
                          onPressed: () {
                            if(_isSearch) {
                              setState(() {
                                dismissSearch();
                              });
                            } else {
                              setState(() {
                                _isSearch = true;
                                _focusNode.requestFocus();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 60,
                    alignment: Alignment.center,
                    child: _isSearch ? TextField(
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: highlightColor, fontSize: 16),
                      onEditingComplete: () {
                        setState(() {
                          _isSearch = false;
                          refreshLists();
                        });
                      },
                      focusNode: _focusNode,
                      maxLength: 33,//TODO: adjust
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: _txtController,
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: highlightColor),
                        contentPadding: const EdgeInsets.only(top: 10.0),
                        hintStyle: TextStyle(color: highlightColor),
                        hintText: textHomePageCollection.strings[language]!['T03'] ?? 'Search...',//'Searching for...'
                        //helperText: 'Helper Text',

                        border: InputBorder.none,
                        labelText: '',
                      ),
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      maxLines: 1,
                      onChanged: (val) {
                        setState(() {
                          applySearch(val);
                        });
                      },
                    ) : Text(textHomePageCollection.strings[language]!['T04'] ?? 'Collection',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _isSearch ? IconButton(
                          color: highlightColor,
                          icon: const Icon(Icons.clear,),
                          onPressed: () {
                            setState(() {
                              dismissSearch();
                            });
                          },
                          disabledColor: Colors.transparent,
                        ) : IconButton(
                          color: _isShuffle ? highlightColor : Colors.white,
                          icon: const Icon(Icons.swap_horiz,),
                          onPressed: () {
                            setState(() {
                              selectAll(false, _tabIndex);
                              _isSelect = false;
                              if(_isShuffle) {
                                _isShuffle = false;
                              } else {
                                _isShuffle = true;
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: _isSelect ? highlightColor : Colors.white),
                          onPressed: () {
                            setState(() {
                              selectAll(false, _tabIndex);
                              if(_isShuffle) {
                                _isShuffle = false;
                              }
                              if(_isSelect) {
                                _isSelect = false;
                              } else {
                                _isSelect = true;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            //_____________________________________________________________
            _isSelect ? SizedBox(
              height: 48.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        child: _isAllSelected ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.check_box, color: highlightColor,),
                            Text(textHomePageCollection.strings[language]!['T05'] ?? 'Deselect',//'Select none'
                              style: TextStyle(color: highlightColor),
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ) : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.check_box_outline_blank, color: highlightColor,),
                            Text(textHomePageCollection.strings[language]!['T06'] ?? 'Select all',//'Select all'
                              style: TextStyle(color: highlightColor),
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            if(_isAllSelected) {
                              selectAll(false, _tabIndex);
                            } else {
                              selectAll(true, _tabIndex);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.clear, color: highlightColor,),
                            Text(textHomePageCollection.strings[language]!['T01'] ?? 'Cancel',//'Cancel'
                              style: TextStyle(color: highlightColor),
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            selectAll(false, _tabIndex);
                            _isSelect = false;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.delete, color: highlightColor,),
                            Text((textHomePageCollection.strings[language]!['T02'] ?? 'Delete')+'(${_selected.length})',//'Delete'
                              style: TextStyle(color: highlightColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        onTap: () {
                          if(_selected.isNotEmpty) {
                            deleteSelected(_tabIndex, _uid, context);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ) : TabBar(
              onTap: (_tab) {
                setState(() {
                  _tabIndex = _tab;
                });
              },
              indicatorColor: highlightColor,
              labelColor: _isShuffle ? highlightColor : Colors.white,
              unselectedLabelColor: _isShuffle ? highlightColor : Colors.grey,
              isScrollable: false,
              tabs: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Tab(
                    text: textHomePageCollection.strings[language]!['T07'] ?? 'Main',//'Favorites'
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Tab(
                    text: textHomePageCollection.strings[language]!['T08'] ?? 'Favorites',//'Main'
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Tab(
                    text: textHomePageCollection.strings[language]!['T09'] ?? 'Archive',//'Archive'
                  ),
                ),
              ],
            ),
            ////\\\\////\\\\////\\\\////\\\\////\\\\////\\\\////\\\\////\\\\////\\\\
            Expanded(
              child: TabBarView(
                physics: _isShuffle || _isSelect ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                children: [
                  //=================================================================
                  //                    MAIN TAB 0
                  //=================================================================
                  NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      //scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
                      //_scrCntr.offset >= _scrCntr.position.maxScrollExtent && !_scrCntr.position.outOfRange
                      if (_scrollController0.offset >= _scrollController0.position.maxScrollExtent && !_scrollController0.position.outOfRange) {
                        if((_offset_0 + _buffer) > _search_0.length) {
                          setState(() {
                            _list_0.addAll(_search_0.getRange(_offset_0, _search_0.length));
                            _offset_0 = _search_0.length;
                          });
                        } else {
                          setState(() {
                            _list_0.addAll(_search_0.getRange(_offset_0, _offset_0 + _buffer));
                            _offset_0 = _offset_0 + _buffer;
                          });
                        }
                      } //else if (_scrCntr.offset <= _scrCntr.position.minScrollExtent && !_scrCntr.position.outOfRange) {
                      //here we detect uper overscroll
                      //}
                      return true;
                    },
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,//TODO: true??
                      //cacheExtent: 25
                      controller: _scrollController0,
                      physics: const BouncingScrollPhysics(),
                      //itemCount: _list.length + 1,
                      itemCount: _list_0.isNotEmpty ? _list_0.length + 1 : 1,
                      itemBuilder: (context, index) {
                        if(_list_0.isNotEmpty) {
                          if(index >= _list_0.length) {
                            return ((_offset_0 + _buffer) < _search_0.length)
                                ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: const Text(''),
                                title: Center(
                                  child: Text(textHomePageCollection.strings[language]!['T10'] ?? 'Loading...',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),//'Loading...'
                                trailing: const Text(''),
                              ),
                            )
                                : Divider(
                              color: Colors.grey[800],
                              height: 30,
                              thickness: 2,
                              endIndent: 20,
                              indent: 20,
                            );
                          } else {
                            /// /////////////////////////////////////////////
                            return _isShuffle ? Dismissible(

                              key: Key(_list_0[index].cid + '0'),
                              child: CardModel(
                                color: highlightColor,
                                image: _list_0[index].imgUrl,
                                title: _list_0[index].globalTitle,
                                subtitle: _list_0[index].author,
                                icon: Icon(
                                  Icons.swap_horiz,
                                  color: highlightColor,
                                ),
                                onTapIcon: null,
                                dark: false,
                                onTapImage: null,
                                updated: false,
                                privateIcon: false,
                              ),
                              background: Container(
                                color: highlightColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(textHomePageCollection.strings[language]!['T11']
                                          ?? 'Move to Favorites',
                                        style: const TextStyle(color: Colors.white),
                                      ),//'Move to Main'
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: highlightColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    const Icon(Icons.arrow_back_ios, color: Colors.white),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(textHomePageCollection.strings[language]!['T12']
                                          ?? 'Move to Archive',
                                        style: const TextStyle(color: Colors.white),
                                      ),//'Move to Archive'
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (direction) {
                                var _i = _source_0.indexWhere((e) => e.cid == _list_0[index].cid);
                                if (direction == DismissDirection.startToEnd) {
                                  //%%%%%%%% MOVE CARD TO MAIN >>>>>>>>>
                                  _source_1.insert(0, _source_0[_i]);
                                  _search_1 = _source_1;
                                  writeFavorites();
                                } else if (direction == DismissDirection.endToStart) {
                                  //%%%%%%%% MOVE CARD TO ARCHIVE <<<<<<<<<
                                  _source_2.insert(0, _source_0[_i]);
                                  _search_2 = _source_2;
                                  writeArchive();
                                  writeFavorites();
                                }
                                _source_0.removeAt(_i);
                                _search_0 = _source_0;
                                //_list_0.removeAt(index);
                                setState(() {
                                  applySearch(_txtController.text);
                                });
                              },
                              dismissThresholds: const {
                                DismissDirection.startToEnd: 0.69,
                                DismissDirection.endToStart: 0.69
                              },
                            ) : CardModel(
                              color: highlightColor,
                              updated: _list_0[index].updated,
                              image: _list_0[index].imgUrl,
                              title: _list_0[index].globalTitle,
                              subtitle: _list_0[index].author,
                              icon: !_isSelect ? _list_0[index].private ? Icon(
                                Icons.lock, color: Colors.grey[600],
                              ) : const Icon(
                                Icons.share, color: Colors.white,
                              ) : _list_0[index].selected ? Icon(Icons.check_box,
                                color: highlightColor,) : Icon(Icons.check_box_outline_blank,
                                color: highlightColor,),
                              onTapIcon: !_isSelect ? _list_0[index].private ? () {
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
                                            Icons.lock,
                                            color: highlightColor,
                                            size: 50,
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Text(
                                              textHomePageCollection.strings[language]!['T13']
                                                  ?? 'Private card can be shared only by its owner',
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
                                              child: Text(textHomePageCollection.strings[language]!['T14'] ?? 'Ok',
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
                              } : () {
                                Navigator.of(context).pushNamed('/share_module',
                                    arguments: RouteArguments(
                                      uid: _uid,
                                      cid: _list_0[index].cid,
                                      title: _list_0[index].globalTitle,
                                      link: _list_0[index].link,
                                      cont: context,
                                    )
                                );
                              } : () {
                                setState(() {
                                  selectSingle(_list_0[index].cid, _tabIndex);
                                });
                              },
                              onTapImage: !_isSelect ? () {
                                Navigator.of(context).pushNamed('/viewer_loader',
                                    arguments: RouteArguments(
                                      uid: _uid,
                                      cid: _list_0[index].cid,
                                      link: _list_0[index].link,
                                      cont: context,
                                      cardDataCollect: _list_0[index],
                                    )
                                );
                              } : null,
                              dark: false,
                              privateIcon: false,
                            );
                          }
                        } else {
                          if(_source_0.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(textHomePageCollection.strings[language]!['T15']
                                    ?? 'This collection is empty',
                                  style: const TextStyle(color: Colors.grey),
                                ),//'This collection is empty'
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(textHomePageCollection.strings[language]!['T16']
                                    ?? 'The search gave no results',
                                  style: const TextStyle(color: Colors.grey),
                                ),//'Search gave no results'
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  //=================================================================
                  //                    FAVORITE TAB
                  //=================================================================
                  NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      //scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
                      //_scrCntr.offset >= _scrCntr.position.maxScrollExtent && !_scrCntr.position.outOfRange
                      if (_scrollController1.offset >= _scrollController1.position.maxScrollExtent && !_scrollController1.position.outOfRange) {
                        if((_offset_1 + _buffer) > _search_1.length) {
                          setState(() {
                            _list_1.addAll(_search_1.getRange(_offset_1, _search_1.length));
                            _offset_1 = _search_1.length;
                          });
                        } else {
                          setState(() {
                            _list_1.addAll(_search_1.getRange(_offset_1, _offset_1 + _buffer));
                            _offset_1 = _offset_1 + _buffer;
                          });
                        }
                      } //else if (_scrCntr.offset <= _scrCntr.position.minScrollExtent && !_scrCntr.position.outOfRange) {
                      //here we detect uper overscroll
                      //}
                      return true;
                    },
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,
                      //cacheExtent: 25
                      controller: _scrollController1,
                      physics: const BouncingScrollPhysics(),
                      //itemCount: _list.length + 1,
                      itemCount: _list_1.isNotEmpty ? _list_1.length + 1 : 1,
                      itemBuilder: (context, index) {
                        if(_list_1.isNotEmpty) {
                          if(index >= _list_1.length) {
                            return ((_offset_1 + _buffer) < _search_1.length)
                                ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: const Text(''),
                                title: Center(
                                  child: Text(textHomePageCollection.strings[language]!['T10'] ?? 'Loading...',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),//'Loading...'
                                trailing: const Text(''),
                              ),
                            )
                                : Divider(
                              color: Colors.grey[800],
                              height: 30,
                              thickness: 2,
                              endIndent: 20,
                              indent: 20,
                            );
                          } else {

                            /// /////////////////////////////////////////////
                            return _isShuffle ? Dismissible(

                              key: Key(_list_1[index].cid + '0'),
                              child: CardModel(
                                color: highlightColor,
                                image: _list_1[index].imgUrl,
                                title: _list_1[index].globalTitle,
                                subtitle: _list_1[index].author,
                                icon: Icon(
                                  Icons.swap_horiz,
                                  color: highlightColor,
                                ),
                                onTapIcon: null,
                                dark: false,
                                privateIcon: false,
                                onTapImage: null,
                                updated: false,
                              ),
                              background: Container(
                                color: highlightColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(textHomePageCollection.strings[language]!['T12'] ?? 'Move to Archive',
                                        style: const TextStyle(color: Colors.white),
                                      ),//'Move to Main'
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: highlightColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    const Icon(Icons.arrow_back_ios, color: Colors.white),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(textHomePageCollection.strings[language]!['T17'] ?? 'Move to Main',
                                        style: const TextStyle(color: Colors.white),
                                      ),//'Move to Archive'
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (direction) {
                                var _i = _source_1.indexWhere((e) => e.cid == _list_1[index].cid);
                                if (direction == DismissDirection.startToEnd) {
                                  //%%%%%%%% MOVE CARD TO ARCHIVE >>>>>>>>>
                                  _source_2.insert(0, _source_1[_i]);
                                  _search_2 = _source_2;
                                  writeArchive();
                                } else if (direction == DismissDirection.endToStart) {
                                  //%%%%%%%% MOVE CARD TO FAVORITES <<<<<<<<<
                                  _source_0.insert(0, _source_1[_i]);
                                  _search_0 = _source_0;
                                  writeFavorites();
                                }
                                _source_1.removeAt(_i);
                                _search_1 = _source_1;
                                //_list_1.removeAt(index);
                                setState(() {
                                  applySearch(_txtController.text);
                                });
                              },
                              dismissThresholds: const {
                                DismissDirection.startToEnd: 0.69,
                                DismissDirection.endToStart: 0.69
                              },
                            ) : CardModel(
                              color: highlightColor,
                              updated: _list_1[index].updated,
                              image: _list_1[index].imgUrl,
                              title: _list_1[index].globalTitle,
                              subtitle: _list_1[index].author,
                              icon: !_isSelect ? _list_1[index].private ? Icon(
                                Icons.lock, color: Colors.grey[600],
                              ) : const Icon(
                                Icons.share, color: Colors.white,
                              ) : _list_1[index].selected ? Icon(Icons.check_box,
                                color: highlightColor,) : Icon(Icons.check_box_outline_blank,
                                color: highlightColor,),
                              onTapIcon: !_isSelect ? _list_1[index].private ? () {
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
                                            Icons.lock,
                                            color: highlightColor,
                                            size: 50,
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Text(
                                              textHomePageCollection.strings[language]!['T13']
                                                  ?? 'Private card can be shared only by its owner',
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
                                              child: Text(textHomePageCollection.strings[language]!['T14'] ?? 'Ok',
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
                              } : () {
                                Navigator.of(context).pushNamed('/share_module',
                                    arguments: RouteArguments(
                                      uid: _uid,
                                      cid: _list_1[index].cid,
                                      title: _list_1[index].globalTitle,
                                      link: _list_1[index].link,
                                      cont: context,
                                    )
                                );
                              } : () {
                                setState(() {
                                  selectSingle(_list_1[index].cid, _tabIndex);
                                });
                              },
                              onTapImage: !_isSelect ? () {
                                Navigator.of(context).pushNamed('/viewer_loader',
                                    arguments: RouteArguments(
                                      uid: _uid,
                                      cid: _list_1[index].cid,
                                      link: _list_1[index].link,
                                      cont: context,
                                      cardDataCollect: _list_1[index],
                                    )
                                );
                              } : null,
                              dark: false,
                              privateIcon: false,
                            );
                          }
                        } else {
                          if(_source_1.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(textHomePageCollection.strings[language]!['T15'] ?? 'This collection is empty',
                                  style: const TextStyle(color: Colors.grey),
                                ),//'This collection is empty'
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(textHomePageCollection.strings[language]!['T16']
                                    ?? 'The search gave no results',
                                  style: const TextStyle(color: Colors.grey),
                                ),//'Search gave no results'
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  //=================================================================
                  //                    ARCHIVE TAB
                  //=================================================================
                  NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      //scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
                      //_scrCntr.offset >= _scrCntr.position.maxScrollExtent && !_scrCntr.position.outOfRange
                      if (_scrollController2.offset >= _scrollController2.position.maxScrollExtent && !_scrollController2.position.outOfRange) {
                        if((_offset_2 + _buffer) > _search_2.length) {
                          setState(() {
                            _list_2.addAll(_search_2.getRange(_offset_2, _search_2.length));
                            _offset_2 = _search_2.length;
                          });
                        } else {
                          setState(() {
                            _list_2.addAll(_search_2.getRange(_offset_2, _offset_2 + _buffer));
                            _offset_2 = _offset_2 + _buffer;
                          });
                        }
                      } //else if (_scrCntr.offset <= _scrCntr.position.minScrollExtent && !_scrCntr.position.outOfRange) {
                      //here we detect uper overscroll
                      //}
                      return true;
                    },
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,
                      //cacheExtent: 25
                      controller: _scrollController2,
                      physics: const BouncingScrollPhysics(),
                      //itemCount: _list.length + 1,
                      itemCount: _list_2.isNotEmpty ? _list_2.length + 1 : 1,
                      itemBuilder: (context, index) {
                        if(_list_2.isNotEmpty) {
                          if(index >= _list_2.length) {
                            return ((_offset_2 + _buffer) < _search_2.length)
                                ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: const Text(''),
                                title: Center(
                                  child: Text(textHomePageCollection.strings[language]!['T10'] ?? 'Loading...',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),//'Loading...'
                                trailing: const Text(''),
                              ),
                            )
                                : Divider(
                              color: Colors.grey[800],
                              height: 30,
                              thickness: 2,
                              endIndent: 20,
                              indent: 20,
                            );
                          } else {
                            /// /////////////////////////////////////////////
                            return _isShuffle ? Dismissible(

                              key: Key(_list_2[index].cid + '0'),
                              child: CardModel(
                                color: highlightColor,
                                image: _list_2[index].imgUrl,
                                title: _list_2[index].globalTitle,
                                subtitle: _list_2[index].author,
                                icon: Icon(
                                  Icons.swap_horiz,
                                  color: highlightColor,
                                ),
                                onTapIcon: null,
                                dark: false,
                                privateIcon: false,
                                onTapImage: null,
                                updated: false,
                              ),
                              background: Container(
                                color: highlightColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(textHomePageCollection.strings[language]!['T17']
                                          ?? 'Move to Main',
                                        style: const TextStyle(color: Colors.white),
                                      ),//'Move to Main'
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: highlightColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    const Icon(Icons.arrow_back_ios, color: Colors.white),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(textHomePageCollection.strings[language]!['T11']
                                          ?? 'Move to Favorites',
                                        style: const TextStyle(color: Colors.white),
                                      ),//'Move to Archive'
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (direction) {
                                var _i = _source_2.indexWhere((e) => e.cid == _list_2[index].cid);
                                if (direction == DismissDirection.startToEnd) {
                                  //%%%%%%%% MOVE CARD TO FAVORITES >>>>>>>>>
                                  _source_0.insert(0, _source_2[_i]);
                                  _search_0 = _source_0;
                                  writeFavorites();
                                  writeArchive();
                                } else if (direction == DismissDirection.endToStart) {
                                  //%%%%%%%% MOVE CARD TO MAIN <<<<<<<<<
                                  _source_1.insert(0, _source_2[_i]);
                                  _search_1 = _source_1;
                                  writeArchive();
                                }
                                _source_2.removeAt(_i);
                                _search_2 = _source_2;
                                //_list_2.removeAt(index);
                                setState(() {
                                  applySearch(_txtController.text);
                                });
                              },
                              dismissThresholds: const {
                                DismissDirection.startToEnd: 0.69,
                                DismissDirection.endToStart: 0.69
                              },
                            ) : CardModel(
                              color: highlightColor,
                              updated: _list_2[index].updated,
                              image: _list_2[index].imgUrl,
                              title: _list_2[index].globalTitle,
                              subtitle: _list_2[index].author,
                              icon: !_isSelect ? _list_2[index].private ? Icon(
                                Icons.lock, color: Colors.grey[600],
                              ) : const Icon(
                                Icons.share, color: Colors.white,
                              ) : _list_2[index].selected ? Icon(Icons.check_box,
                                color: highlightColor,) : Icon(Icons.check_box_outline_blank,
                                color: highlightColor,),
                              onTapIcon: !_isSelect ? _list_2[index].private ? () {
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
                                            Icons.lock,
                                            color: highlightColor,
                                            size: 50,
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Text(
                                              textHomePageCollection.strings[language]!['T13']
                                                  ?? 'Private card can be shared only by its owner',
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
                                              child: Text(textHomePageCollection.strings[language]!['T14'] ?? 'Ok',
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
                              } : () {
                                Navigator.of(context).pushNamed('/share_module',
                                    arguments: RouteArguments(
                                      uid: _uid,
                                      cid: _list_2[index].cid,
                                      title: _list_2[index].globalTitle,
                                      link: _list_2[index].link,
                                      cont: context,
                                    )
                                );
                              } : () {
                                setState(() {
                                  selectSingle(_list_2[index].cid, _tabIndex);
                                });
                              },
                              onTapImage: !_isSelect ? () {
                                Navigator.of(context).pushNamed('/viewer_loader',
                                    arguments: RouteArguments(
                                      uid: _uid,
                                      cid: _list_2[index].cid,
                                      link: _list_2[index].link,
                                      cont: context,
                                      cardDataCollect: _list_2[index],
                                    )
                                );
                              } : null,
                              dark: false,
                              privateIcon: false,
                            );
                          }
                        } else {
                          if(_source_2.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(textHomePageCollection.strings[language]!['T15']
                                    ?? 'This collection is empty', style: const TextStyle(color: Colors.grey),),//'This collection is empty'
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(textHomePageCollection.strings[language]!['T16']
                                    ?? 'The search gave no results',
                                  style: const TextStyle(color: Colors.grey),
                                ),//'Search gave no results'
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}