import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/models/order.dart';
import 'package:selvis_flutter/app/models/order_line.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class OrderLinesPage extends StatefulWidget {
  final Order order;

  OrderLinesPage({Key key, @required this.order}) : super(key: key);

  @override
  _OrderLinesPageState createState() => _OrderLinesPageState();
}

class _OrderLinesPageState extends State<OrderLinesPage> {
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.order.number),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 8.0),
      children: <Widget>[
        Table(
          columnWidths: <int, TableColumnWidth>{
            0: FixedColumnWidth(132.0)
          },
          children: <TableRow>[
            _buildTableRow(context, 'Адрес доставки', widget.order.shipAddress),
            _buildTableRow(context, 'Дата доставки', DateFormat.yMMMMd('ru').format(widget.order.deliveryDate)),
            _buildTableRow(context, 'Состояние заказа', widget.order.statusName?.toString() ?? 'Не определен'),
            _buildTableRow(context, 'Итого', widget.order.total.toStringAsFixed(2)),
          ]
        )
      ]..addAll(widget.order.orderLines.map((OrderLine orderLine) {
        return ListTile(
          title: Text(orderLine.name, style: Theme.of(context).textTheme.caption),
          subtitle: Text('${orderLine.quantity} X ${orderLine.price}'),
          trailing: Text(orderLine.sum.toString())
        );
      }).toList())
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
    await widget.order.loadAdditionalData();
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
