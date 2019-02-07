import 'package:intl/intl.dart';

import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/utils/nullify.dart';

class DeliveryAddress {
  double deliveryCost;
  DateTime date;

  DeliveryAddress(Map<String, dynamic> values) {
    deliveryCost = Nullify.parseDouble(values['deliveryCost']);
    date = Nullify.parseDate(values['date']);
  }

  static Future<List<DeliveryAddress>> loadForDelivery(
    String guid,
    String fiasCode,
    DateTime date,
    String addressText
  ) async {
    List<dynamic> res = (await Api.post(
      'orderEditor/getDeliveryVariants',
      params: {
        'guid': guid,
        'fiasCode': fiasCode,
        'deliveryDate': DateFormat('yyyy-MM-dd').format(date),
        'deliveryAddressText': addressText
    })).first;

    return res.map<DeliveryAddress>((row) => DeliveryAddress(row)).toList();
  }
}
