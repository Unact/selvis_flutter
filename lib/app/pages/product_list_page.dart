import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/group.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';

class ProductListPage extends StatefulWidget {
  final Group parentGroup;

  ProductListPage({Key key, @required this.parentGroup}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = [];

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: ListView(
        children: products.map((Product product) {
          return ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(product: product)));
            },
            title: Text(product.wareName, style: Theme.of(context).textTheme.caption),
            leading: SizedBox(
              child: Image.network(App.application.config.apiBaseUrl + 'images/${product.productGuid}.png'),
              width: 48,
              height: 52
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
    products = await Product.loadByGroup3(widget.parentGroup.title);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentGroup.title),
      ),
      body: _buildBody(context)
    );
  }
}
