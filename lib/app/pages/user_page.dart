import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/pages/orders_page.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _login;
  String _password;

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Профиль'),
    );
  }

  Widget _buildBody(BuildContext context) {
    return User.currentUser().isLogged() ? _buildProfileForm(context) : _buildLoginForm(context);
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TextField(
          onChanged: (val) => _login = val,
          keyboardType: TextInputType.phone,
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
        Container(
          width: 80.0,
          child: RaisedButton(
            onPressed: () async {
              dynamic res = (await App.application.api.post(
                'login/login',
                params: {'login': _login, 'password': _password, 'rememberme': 'on'}
              ))['user'];
              User user = User.currentUser();

              user.uid = res['uid'];
              user.password = _password;
              user.login = _login;
              await user.save();

              setState(() {});
            },
            color: Colors.blueGrey,
            textColor: Colors.white,
            child: Text('Войти'),
          ),
        )
      ]
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    User user = User.currentUser();

    return Column(
      children: <Widget>[
        Text('Logged'),
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
              await App.application.api.post('login/logout');
              user.reset();
              await user.save();

              setState(() {});
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
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
      loadData: _loadData,
    );
  }
}
