import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/models/order.dart';
import 'package:selvis_flutter/app/pages/order_lines_page.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class OrdersPage extends StatefulWidget {
  OrdersPage({Key key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Order> _orders = [];

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Список заказов'),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      children: _orders.map((Order order) {
        return ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OrderLinesPage(order: order)));
          },
          title: Text('№ ${order.number}'),
          subtitle: Text('от ${DateFormat.yMMMMd('ru').format(order.deliveryDate)}'),
          trailing: Text(order.total.toString())
        );
      }).toList()
    );
  }

  Future<void> _loadData() async {
    _orders = await Order.loadHistory();
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
