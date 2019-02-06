import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/modules/sentry.dart';
import 'package:selvis_flutter/app/pages/home_page.dart';
import 'package:selvis_flutter/config/app_config.dart';

class App {
  App.setup(this.config) {
    _setupEnv();
    _application = this;
  }

  static App _application;
  static App get application => _application;
  final String name = 'selvis_flutter';
  final String title = 'Selvis';
  final AppConfig config;
  Sentry sentry;
  Widget widget;
  SharedPreferences prefs;

  Future<void> run() async {
    prefs = await SharedPreferences.getInstance();
    widget = _buildWidget();
    User.init();

    print('Started $name in ${config.env} environment');
    runApp(widget);
  }

  void _setupEnv() {
    if (config.env != 'development') {
      sentry = Sentry.setup(config);
    }
  }

  Widget _buildWidget() {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey
      ),
      home: HomePage(),
      locale: Locale('ru', 'RU'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ru', 'RU'),
      ]
    );
  }
}
