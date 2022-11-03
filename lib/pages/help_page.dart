import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../texts/text_help_page.dart';

class HelpPage extends StatefulWidget {

  final String type;
  final String language;

  const HelpPage({Key? key,
    required this.type,
    required this.language
  }) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  String _title = '';
  String _url = '';

  String? language = 'english';
  TextHelpPage textHelpPage = TextHelpPage();



  @override
  void initState() {
    super.initState();

    language = widget.language;

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    switch (widget.type) {
      case 'main':
        _url = 'https://www.signmi.app/help/main';
        break;
      case 'collection':
        _url = 'https://www.signmi.app/help/collection';
        break;
      case 'analytics':
        _url = 'https://www.signmi.app/help/analytics';
        break;
      case 'editor':
        _url = 'https://www.signmi.app/help/editor';
        break;
      case 'transactions':
        _url = 'https://www.signmi.app/help/transactions';
        break;
      case 'profile':
        _url = 'https://www.signmi.app/help/profile';
        break;
      case 'share':
        _url = 'https://www.signmi.app/help/share';
        break;
      case 'add':
        _url = 'https://www.signmi.app/help/add';
        break;
      case 'settings':
        _url = 'https://www.signmi.app/help/settings';
        break;
      case 'viewer':
        _url = 'https://www.signmi.app/help/viewer';
        break;
      //default: return null;
    }

  }

  Future<void> _writeEmail() async {
    final Uri _emailUri = Uri(
        scheme: 'mailto',
        path: 'help@signmi.app',
        queryParameters: {
          'subject': 'Sent from the Signmi App'//TODO CHANGE
        }
    );
    var _url = _emailUri.toString();
    if (await canLaunchUrlString(_url)) {
      await launchUrlString(_url);
    } else {
      throw 'Could not launch help@signmi.app';
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error', style: TextStyle(color: Colors.deepOrangeAccent[400]),);
    } else {
      return const Text('');
    }
  }

  late Future<void> _launched;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(textHelpPage.strings[language]!['T00'] ?? 'Guide', overflow: TextOverflow.ellipsis,),
        actions: [
          FutureBuilder<void>(future: _launched, builder: _launchStatus),

          IconButton(icon:
          const Icon(
            Icons.email_outlined,
          ),
            onPressed: () {
              setState(() {
                _launched = _writeEmail();
              });
            },
          ),
        ],
      ),
      body: WebView(
        initialUrl: _url,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
    );
  }
}
