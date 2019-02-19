import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/modules/api.dart';

class PasswordRecoveryPage extends StatefulWidget {
  PasswordRecoveryPage({Key key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final Duration _kWaitDuration = Duration(seconds: 1);
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String _login = '';

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Восстановление пароля')
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Для восстановления пароля необходимо ввести телефон или e-mail', textAlign: TextAlign.center)
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 40.0, left: 40.0),
            child: TextField(
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: (val) => _login = val,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Телефон или e-mail'
              )
            )
          ),
          RaisedButton(
            onPressed: () async {
              try {
                if (_login.isEmpty) {
                  showMessage('Необходимо указать телефон или e-mail');
                  return;
                }

                await User.currentUser.apiRestorePassword(_login);

                showMessage('Отправлен e-mail/sms');
                await Future.delayed(_kWaitDuration);
                Navigator.of(context).pop();
              } on ApiException catch(e) {
                showMessage(e.errorMsg);
              }
            },
            color: Colors.blueGrey,
            textColor: Colors.white,
            child: Text('Получить письмо')
          )
        ]
      )
    );
  }

  void showMessage(String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context)
    );
  }
}
