import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_page.dart';
import 'data_loader.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);

    /// Если пользователь не вошел или не зарегестрирован через Firebase Auth,
    /// то возвращается страница аутентификации, как только есть данные о User
    /// открывается остальное приложение и загружаются данные пользователя
    ///
    if (user == null) {
      return const AuthPage();
    } else {
      return DataLoader(
        uid: user.uid,
      );

    }
  }
}