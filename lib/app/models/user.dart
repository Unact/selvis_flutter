import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/modules/api.dart';

class UserAddress {
  final String addressId;
  final String address;
  final String legalName;

  UserAddress(this.addressId, this.address, this.legalName);

   Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'address': address,
      'legalName': legalName
    };
  }
}

class User {
  User.init() {
    _currentUser = this;
    login = App.application.prefs.getString('login') ?? kGuestLogin;
    lastDraft = App.application.prefs.getString('lastDraft');
    sessionId = App.application.prefs.getString('sessionId');
    refreshToken = App.application.prefs.getString('refreshToken');
    firstname = App.application.prefs.getString('firstname');
    lastname = App.application.prefs.getString('lastname');
    middlename = App.application.prefs.getString('middlename');
    phone = App.application.prefs.getString('phone');
    email = App.application.prefs.getString('email');
    addresses = jsonDecode(App.application.prefs.getString('addresses') ?? "[]").map<UserAddress>(
      (dynamic val) => UserAddress(val['addressId'], val['address'], val['legalName'])
    ).toList();
  }

  User._();

  static User _currentUser;
  static User get currentUser => _currentUser;

  static const String kGuestLogin = 'guest';

  String login;
  String lastDraft;
  String sessionId;
  String refreshToken;
  List<UserAddress> addresses = [];

  String firstname;
  String lastname;
  String middlename;
  String phone;
  String email;

  String get fullname => [firstname, lastname].join(' ');
  bool get isLoggedIn => refreshToken != null;

  Future<void> apiLogin(Map<String, String> params) async {
    Map<String, dynamic> res = await Api.post('login/login', params: params);
    Map<String, dynamic> userData = res['user'];

    if (userData != null) {
      firstname = userData['firstname'];
      lastname = userData['lastname'];
      middlename = userData['middlename'];
      phone = userData['phone'];
      email = userData['email'];
      addresses = res['addresses'].map<UserAddress>(
        (dynamic val) {
          Map<String, dynamic> info = val['address'];
          return UserAddress(info['addressId'], info['address'], info['legalName']);
        }
      ).toList();
    }
    if ((await Product.loadOrdered(User.currentUser.lastDraft)).isEmpty) {
      await newDraft();
    }

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
    await Api.post('login/logout');
    reset();
    await newDraft();
    await save();
  }

  Future<void> newDraft() async {
    lastDraft = await Api.post('orderEditor/newOrder');
  }

  Future<void> loadAdditionalData() async {
    await apiLogin({});
  }

  Future<void> changeAdditionalData() async {
    await Api.post(
      'user-profile/setProfile',
      params: {
        'firstname': firstname,
        'lastname': lastname,
        'middlename': middlename,
        'phone': phone,
        'email': email
      }
    );
    await User.currentUser.save();
  }

  static Future<bool> userExists(String login) async {
    return await Api.post(
      'login/isExists',
      params: {
        'login': login
      }
    );
  }

  void reset() {
    login = kGuestLogin;
    lastDraft = null;
    sessionId = null;
    refreshToken = null;
    firstname = null;
    lastname = null;
    middlename = null;
    email = null;
    phone = null;
    addresses = [];
  }

  Future<void> save() async {
    SharedPreferences prefs = App.application.prefs;

    await (login != null ? prefs.setString('login', login) : prefs.remove('login'));
    await (lastDraft != null ? prefs.setString('lastDraft', lastDraft) : prefs.remove('lastDraft'));
    await (sessionId != null ? prefs.setString('sessionId', sessionId) : prefs.remove('sessionId'));
    await (refreshToken != null ? prefs.setString('refreshToken', refreshToken) : prefs.remove('refreshToken'));
    await (firstname != null ? prefs.setString('firstname', firstname) : prefs.remove('firstname'));
    await (lastname != null ? prefs.setString('lastname', lastname) : prefs.remove('lastname'));
    await (middlename != null ? prefs.setString('middlename', middlename) : prefs.remove('middlename'));
    await (phone != null ? prefs.setString('phone', phone) : prefs.remove('phone'));
    await (email != null ? prefs.setString('email', email) : prefs.remove('email'));
    prefs.setString('addresses', jsonEncode(addresses));
  }
}
