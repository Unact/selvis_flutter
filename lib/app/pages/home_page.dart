import 'package:flutter/material.dart';
import 'package:multi_navigator_bottom_bar/multi_navigator_bottom_bar.dart';

import 'package:selvis_flutter/app/pages/catalog_page.dart';
import 'package:selvis_flutter/app/pages/cart_page.dart';
import 'package:selvis_flutter/app/pages/user_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ]
      )
    );
  }
}
