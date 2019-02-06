import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/models/product_spec.dart';
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
              child: widget.product.image,
              width: 260,
              height: 200
            ),
            Table(
              columnWidths: <int, TableColumnWidth>{
                0: FixedColumnWidth(132.0)
              },
              children: <TableRow>[
                _buildTableRow(context, 'Товар', widget.product.wareName),
              ]..addAll(widget.product.productSpecs.map((ProductSpec spec) {
                return _buildTableRow(context, spec.name, spec.value);
              }))..addAll([
                _buildTableRow(context, 'НДС', (widget.product.vat?.toStringAsFixed(0) ?? 'Не задан')),
                _buildTableRow(context, 'Цена', widget.product.price.toString()),
                _buildTableRow(context, 'Кол-во', widget.product.quantity.toStringAsFixed(0)),
                _buildTableRow(context, 'Итого', widget.product.sum.toStringAsFixed(2)),
              ])
            ),
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
                SizedBox(width: 20),
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
          ]
        )
      ]
    );
  }

  TableRow _buildTableRow(BuildContext context, String key, String value) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 4.0, right: 8.0),
          child: Text(key, style: TextStyle(color: Theme.of(context).accentColor), textAlign: TextAlign.end)
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(value, style: TextStyle(fontSize: 14.0, color: Colors.black)),
        ),
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
