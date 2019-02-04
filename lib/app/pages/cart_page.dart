import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class CartPage extends StatefulWidget {
  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> _products = [];

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Корзина'),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: _products.where((Product product) => product.quantity > 0).map((Product product) {
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
    );
  }

  Future<void> _loadData() async {
    _products = await Product.loadOrdered(User.currentUser().lastDraft);
  }

  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
      loadData: _loadData
    );
  }
}
