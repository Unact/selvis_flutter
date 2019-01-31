import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/models/group.dart';
import 'package:selvis_flutter/app/pages/product_list_page.dart';

class SubGroupsPage extends StatefulWidget {
  final Group parentGroup;

  SubGroupsPage({Key key, @required this.parentGroup}) : super(key: key);

  @override
  _SubGroupsPageState createState() => _SubGroupsPageState();
}

class _SubGroupsPageState extends State<SubGroupsPage> {
  Widget _buildBody(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: ListView(
        children: widget.parentGroup.childrenList.map((Group group) {
          return ListTile(
            onTap: () async {
              if (group.childrenList.first.childrenList != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SubGroupsPage(parentGroup: group)));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListPage(parentGroup: group)));
              }
            },
            title: Text(group.title)
          );
        }).toList()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentGroup.title),
      ),
      body: _buildBody(context)
    );
  }
}
