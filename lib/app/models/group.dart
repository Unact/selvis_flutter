import 'package:selvis_flutter/app/app.dart';

class Group {
  int id;
  String title;
  int productCount;
  List<Group> childrenList;

  Group(Map<String, dynamic> values) {
    id = values['id'];
    productCount = values['productCount'];
    title = values['title'];
    childrenList = values.containsKey('childrenList') ? values['childrenList'].map<Group>((row) => Group(row)).toList() : null;
  }

  static Future<List<Group>> loadFromRemote() async {
    List<dynamic> res = await App.application.api.get('orderEditor/groups');
    return res.map<Group>((row) => Group(row)).toList();
  }
}
