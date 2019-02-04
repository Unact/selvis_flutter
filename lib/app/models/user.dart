import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:selvis_flutter/app/app.dart';

class User {
  User.init() {
    _currentUser = this;
    uid = App.application.prefs.getString('uid') ?? kGuestUid;
    login = App.application.prefs.getString('login');
    password = App.application.prefs.getString('password');
    lastDraft = App.application.prefs.getString('lastDraft');
    sessionId = App.application.prefs.getString('sessionId');
    refreshToken = App.application.prefs.getString('refreshToken');
    firstname = App.application.prefs.getString('firstname');
    lastname = App.application.prefs.getString('lastname');
    middlename = App.application.prefs.getString('middlename');
    phone = App.application.prefs.getString('phone');
    email = App.application.prefs.getString('email');
  }

  User._();

  static User _currentUser;
  static User get currentUser => _currentUser;

  static const String kGuestUid = 'guest';

  String uid;
  String login;
  String password;
  String lastDraft;
  String sessionId;
  String refreshToken;

  String firstname;
  String lastname;
  String middlename;
  String phone;
  String email;

  String get fullname => [firstname, lastname].join(' ');
  bool get isLoggedIn => refreshToken != null;

  Future<void> apiLogin(Map<String, String> params) async {
    Map<String, dynamic> res = await App.application.api.post('login/login', params: params);

    this.login = login;
    this.password = password;
    this.firstname = res['firstname'];
    this.lastname = res['lastname'];
    this.middlename = res['middlename'];
    this.phone = res['phone'];
    this.email = res['email'];
    await save();
  }

  Future<void> apiLoginWithCredentials(String login, String password) async {
    await apiLogin({
      'login': login,
      'password': password,
      'rememberme': 'on'
    });
  }

  Future<void> apiLoginWithQrCode(String qrCode) async {
    this.refreshToken = utf8.decode(base64.decode(qrCode)).split('\n').last;
    await apiLogin({});
  }

  Future<void> apiLogout() async {
    await App.application.api.post('login/logout');
    reset();

    await save();
  }

  void reset() {
    uid = kGuestUid;
    login = null;
    password = null;
    lastDraft = null;
    sessionId = null;
    refreshToken = null;
    firstname = null;
    lastname = null;
    middlename = null;
    email = null;
    phone = null;
  }

  Future<void> save() async {
    SharedPreferences prefs = App.application.prefs;

    await (uid != null ? prefs.setString('uid', uid) : prefs.remove('uid'));
    await (login != null ? prefs.setString('login', login) : prefs.remove('login'));
    await (password != null ? prefs.setString('password', password) : prefs.remove('password'));
    await (lastDraft != null ? prefs.setString('lastDraft', lastDraft) : prefs.remove('lastDraft'));
    await (sessionId != null ? prefs.setString('sessionId', sessionId) : prefs.remove('sessionId'));
    await (refreshToken != null ? prefs.setString('refreshToken', refreshToken) : prefs.remove('refreshToken'));
    await (firstname != null ? prefs.setString('firstname', firstname) : prefs.remove('firstname'));
    await (lastname != null ? prefs.setString('lastname', lastname) : prefs.remove('lastname'));
    await (middlename != null ? prefs.setString('middlename', middlename) : prefs.remove('middlename'));
    await (phone != null ? prefs.setString('phone', phone) : prefs.remove('phone'));
    await (email != null ? prefs.setString('email', email) : prefs.remove('email'));
  }
}
