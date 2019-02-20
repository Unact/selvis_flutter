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
    return GridView.count(
      childAspectRatio: App.application.config.isTabletDevice ? 0.8 : 1,
      crossAxisCount: App.application.config.isTabletDevice ? 4 : 2,
      padding: EdgeInsets.only(top: _scaleForDevice(20)),
      crossAxisSpacing: _scaleForDevice(16),
      mainAxisSpacing: _scaleForDevice(4),
      children: _products.map((Product product) {
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => ProductPage(product: product))
            );
          },
          child: Column(
            children: <Widget>[
              SizedBox(
                child: product.image,
                height: _scaleForDevice(64),
                width: _scaleForDevice(64)
              ),
              SizedBox(height: _scaleForDevice(4)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.wareName,
                    style: TextStyle(fontSize: 12.0),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                  ),
                  SizedBox(height: _scaleForDevice(4)),
                  Row(
                    children: <Widget>[
                      Text(
                        '${product.price} ₽',
                        style: Theme.of(context).textTheme.subtitle,
                        textAlign: TextAlign.left,
                      )
                    ]
                  ),
                ]
              )
            ]
          )
        );
      }).toList()
    );
  }

  Future<void> _loadData() async {
    _products = await Product.loadByGroup3(widget.parentGroup.title);
  }

  double _scaleForDevice(double size) => App.application.config.isTabletDevice ? 2 * size : size;

  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
      loadData: _loadData,
    );
  }
}
