import 'package:selvis_flutter/app/app.dart';

class Product {
  String skuGuid;
  String productGuid;
  String wareName;
  String brand;
  int productCount;
  int quantity;
  double price;
  double vat;
  int multiple;
  List<dynamic> specs;

  double get sum => price * quantity;

  Product(Map<String, dynamic> values) {
    skuGuid = values['skuGuid'];
    productGuid = values['productGuid'];
    productCount = values['productCount'];
    wareName = values['wareName'];
    brand = values['brand'];
    specs = values['specs'];
    vat = values['vat'];
    quantity = values['quantity'];
    price = values['price'];
    multiple = values['multiples'].first['value'];
  }

  static Future<List<Product>> loadByGroup3(String group3) async {
    List<dynamic> res = (
      await App.application.api.get('orderEditor/getDataRange', params: {'group3': group3, 'fetch': 10000})
    )['list'];
    return res.map<Product>((row) => Product(row)).toList();
  }

  static Future<List<Product>> loadOrdered(String draftGuid) async {
    List<dynamic> res = (
      await App.application.api.get(
        'orderEditor/getDataRange',
        params: {
          'guid': draftGuid,
          'fetch': 10000,
          'orderedOnly': true
        }
      )
    )['list'];

    return res.map<Product>((row) => Product(row)).toList();
  }

  static Future<Product> loadByBarcode(String barcode) async {
    Map<String, dynamic> res = (
      await App.application.api.get('orderEditor/getSkuSpec', params: {'barcode': barcode})
    )['line'];

    return Product(res);
  }

  Future<void> loadAdditionalData() async {
    Map<String, dynamic> res = await App.application.api.get('orderEditor/getSkuSpec', params: {'skuGuid': skuGuid});

    specs = res['specs'];
    vat = res['vat'];
  }

  Future<void> changeQuantity(int newQuantity, String draftGuid) async {
    int sendQuantity = newQuantity > 0 ? newQuantity : 0;

    if (sendQuantity != quantity) {
      quantity = sendQuantity;
      await App.application.api.post(
        'orderEditor/manageLine',
        params: {
          'quantity': sendQuantity,
          'skuId': skuGuid,
          'guid': draftGuid
        }
      );
    }
  }
}
