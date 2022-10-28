import 'package:cloud_firestore/cloud_firestore.dart';

/// Функция создает документ профиля в Firebase для нового юзера

Future<bool> setNewUserData(String _uid, String _email, String _name, String _language) async {
  try {
    await FirebaseFirestore.instance.collection('user_profiles').doc(_uid).set({
      'name': _name,
      'photoUrl': '',
      'colorNum': '2',
      'shadeNum': '1200',
      'language': _language,
    });
    return true;
  } catch(e) {
    //print('101error: $e');
    return false;
  }
}