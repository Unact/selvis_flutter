import 'package:flutter/material.dart';

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
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.only(top: 20.0),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 4.0,
      children: _products.map((Product product) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(product: product)));
          },
          child: Column(
            children: <Widget>[
              SizedBox(
                child: product.image,
                height: 64,
                width: 64
              ),
              SizedBox(height: 4.0),
              Text(
                product.wareName,
                style: TextStyle(fontSize: 12.0),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.left,
                maxLines: 3,
              ),
              SizedBox(height: 4.0),
              Row(
                children: <Widget>[
                  Text(
                    '${product.price} ',
                    style: Theme.of(context).textTheme.subtitle,
                    textAlign: TextAlign.left,
                  ),
                  Text('руб.', style: TextStyle(fontSize: 10.0))
                ],
              ),
            ]
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
