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
    return Column(
      children: <Widget>[
        Text('Адрес доставки: ${widget.order.shipAddress}'),
        Text('Дата доставки: ${DateFormat.yMMMMd('ru').format(widget.order.deliveryDate)}'),
        Text('Состояние заказа: ${widget.order.statusName}'),
        Text('Итого: ${widget.order.total}'),
        Expanded(
          child: ListView(
            children: widget.order.orderLines.map((OrderLine orderLine) {
              return ListTile(
                title: Text(orderLine.name, style: Theme.of(context).textTheme.caption),
                subtitle: Text('${orderLine.quantity} X ${orderLine.price}'),
                trailing: Text(orderLine.sum.toString())
              );
            }).toList()
          )
        )
      ]
    );
  }

  Future<void> _loadData() async {
    await widget.order.loadInfo();
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
