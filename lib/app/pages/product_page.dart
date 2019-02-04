import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  ProductPage({Key key, @required this.product}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Товар'),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 8.0),
      children: [
        Column(
          children: <Widget>[
            SizedBox(
              child: Image.network(App.application.config.apiBaseUrl + 'images/${widget.product.productGuid}.png'),
              width: 260,
              height: 200
            ),
            Text(widget.product.wareName),
            Text('НДС: ${widget.product.vat ?? ''}', textAlign: TextAlign.left,),
            Text('Цена: ${widget.product.price ?? 0}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('-${widget.product.multiple}'),
                  onPressed: () async {
                    int newQuantity = widget.product.quantity - widget.product.multiple;

                    await widget.product.changeQuantity(newQuantity, User.currentUser.lastDraft);
                    setState((){});
                  },
                ),
                Text('${widget.product.quantity ?? 0}'),
                RaisedButton(
                  child: Text('+${widget.product.multiple}'),
                  onPressed: () async {
                    int newQuantity = widget.product.quantity + widget.product.multiple;

                    await widget.product.changeQuantity(newQuantity, User.currentUser.lastDraft);
                    setState((){});
                  },
                )
              ]
            ),
            Text('Итого: ${widget.product.sum}', textAlign: TextAlign.left,)
          ]
        )
      ]
    );
  }

  Future<void> _loadData() async {
    await widget.product.loadAdditionalData();
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
