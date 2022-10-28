import 'package:flutter/material.dart';

import '../models/route_arguments.dart';
import '../pages/wrapper.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final RouteArguments argsE = settings.arguments as RouteArguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Wrapper());
        break;
      default: return MaterialPageRoute(builder: (_) => Wrapper());
    }
    /////////FAKE
    return MaterialPageRoute(
      builder: (_) => Container(),
    );

    // switch (settings.name) {
    //   case '/':
    //     return MaterialPageRoute(builder: (_) => Wrapper());
    //     break;
    //   case '/editor_loader':
    //     return MaterialPageRoute(
    //       builder: (_) => EditorLoader(
    //         uid: argsE.uid,
    //         cid: argsE.cid,
    //         cont: argsE.cont,
    //         link: argsE.link,
    //         colorE: argsE.color,
    //         languageE: argsE.language,
    //         cardE: argsE.cardDataPreview,
    //       ),
    //     );
    //     break;
    //   case '/viewer_loader':
    //     return MaterialPageRoute(
    //       builder: (_) => ViewerLoader(
    //         uid: argsE.uid,
    //         cid: argsE.cid,
    //         link: argsE.link,
    //         cont: argsE.cont,
    //         cardData: argsE.cardDataCollect,
    //         own: argsE.own,
    //       ),
    //     );
    //     break;
    //   case '/preview_viewer':
    //     return MaterialPageRoute(
    //       builder: (_) => Viewer(
    //         language: argsE.cid,//here it carries language
    //         color: argsE.color,
    //         //link: argsE.link,
    //         cont: argsE.cont,
    //         card: argsE.cardDataPreview,
    //         preview: argsE.preview,
    //         preImg: argsE.file,
    //       ),
    //     );
    //     break;
    //   case '/scan_module':
    //     return MaterialPageRoute(
    //       builder: (_) => ScanQR(
    //         cont: argsE.cont,
    //         collectLength: argsE.number,
    //       ),
    //     );
    //     break;
    //   case '/share_module':
    //     return MaterialPageRoute(
    //       builder: (_) => SharingModule(
    //         uid: argsE.uid,
    //         cid: argsE.cid,
    //         title: argsE.title,
    //         link: argsE.link,
    //         cont: argsE.cont,
    //         colorE: argsE.color,
    //         languageE: argsE.language,
    //       ),
    //     );
    //     break;
    //   case '/share_link_generator':
    //     return MaterialPageRoute(
    //       builder: (_) => ShareLinkGenerator(
    //         uid: argsE.uid,
    //         cid: argsE.cid,
    //         link: argsE.link,//here it carries imgUrl
    //         title: argsE.title,
    //         cont: argsE.cont,
    //         colorE: argsE.color,
    //         languageE: argsE.language,
    //       ),
    //     );
    //     break;
    //
    // //TODO: delete this?======
    //   case '/date_test':
    //     return MaterialPageRoute(
    //       builder: (_) => ControlPanel(
    //
    //       ),
    //     );
    //     break;
    //
    //   case '/prototype':
    //     return MaterialPageRoute(
    //       builder: (_) => SettingsPage(
    //
    //       ),
    //     );
    //     break;
    // //TODO====================
    //
    //   case '/transactions':
    //     return MaterialPageRoute(
    //       builder: (_) => ViewTransactions(
    //         uid: argsE.uid,
    //         cid: argsE.cid,
    //         title: argsE.title,
    //         cont: argsE.cont,
    //       ),
    //     );
    //     break;
    //   case '/other_profile':
    //     return MaterialPageRoute(
    //       builder: (_) => ProfilePageLoader(
    //         target: argsE.uid,//here it carries uid of a target profile
    //         cid: argsE.cid,
    //         cont: argsE.cont,
    //       ),
    //     );
    //     break;
    //   case '/settings':
    //     return MaterialPageRoute(
    //       builder: (_) => SettingsPage(
    //         uid: argsE.uid,
    //         cont: argsE.cont,
    //       ),
    //     );
    //     break;
    //   case '/terms':
    //     return MaterialPageRoute(
    //       builder: (_) => TermsAndPolicyPage(
    //         language: argsE.link,//here it carries language string
    //         cont: argsE.cont,
    //       ),
    //     );
    //     break;
    //   case '/adding_card':
    //     return MaterialPageRoute(
    //       builder: (_) => AddingCard(
    //         source: argsE.uid,//here it carries source
    //         cid: argsE.cid,
    //         link: argsE.link,
    //         cont: argsE.cont,
    //         uid: argsE.title,//here it carries uid
    //         collectCardNum: argsE.number,//here it carries collectCardList.length
    //       ),
    //     );
    //     break;
    //   case '/help_page':
    //     return MaterialPageRoute(
    //       builder: (_) => HelpPage(
    //         type: argsE.title,//here it carries type
    //         language: argsE.language,
    //       ),
    //     );
    //     break;
    //   default: return MaterialPageRoute(builder: (_) => Wrapper());
    // }
  }
}