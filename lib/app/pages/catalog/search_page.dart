import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _queryTextController = TextEditingController();
  List<Product> _products;

  Widget _buildProductList(BuildContext context) {
    if (_products.isEmpty) {
      return Center(child: Text('Ничего не найдено', textAlign: TextAlign.center));
    }

    return ListView(
      children: _products.map((Product product) {
        return ListTile(
          leading: SizedBox(
            child: product.image,
            width: 48,
            height: 52
          ),
          isThreeLine: false,
          title: Text(product.wareName, style: Theme.of(context).textTheme.caption),
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProductPage(product: product))
            );
          }
        );
      }).toList()
    );
  }

  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autocorrect: false,
          controller: _queryTextController,
          style: theme.primaryTextTheme.title,
          textInputAction: TextInputAction.search,
          onChanged: (String val) => setState((){}),
          onSubmitted: (String searchStr) async {
            _products = await Product.loadByName(searchStr);
            setState(() {});
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Поиск',
            hintStyle: theme.primaryTextTheme.title,
          ),
        ),
        actions: _buildActions(context),
      ),
      body: _products != null ? _buildProductList(context) : Container()
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      _queryTextController.text.isEmpty ?
        Container() :
        IconButton(icon: Icon(Icons.clear), onPressed: _reset)
      ];
  }

  void _reset() {
    _queryTextController.text = '';
    _products = null;
    setState(() {});
  }
}
