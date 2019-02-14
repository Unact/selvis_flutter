import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/pages/complete_order_page.dart';
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

  List<Widget> _buildPersistentFooterButtons(BuildContext context) {
    double total = _products.map((Product product) => product.sum).fold(0, (curVal, el) => curVal + el);

    if (_products.isEmpty) return null;

    return <Widget>[
      FlatButton(onPressed: null, child: Text('${total.toStringAsFixed(2)} ₽')),
      FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
        color: Theme.of(context).accentColor,
        child: Text('Перейти к оформлению', style: Theme.of(context).primaryTextTheme.button),
        onPressed: () async {
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (context) => CompleteOrderPage(products: _products))
          );
        }
      )
    ];
  }

  Widget _buildBody(BuildContext context) {
    List<Product> productsToShow = _products.where((Product product) => product.quantity > 0).toList();

    return ListView.separated(
      separatorBuilder: (BuildContext context, int idx) => Divider(height: 4, color: Theme.of(context).accentColor),
      itemCount:  productsToShow.length,
      itemBuilder: (BuildContext context, int idx) {
        Product product = productsToShow[idx];

        return InkWell(
          onTap: () async {
            await Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => ProductPage(product: product))
            );
            setState(() {});
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      child: product.image,
                      width: 48,
                      height: 52
                    ),
                  ),
                  Expanded(
                    child: Text(product.wareName)
                  ),
                  SizedBox(width: 8)
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.all(0),
                        color: Theme.of(context).accentColor,
                        icon: Icon(Icons.remove),
                        iconSize: 12,
                        onPressed: () async {
                          int newQuantity = product.quantity - product.multiple;

                          await product.changeQuantity(newQuantity, User.currentUser.lastDraft);
                          setState((){});
                        },
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(product.quantity.toStringAsFixed(0), textAlign: TextAlign.center)
                      ),

                      IconButton(
                        iconSize: 12,
                        padding: EdgeInsets.all(0),
                        color: Theme.of(context).accentColor,
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          int newQuantity = product.quantity + product.multiple;

                          await product.changeQuantity(newQuantity, User.currentUser.lastDraft);
                          setState((){});
                        },
                      )
                    ]
                  ),
                  Expanded(
                      child: Text(product.sum.toStringAsFixed(2) + ' ₽', textAlign: TextAlign.end)
                    ),
                  SizedBox(width: 8)
                ]
              )
            ]
          )
        );
      }
    );
  }

  Future<void> _loadData() async {
    _products = await Product.loadOrdered(User.currentUser.lastDraft);
  }

  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      buildPersistentFooterButtons: _buildPersistentFooterButtons,
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
      loadData: _loadData
    );
  }
}
