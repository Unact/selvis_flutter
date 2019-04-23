import 'package:intl/intl.dart';

import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/utils/nullify.dart';

class DeliveryAddress {
  static const kPickupId = 'pickup';
  double deliveryCost;
  DateTime date;
  String message;
  String title;
  String serviceId;

  bool get isPickup => serviceId == kPickupId;

  DeliveryAddress(Map<String, dynamic> values) {
    deliveryCost = Nullify.parseDouble(values['deliveryCost']);
    date = Nullify.parseDate(values['date']);
    title = values['title'];
    message = values['message'];
    serviceId = values['serviceId'];
  }

  static Future<List<DeliveryAddress>> loadForDelivery(String guid, DateTime date) async {
    List<dynamic> res = (await Api.post(
      'orderEditor/getDeliveryVariants',
      params: {
        'guid': guid,
        'deliveryDate': DateFormat('yyyy-MM-dd').format(date)
    })).first;

    return res.map<DeliveryAddress>((row) => DeliveryAddress(row)).toList();
  }
}
