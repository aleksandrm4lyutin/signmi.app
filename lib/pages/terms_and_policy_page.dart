import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../functions/authservice.dart';
import '../texts/text_terms_and_policiy_page.dart';



class TermsAndPolicyPage extends StatefulWidget {

  final String language;
  final BuildContext cont;

  const TermsAndPolicyPage({Key? key,
    required this.language,
    required this.cont
  }) : super(key: key);

  @override
  _TermsAndPolicyPageState createState() => _TermsAndPolicyPageState();
}

class _TermsAndPolicyPageState extends State<TermsAndPolicyPage> {

  @override
  void initState() {
    super.initState();

    termsTxt = loadTerms(widget.language);
    language = widget.language;
  }

  final AuthService _auth = AuthService();

  late Future<String?> termsTxt;

  dynamic snapshotData;

  String? language;
  TextTermsAndPolicyPage textTermsAndPolicyPage = TextTermsAndPolicyPage();

  final passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(textTermsAndPolicyPage.strings[language]!['T01'] ?? 'Terms and Policies'),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              FutureBuilder(
                  future: termsTxt,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if(snapshot.data != null) {
                        snapshotData = snapshot.data;
                        return Text(snapshotData ?? 'no data');
                      } else {
                        return Column(
                          children: [
                            Text(textTermsAndPolicyPage.strings[language]!['T02']
                                ?? 'Please check your internet connection and try again'),
                          ],
                        );
                      }
                    } else {
                      return SpinKitDualRing(
                        size: 40,
                        color: Colors.deepOrangeAccent[400]!,
                      );
                    }
                    //return null;
                  }
              ),
              const SizedBox(height: 40,),

              InkWell(
                child: Text(textTermsAndPolicyPage.strings[language]!['T03'] ?? 'Revoke your consent and delete account',
                  style: TextStyle(color: Colors.deepOrangeAccent[400], fontSize: 16),
                ),
                onTap: () {
                  ///XXXXXXXXXXXXXXXXXXX DELETE USER XXXXXXXXXXXXXXXXXXXX
                  /////TODO ADD USER TO THE LIST FOR CLEANING FUNCTION
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context1) => SimpleDialog(
                      title: Center(
                        child: Text(textTermsAndPolicyPage.strings[language]!['T04'] ?? 'Deleting account',
                          style: const TextStyle(fontSize: 20),),
                      ),
                      titlePadding: const EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      children: <Widget>[
                        Center(
                          child: Icon(
                            Icons.report,
                            size: 40,
                            color: Colors.deepOrangeAccent[400],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              textTermsAndPolicyPage.strings[language]!['T00']
                                  ?? 'Are you absolutely sure that you want to delete your account and lose access to all the content you have accumulated, as well as the ability to edit or delete your personal information that may remain in the collections of other users?',
                              style: const TextStyle(fontSize: 20, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            TextButton(
                              child: Text(textTermsAndPolicyPage.strings[language]!['T05'] ?? 'Cancel',
                                style: const TextStyle(fontSize: 18),
                              ),//'Cancel'
                              onPressed: () {
                                Navigator.pop(context1);
                              },
                            ),
                            TextButton(
                              child: Text(textTermsAndPolicyPage.strings[language]!['T06'] ?? 'Delete',
                                style: const TextStyle(fontSize: 18),
                              ),//'Cancel'
                              onPressed: () async {
                                ///Enter password to delete
                                String _pass = '';
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context2) => SimpleDialog(
                                      title: Container(),
                                      titlePadding: const EdgeInsets.all(10.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      children: <Widget>[

                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Center(child: Text(textTermsAndPolicyPage.strings[language]!['T07']
                                              ?? 'Please enter your password to confirm the action',
                                            style: const TextStyle(fontSize: 18),
                                            textAlign: TextAlign.center,
                                          ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: TextFormField(
                                            controller: passwordController,
                                            //maxLength: 100,
                                            //maxLengthEnforced: true,
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              //color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              //hintText: textTermsAndPolicyPage.strings[language]['T08'] ?? 'Password',
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1.0,
                                                  color: Colors.grey,//grey[200]
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                borderSide: BorderSide(
                                                    color: Colors.deepOrangeAccent[400]!
                                                ),
                                              ),
                                              focusedErrorBorder: const OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey,
                                                  )
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                  borderSide: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.grey,//grey[500]
                                                  )
                                              ),
                                            ),

                                            onChanged: (val) {
                                              setState(() {
                                                _pass = val;
                                              });
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 20,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            TextButton(
                                              child: Row(
                                                children: [
                                                  Text(textTermsAndPolicyPage.strings[language]!['T06'] ?? 'Delete',
                                                    style: TextStyle(fontSize: 20, color: Colors.deepOrangeAccent[400],),
                                                  ),
                                                  const SizedBox(width: 2,),
                                                  Icon(Icons.delete_forever_outlined, color: Colors.deepOrangeAccent[400],),
                                                ],
                                              ),//'Cancel'
                                              onPressed: () async {
                                                await _auth.deleteUserFunction(_pass);///   ヽ(°〇°)ﾉ   \\\

                                                Navigator.pop(widget.cont);
                                                Navigator.pop(context2);
                                                Navigator.pop(context1);
                                                Navigator.pop(context);
                                              },
                                            ),

                                            TextButton(
                                              child: Text(textTermsAndPolicyPage.strings[language]!['T05'] ?? 'Cancel',
                                                style: const TextStyle(fontSize: 18),
                                              ),//'Cancel'
                                              onPressed: () {
                                                Navigator.pop(context2);
                                                Navigator.pop(context1);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                );

                              },
                            ),
                          ],
                        ),

                      ],
                    ),
                  );

                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> loadTerms(String language) async {

  try {
    var _snapshot = await FirebaseFirestore.instance.collection('licenses').doc('terms').get();
    return _snapshot.data()?[language];

  } catch(e) {
    //print('$e');
    return null;
  }

}