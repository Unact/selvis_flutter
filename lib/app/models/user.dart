import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:selvis_flutter/app/app.dart';

class User {
  String uid = kGuestUid;
  String login;
  String firstname = '';
  String lastname = '';
  String password;
  String email = '';
  String lastDraft;
  String sessionId;

  String get fullname => [firstname, lastname].join(' ');

  static const String kGuestUid = 'guest';

  User({Map<String, dynamic> values}) {
    if (values != null) build(values);
  }

  void build(Map<String, dynamic> values) {
    uid = values['uid'] ?? kGuestUid;
    login = values['login'];
    firstname = values['firstname'] ?? '';
    lastname = values['lastname'] ?? '';
    password = values['password'];
    email = values['email'] ?? '';
    lastDraft = values['lastDraft'];
    sessionId = values['sessionId'];
  }

  static User currentUser() {
    return User(values: {
      'uid': App.application.prefs.getString('uid'),
      'firstname': App.application.prefs.getString('firstname'),
      'lastname': App.application.prefs.getString('lastname'),
      'login': App.application.prefs.getString('login'),
      'password': App.application.prefs.getString('password'),
      'email': App.application.prefs.getString('email'),
      'lastDraft': App.application.prefs.getString('lastDraft'),
      'sessionId': App.application.prefs.getString('sessionId')
    });
  }

  bool isLogged() {
    return currentUser().password != null;
  }

  void reset() {
    uid = kGuestUid;
    login = null;
    firstname = '';
    lastname = '';
    password = null;
    email = '';
    lastDraft = null;
    sessionId = null;
  }

  Future<void> save() async {
    SharedPreferences prefs = App.application.prefs;

    await (uid != null ? prefs.setString('uid', uid) : prefs.remove('uid'));
    await (firstname != null ? prefs.setString('firstname', firstname) : prefs.remove('firstname'));
    await (lastname != null ? prefs.setString('lastname', lastname) : prefs.remove('lastname'));
    await (login != null ? prefs.setString('login', login) : prefs.remove('login'));
    await (password != null ? prefs.setString('password', password) : prefs.remove('password'));
    await (email != null ? prefs.setString('email', email) : prefs.remove('email'));
    await (lastDraft != null ? prefs.setString('lastDraft', lastDraft) : prefs.remove('lastDraft'));
    await (sessionId != null ? prefs.setString('sessionId', sessionId) : prefs.remove('sessionId'));
  }
}
