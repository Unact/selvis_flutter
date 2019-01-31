import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/group.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/pages/sub_groups_page.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';

class CatalogPage extends StatefulWidget {
  CatalogPage({Key key}) : super(key: key);

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<Group> groups = [];

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _loadData,
      child: GridView.count(
        crossAxisCount: 2,
        children: groups.map((Group group) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SubGroupsPage(parentGroup: group)));
            },
            child: Column(
              children: <Widget>[
                SizedBox(child: Image.network(App.application.config.apiBaseUrl + 'images/source/groups/${group.title}'),
                  height: 125,
                  width: 125
                ),
                Text(group.title,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center
                )
              ]
            )
          );
        }).toList()
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Group> topGroups = await Group.loadFromRemote();
    groups = topGroups.map((group) => group.childrenList).expand((el) => el).toList();

    if (mounted) {
      setState(() {});
    }
  }

  void _scanBarcode() async {
    try {
      Product product = await Product.loadByBarcode(await BarcodeScanner.scan());

      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(product: product)));
    } on PlatformException catch (e) {
      String errorMsg = 'Не известная ошибка: $e';

      if (e.code == BarcodeScanner.CameraAccessDenied) {
        errorMsg = 'Необходимо дать доступ к использованию камеры';
      }

      showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ошибка сканирования'),
            content: Text(errorMsg),
          );
        }
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshIndicatorKey.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {

            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              _scanBarcode();
            }
          ),
        ],
        title: Text(App.application.config.packageInfo.appName)
      ),
      body: _buildBody(context)
    );
  }
}
