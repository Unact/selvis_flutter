import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/order_line.dart';
import 'package:selvis_flutter/app/utils/nullify.dart';

class Order {
  String guid;
  String number;
  String shipAddress;
  double total;
  DateTime deliveryDate;
  String statusName;
  String trackingMessage;
  DateTime trackingTimestamp;
  List<OrderLine> orderLines = [];

  Order(Map<String, dynamic> values) {
    guid = values['guid'];
    number = values['number'];
    total = values['total'];
    shipAddress = values['shipAddress'];
    deliveryDate = Nullify.parseDate(values['deliveryDate']);
  }

  static Future<List<Order>> loadHistory() async {
    List<dynamic> res = (await App.application.api.get('orders/getDataRange', params: {'fetch': 10000}))['list'];

    return res.map<Order>((row) => Order(row)).toList();
  }

  Future<void> loadInfo() async {
    Map<String, dynamic> res = await App.application.api.get(
      'orders/getLinesDataRange',
      params: {'guid': guid, 'fetch': 10000}
    );
    List<dynamic> tracking = res['tracking'];

    if (tracking != null && tracking.isNotEmpty) {
      trackingMessage = tracking.first['message'];
      trackingTimestamp = Nullify.parseDate(tracking.first['timestamp']);
    }
    statusName = res['order']['statusName'];
    orderLines = res['list'].map<OrderLine>((row) => OrderLine(row)).toList();
  }
}
