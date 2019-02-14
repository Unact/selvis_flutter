import 'package:flutter/material.dart';

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
              ]..addAll([
                _buildTableRow(context, 'Цена', widget.product.price.toString()),
                _buildTableRow(context, 'НДС', (widget.product.vat?.toStringAsFixed(0) ?? 'Не задан')),
              ])..addAll(widget.product.productSpecs.map((ProductSpec spec) {
                return _buildTableRow(context, spec.name, spec.value);
              }))
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            padding: EdgeInsets.only(right: 8, left: 8),
            color: Theme.of(context).accentColor,
            child: Text('-${widget.product.multiple}', style: Theme.of(context).primaryTextTheme.button),
            onPressed: () async {
              int newQuantity = widget.product.quantity - widget.product.multiple;

              await widget.product.changeQuantity(newQuantity, User.currentUser.lastDraft);
              setState((){});
            },
          ),
          FlatButton(
            onPressed: null,
            child: Text(widget.product.quantity.toStringAsFixed(0), style: Theme.of(context).textTheme.title),
          ),
          FlatButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            color: Theme.of(context).accentColor,
            child: Text('+${widget.product.multiple}', style: Theme.of(context).primaryTextTheme.button),
            onPressed: () async {
              int newQuantity = widget.product.quantity + widget.product.multiple;

              await widget.product.changeQuantity(newQuantity, User.currentUser.lastDraft);
              setState((){});
            },
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      buildBottomNavigationBar: _buildBottomNavigationBar,
      buildAppBar: _buildAppBar,
      buildBody: _buildBody,
      loadData: _loadData,
    );
  }
}
