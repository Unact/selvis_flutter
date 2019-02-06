import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/modules/api.dart';

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
  Image get image => Image.network(App.application.config.apiBaseUrl + 'images/$productGuid.png');

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
    List<dynamic> res = (await Api.get(
      'orderEditor/getDataRange',
      params: {
        'group3': group3,
        'fetch': 10000
      })
    )['list'];
    return res.map<Product>((row) => Product(row)).toList();
  }

  static Future<List<Product>> loadOrdered(String draftGuid) async {
    List<dynamic> res = (await Api.get(
      'orderEditor/getDataRange',
      params: {
        'guid': draftGuid,
        'fetch': 10000,
        'orderedOnly': true
      })
    )['list'];

    return res.map<Product>((row) => Product(row)).toList();
  }

  static Future<Product> loadByBarcode(String barcode) async {
    Map<String, dynamic> res = (
      await Api.get('orderEditor/getSkuSpec', params: {'barcode': barcode})
    )['line'];

    return Product(res);
  }

  static Future<List<Product>> loadByName(String name) async {
    List<dynamic> res = (await Api.get(
      'orderEditor/getDataRange',
      params: {
        'search': name,
        'fetch': 10000
      })
    )['list'];

    return res.map<Product>((row) => Product(row)).toList();
  }

  Future<void> loadAdditionalData() async {
    Map<String, dynamic> res = await Api.get('orderEditor/getSkuSpec', params: {'skuGuid': skuGuid});

    specs = res['specs'];
    vat = res['vat'];
  }

  Future<void> changeQuantity(int newQuantity, String draftGuid) async {
    int sendQuantity = newQuantity > 0 ? newQuantity : 0;

    if (sendQuantity != quantity) {
      quantity = sendQuantity;
      await Api.post(
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
