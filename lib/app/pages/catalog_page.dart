import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/group.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/pages/catalog/search_page.dart';
import 'package:selvis_flutter/app/pages/sub_groups_page.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class CatalogPage extends StatefulWidget {
  CatalogPage({Key key}) : super(key: key);

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with WidgetsBindingObserver {
  GlobalKey<ApiPageWidgetState> _apiWidgetKey = GlobalKey();
  List<Group> _groups = [];

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: _searchProduct
        ),
        IconButton(
          color: Colors.white,
          icon: Icon(Icons.camera_alt),
          onPressed: _scanBarcode
        ),
      ],
      title: Text(App.application.config.packageInfo.appName)
    );
  }

  Widget _buildBody(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: _groups.map((Group group) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SubGroupsPage(parentGroup: group)));
          },
          child: Column(
            children: <Widget>[
              SizedBox(
                child: group.image,
                height: 112,
                width: 112
              ),
              Text(
                group.title,
                style: Theme.of(context).textTheme.subtitle,
                textAlign: TextAlign.center
              )
            ]
          )
        );
      }).toList()
    );
  }

  Future<void> _loadData() async {
    List<Group> topGroups = await Group.loadFromRemote();
    _groups = topGroups.map((group) => group.childrenList).expand((el) => el).toList();
  }

  void _searchProduct() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
  }

  void _scanBarcode() async {
    String errorMsg;

    try {
      Product product = await Product.loadByBarcode(await BarcodeScanner.scan());

      if (product != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(product: product)));
      } else {
        errorMsg = 'Товар не найден';
      }
    } on PlatformException catch (e) {
      errorMsg = 'Не известная ошибка: $e';

      if (e.code == BarcodeScanner.CameraAccessDenied) {
        errorMsg = 'Необходимо дать доступ к использованию камеры';
      }
    } on ApiException catch (e) {
      errorMsg = e.errorMsg;
    }

    if (errorMsg != null) {
      _apiWidgetKey.currentState?.showMessage(errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      key: _apiWidgetKey,
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
      loadData: _loadData,
    );
  }
}
