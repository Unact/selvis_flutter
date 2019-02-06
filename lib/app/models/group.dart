import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/modules/api.dart';

class Group {
  int id;
  String title;
  int productCount;
  List<Group> childrenList;

  Image get image => Image.network(App.application.config.apiBaseUrl + 'images/source/groups/$title');

  Group(Map<String, dynamic> values) {
    id = values['id'];
    productCount = values['productCount'];
    title = values['title'];
    childrenList = values.containsKey('childrenList') ? values['childrenList'].map<Group>((row) => Group(row)).toList() : null;
  }

  static Future<List<Group>> loadFromRemote() async {
    List<dynamic> res = await Api.get('orderEditor/groups');
    return res.map<Group>((row) => Group(row)).toList();
  }
}
