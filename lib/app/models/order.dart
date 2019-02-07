import 'package:intl/intl.dart';

import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/models/order_line.dart';
import 'package:selvis_flutter/app/utils/nullify.dart';

enum PaymentTypes {
  unknown,
  cash,
  cashless,
  card
}

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

  static Future<void> createOrder(
    String guid,
    PaymentTypes paymentType,
    DateTime deliveryDate,
    String phone,
    String email,
    String personName,
    String deliveryAddressText,
    String fiasCode
  ) async {
    await Api.post(
      'orderEditor/ready',
      params: {
        'legalTransaction': false,
        'guid': guid,
        'paymentMethod': paymentType.index,
        'email': email,
        'deliveryAddressText': deliveryAddressText,
        'fiasCode': fiasCode,
        'phoneForNotifications': phone,
        'deliveryDate': DateFormat('yyyy-MM-dd').format(deliveryDate),
      }
    );
  }

  static Future<List<Order>> loadHistory() async {
    List<dynamic> res = (await Api.get('orders/getDataRange', params: {'fetch': 10000}))['list'];

    return res.map<Order>((row) => Order(row)).toList();
  }

  Future<void> loadAdditionalData() async {
    Map<String, dynamic> res = await Api.get(
      'orders/getLinesDataRange',
      params: {
        'guid': guid,
        'fetch': 10000
      }
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
