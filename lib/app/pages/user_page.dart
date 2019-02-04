import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/pages/orders_page.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  GlobalKey<ApiPageWidgetState> _apiWidgetKey = GlobalKey();
  String _login;
  String _password;

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Профиль'),
    );
  }

  Widget _buildBody(BuildContext context) {
    return User.currentUser.isLoggedIn ? _buildProfileForm(context) : _buildLoginForm(context);
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TextField(
          onChanged: (val) => _login = val,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Телефон или e-mail',
          ),
        ),
        TextField(
          onChanged: (val) => _password = val,
          keyboardType: TextInputType.text,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Пароль'
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                try {
                  await User.currentUser.apiLoginWithCredentials(_login, _password);
                  setState(() {});
                } on ApiException catch(e) {
                  _apiWidgetKey.currentState?.showMessage(e.errorMsg);
                }
              },
              color: Colors.blueGrey,
              textColor: Colors.white,
              child: Text('Войти'),
            ),
            SizedBox(width: 10,),
            RaisedButton(
              onPressed: _qrLogin,
              color: Colors.blueGrey,
              textColor: Colors.white,
              child: Text('QR'),
            ),
          ]
        )
      ]
    );
  }

  void _qrLogin() async {
    String errorMsg;

    try {
      await User.currentUser.apiLoginWithQrCode(await BarcodeScanner.scan());
      setState(() {});
    } on PlatformException catch (e) {
      errorMsg = 'Не известная ошибка: $e';

      if (e.code == BarcodeScanner.CameraAccessDenied) {
        errorMsg = 'Необходимо дать доступ к использованию камеры';
      }
    } on ApiException catch (e) {
      errorMsg = e.errorMsg;
    }

    if (errorMsg != null) {
      _apiWidgetKey.currentState?.showMessage(errorMsg);
    }
  }

  Widget _buildProfileForm(BuildContext context) {
    User user = User.currentUser;

    return Column(
      children: <Widget>[
        RaisedButton(
          onPressed: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
          },
          child: Text('Список заказов'),
        ),
        Container(
          width: 80.0,
          child: RaisedButton(
            onPressed: () async {
              try {
                await user.apiLogout();
                setState(() {});
              } on ApiException catch(e) {
                _apiWidgetKey.currentState?.showMessage(e.errorMsg);
              }
            },
            color: Colors.blueGrey,
            textColor: Colors.white,
            child: Text('Выйти'),
          ),
        )
      ],
    );
  }

  Future<void> _loadData() async {
    print('Implement me!');
  }

  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      key: _apiWidgetKey,
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
      loadData: _loadData,
    );
  }
}
