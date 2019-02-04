import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/group.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class ProductListPage extends StatefulWidget {
  final Group parentGroup;

  ProductListPage({Key key, @required this.parentGroup}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.parentGroup.title),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      children: _products.map((Product product) {
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
    );
  }

  Future<void> _loadData() async {
    _products = await Product.loadByGroup3(widget.parentGroup.title);
  }

  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
      loadData: _loadData,
    );
  }
}
