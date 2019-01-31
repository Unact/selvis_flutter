import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AppConfig {
  AppConfig({
    @required this.isPhysicalDevice,
    @required this.deviceModel,
    @required this.osVersion,
    @required this.packageInfo,
    @required this.env,
    @required this.sentryDsn,
    @required this.apiBaseUrl
  });

  final PackageInfo packageInfo;
  final bool isPhysicalDevice;
  final String deviceModel;
  final String osVersion;
  final String env;
  final String sentryDsn;
  final String apiBaseUrl;
}
