import 'dart:core';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import '../../shared/web_info.dart';

/// Функция генерирует динамическую ссылку карточки использую параметры: cid, key, source, globalTitle, author, imgUrl

Future<String> generateLink(String _cid, String _key, String _source, String _globalTitle, String _author, String _imgUrl) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: WebInfo().uriPrefix,
    link: Uri.parse(
      ///Шаблон для построения ссылки
      ///'${WebInfo().website}/sharedlink?link=$_cid??$_key??$_source'),
        '${WebInfo().website}/?link=$_cid??$_key??$_source'),
    androidParameters: const AndroidParameters(
      packageName: 'sssl4yer.dejitarumeishiapp',
      minimumVersion: 0, //TODO---
    ),
    // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
    //   shortDynamicLinkPathLength: ShortDynamicLinkPathLength
    //       .short,
    // ),
    iosParameters: const IOSParameters(
      bundleId: '',
      //TODO---
      minimumVersion: '0', //TODO---
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: _globalTitle,
      description: _author,
      imageUrl: Uri.parse(_imgUrl),
    ),
  );
  Uri _uri;
  final ShortDynamicLink _shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  _uri = _shortLink.shortUrl;
  var _link = _uri.toString();
  return _link;
}
