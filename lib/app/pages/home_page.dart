
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_navigator_bottom_bar/multi_navigator_bottom_bar.dart';
import 'package:uni_links/uni_links.dart';

import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/pages/catalog_page.dart';
import 'package:selvis_flutter/app/pages/cart_page.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';
import 'package:selvis_flutter/app/pages/user_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  StreamSubscription _sub;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: MultiNavigatorBottomBar(
        currentTabIndex: 0,
        tabs: [
          BottomBarTab(
            initPageBuilder: (_) => CatalogPage(),
            tabIconBuilder: (_) => Icon(Icons.category),
            tabTitleBuilder: (_) => Text('Каталог')
          ),
          BottomBarTab(
            initPageBuilder: (_) => CartPage(),
            tabIconBuilder: (_) => Icon(Icons.shopping_cart),
            tabTitleBuilder: (_) => Text('Корзина'),
            savePageState: false
          ),
          BottomBarTab(
            initPageBuilder: (_) => UserPage(),
            tabIconBuilder: (_) => Icon(Icons.account_box),
            tabTitleBuilder: (_) => Text('Профиль'),
            savePageState: false
          )
        ]
      )
    );
  }

  void showMessage(String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> routeUniLink(String rawLink) async {
    if (rawLink != null) {
      String decodedLink = Uri.decodeFull(rawLink);
      String skuGuid = RegExp(r'card\?id=([^&]+)').firstMatch(decodedLink)?.group(1);

      try {
        Product product = await Product.loadBySkuGuid(skuGuid);

        if (product != null) {
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (context) => ProductPage(product: product))
          );
        } else {
          showMessage('Товар не найден');
        }
      } on ApiException catch (e) {
         showMessage(e.errorMsg);
      }
    }
  }

  Future<void> initUniLinks() async {
    // Attach a listener to the Uri links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;

      routeUniLink(link);
    }, onError: (err) {
      if (!mounted) return;

      showMessage('Произошла ошибка');
    });

    try {
      routeUniLink(await getInitialLink());
    } on PlatformException {
      showMessage('Произошла ошибка');
    } on FormatException {
      showMessage('Произошла ошибка');
    }
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  @override
  void dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }
}
