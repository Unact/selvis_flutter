import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/models/group.dart';
import 'package:selvis_flutter/app/pages/product_list_page.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class SubGroupsPage extends StatefulWidget {
  final Group parentGroup;

  SubGroupsPage({Key key, @required this.parentGroup}) : super(key: key);

  @override
  _SubGroupsPageState createState() => _SubGroupsPageState();
}

class _SubGroupsPageState extends State<SubGroupsPage> {
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.parentGroup.title),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
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
    );
  }


  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
    );
  }
}
