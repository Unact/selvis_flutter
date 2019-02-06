class ProductSpec {
  String value;
  String name;
  bool invisible;

  ProductSpec(Map<String, dynamic> values) {
    value = values['value'];
    name = values['name'];
    invisible = values['invisible'];
  }
}
