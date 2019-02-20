import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AppConfig {
  AppConfig({
    @required this.isPhysicalDevice,
    @required this.isTabletDevice,
    @required this.deviceModel,
    @required this.osVersion,
    @required this.packageInfo,
    @required this.env,
    @required this.sentryDsn,
    @required this.dadataApiKey
  });

  final PackageInfo packageInfo;
  final bool isPhysicalDevice;
  final bool isTabletDevice;
  final String deviceModel;
  final String osVersion;
  final String env;
  final String sentryDsn;
  final String dadataApiKey;
}
