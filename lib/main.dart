import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/config/app_config.dart';
import 'package:selvis_flutter/config/app_env.dart' show appEnv;

void main() async {
  AndroidDeviceInfo androidDeviceInfo;
  IosDeviceInfo iosDeviceInfo;
  String osVersion;
  String deviceModel;
  bool isPhysicalDevice;
  bool development = false;
  assert(development = true); // Метод выполняется только в debug режиме

  if (Platform.isIOS) {
    iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
    isPhysicalDevice = iosDeviceInfo.isPhysicalDevice;
    osVersion = iosDeviceInfo.systemVersion;
    deviceModel = iosDeviceInfo.utsname.machine;
  } else {
    androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    isPhysicalDevice = androidDeviceInfo.isPhysicalDevice;
    osVersion = androidDeviceInfo.version.release;
    deviceModel = androidDeviceInfo.brand + ' - ' + androidDeviceInfo.model;
  }

  await appEnv.load();

  await (App.setup(AppConfig(
    packageInfo: await PackageInfo.fromPlatform(),
    isPhysicalDevice: isPhysicalDevice,
    deviceModel: deviceModel,
    osVersion: osVersion,
    env: development ? 'development' : 'production',
    dadataApiKey: appEnv['DADATA_API_KEY'],
    sentryDsn: appEnv['SENTRY_DSN']
  ))).run();
}
