import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';

class CartPage extends StatefulWidget {

  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> products = [];

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: [
          Expanded(child:
            ListView(
              children: products.where((Product product) => product.quantity > 0).map((Product product) {
                return ListTile(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductPage(product: product))
                    );
                    setState(() {});
                  },
                  title: Text(product.wareName, style: Theme.of(context).textTheme.caption),
                  leading: SizedBox(
                    child: Image.network(App.application.config.apiBaseUrl + 'images/${product.productGuid}.png'),
                    width: 48,
                    height: 52
                  ),
                  subtitle: Text(product.sum.toString(), style: TextStyle(color: Colors.green)),
                );
              }).toList()
            ),
          ),
          RaisedButton(
            child: Text('Перейти к оформлению'),
            onPressed: () async {
              print('Implement me!');
            },
          )
        ]
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    products = await Product.loadOrdered(User.currentUser().lastDraft);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Корзина'),
      ),
      body: _buildBody(context)
    );
  }
}
