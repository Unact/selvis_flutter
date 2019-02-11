import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:selvis_flutter/app/app.dart';
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
      actions: <Widget>[
        IconButton(
          color: Colors.white,
          icon: Icon(Icons.info),
          onPressed: () {
            String version = App.application.config.packageInfo.version;

            return _apiWidgetKey.currentState?.showMessage('Версия приложения: $version');
          }
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 32.0),
      child: User.currentUser.isLoggedIn ? _buildProfileForm(context) : _buildLoginForm(context),
    );

  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 32.0, bottom: 4.0, right: 40.0, left: 40.0),
          child: TextField(
            style: TextStyle(fontSize: 14.0, color: Colors.black),
            onChanged: (val) => _login = val,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Телефон или e-mail',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 32.0, right: 40.0, left: 40.0),
          child: TextField(
            style: TextStyle(fontSize: 14.0, color: Colors.black),
            onChanged: (val) => _password = val,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Пароль',
            ),
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
            SizedBox(width: 20,),
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

  TableRow _buildTableRow(BuildContext context, String key, String value, Function onFieldSubmitted) {
    TextEditingController controller = TextEditingController();
    controller.text = value;

    return TableRow(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 4.0, right: 8.0),
          child: Text(key, style: TextStyle(color: Theme.of(context).accentColor), textAlign: TextAlign.end)
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: TextFormField(
            controller: controller,
            enabled: true,
            maxLines: 1,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 14.0, color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(),
            ),
            onFieldSubmitted: (String value) async {
              try {
                onFieldSubmitted(value);
                await User.currentUser.changeAdditionalData();
                setState(() {});
              } on ApiException catch(e) {
                _apiWidgetKey.currentState?.showMessage(e.errorMsg);
              }
            }
          ),
        ),
      ]
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    User user = User.currentUser;

    return ListView(
      children: [
        Column(
          children: <Widget>[
            Table(
              columnWidths: <int, TableColumnWidth>{
                0: FixedColumnWidth(88.0)
              },
              children: <TableRow>[
                _buildTableRow(context, 'Фамилия', user.lastname, (String value) => user.lastname = value),
                _buildTableRow(context, 'Имя', user.firstname, (String value) => user.firstname = value),
                _buildTableRow(context, 'Отчество', user.middlename, (String value) => user.middlename = value),
                _buildTableRow(context, 'Эл. почта', user.email, (String value) => user.email = value),
                _buildTableRow(context, 'Телефон', user.phone, (String value) => user.phone = value)
              ]
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: RaisedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
                },
                child: Text('Список заказов'),
              ),
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
        )
      ]
    );
  }

  Future<void> _loadData() async {
    if (User.currentUser.isLoggedIn) {
      await User.currentUser.loadAdditionalData();
    }
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
