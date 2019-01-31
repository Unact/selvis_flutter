import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/pages/catalog_page.dart';
import 'package:selvis_flutter/app/pages/cart_page.dart';
import 'package:selvis_flutter/app/pages/user_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _bottomNavigationBarKey = GlobalKey();
  int _currentIndex = 0;
  List<Widget> _children = [];

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      key: _bottomNavigationBarKey,
      currentIndex: _currentIndex,
      onTap: (int index) => setState(() => _currentIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          title: Text('Каталог')
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          title: Text('Корзина'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          title: Text('Профиль'),
        )
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return _children[_currentIndex];
  }

  @override
  void initState() {

    super.initState();
    _children = [
      CatalogPage(),
      CartPage(),
      UserPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: _buildBody(context)
    );
  }
}
