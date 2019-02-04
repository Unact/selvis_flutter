class OrderLine {
  String lineId;
  String name;
  double price;
  String skuGuid;
  int quantity;
  double sum;

  OrderLine(Map<String, dynamic> values) {
    lineId = values['lineId'];
    name = values['name'];
    price = values['price'];
    skuGuid = values['skuGuid'];
    quantity = values['quantity'];
    sum = values['sum'];
  }
}
