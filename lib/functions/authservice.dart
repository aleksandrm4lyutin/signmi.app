import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signmi_app/functions/data_services/set_up_new_user_data.dart';

/// Класс содержащий функции связанные с аутентификацией

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Auth change user stream
  Stream<User?> get user{
    return _auth.authStateChanges();
  }


  /// Функция для регистриции нового пользователя
  ///========================================================================================
  Future registerFunction(String email, String password, String name, String locale) async {

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'setAccountNameData',
      );
      var n = name.toLowerCase();
      await callable.call({
        'name': n,
        'email': email,
      });
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      bool _setNewUser = await setNewUserData(user?.uid ?? '', email, name, locale);

      if(_setNewUser) {
        return user;
      } else {
        //print('AuthService!@#%');
        return null;
      }
    } catch(e) {
      //print(e.toString());
      return null;
    }
  }
  ///========================================================================================


  /// Функция для входа в приложение
  ///========================================================================================
  Future signInFunction(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch(e) {
      //print(e.toString());
      return null;
    }
  }
  ///========================================================================================


  /// Функция для выхода из приложение
  ///========================================================================================
  Future signOutFunction() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      //print(e.toString());
      return null;
    }
  }
  ///========================================================================================


  /// Функция для сброса пароля
  ///========================================================================================
  Future resetPasswordFunction(String email, String name) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'requestPasswordReset',
      );
      var result = await callable.call({
        'name': name,
        'email': email,
      });
      if(result.data == true) {
        await _auth.sendPasswordResetEmail(email: email);
        return true;
      } else {
        return false;
      }
    } catch(e) {
      //print(e.toString());
      return null;
    }
  }
  ///========================================================================================


  /// Функция для удаления данных пользователя
  ///========================================================================================
  Future deleteUserFunction(String pass) async {
    try {
      var _user = _auth.currentUser;
      await _user?.reauthenticateWithCredential(EmailAuthProvider.credential(email: _user.email ?? '', password: pass));
      _user?.delete();
      //await signOutFunction();
    } catch(e) {
      //print(e.toString());
      return null;
    }
  }
  ///========================================================================================
}
