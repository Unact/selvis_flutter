import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/models/delivery_address.dart';
import 'package:selvis_flutter/app/models/order.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/modules/dadata_api.dart';
import 'package:selvis_flutter/app/widgets/app_expansion_tile.dart';

class CompleteOrderPage extends StatefulWidget {
  final List<Product> products;

  CompleteOrderPage({Key key, @required this.products}) : super(key: key);

  @override
  _CompleteOrderPageState createState() => _CompleteOrderPageState();
}

class _CompleteOrderPageState extends State<CompleteOrderPage> {
  final DateTime _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final TextStyle _defaultTextStyle = TextStyle(fontSize: 14.0, color: Colors.black);
  final GlobalKey<AppExpansionTileState> _contactTile = GlobalKey<AppExpansionTileState>();
  final GlobalKey<AppExpansionTileState> _deliveryTile = GlobalKey<AppExpansionTileState>();
  final GlobalKey<AppExpansionTileState> _paymentTypeTile = GlobalKey<AppExpansionTileState>();
  final GlobalKey<AppExpansionTileState> _confirmationTile = GlobalKey<AppExpansionTileState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  String _contactErrorText;
  String _email = User.currentUser.isLoggedIn ? User.currentUser.email : null;
  String _name = User.currentUser.isLoggedIn ? User.currentUser.middlename : null;
  String _phone = User.currentUser.isLoggedIn ? User.currentUser.phone : null;
  String _manualDeliveryAddress;
  PaymentTypes _paymentType = PaymentTypes.cash;
  Map<String, dynamic> _currentLocation = {};
  List<dynamic> _deliveryAddressSuggestions = [];
  String _selectedDeliveryFiasGuid;
  DateTime _selectedDeliveryDate;
  DeliveryAddress _deliveryAddress;

  String fieldsErrorMsg() {
    String result = '';

    if (_email == null) result = 'Не заполнен E-mail';
    if (_name == null) result = 'Не заполнено Имя';
    if (_phone == null) result = 'Не заполнен телефон';
    if (_deliveryAddress == null) result = 'Не выбран адрес доставки';
    if (_contactErrorText != null) result = 'Необходимо авторизоваться';

    return result;
  }

  Future<void> _submitOrder() async {
    String errorMsg = fieldsErrorMsg();

    if (errorMsg.isNotEmpty) {
      showMessage(errorMsg);
      return;
    }

    try {
      await Order.createOrder(
        User.currentUser.lastDraft,
        _paymentType,
        _deliveryAddress.date,
        _phone,
        _email,
        _name,
        _manualDeliveryAddress,
        _selectedDeliveryFiasGuid
      );

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Заказ успешно создан'),
          );
        }
      );

      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    } on ApiException catch(e) {
      showMessage(e.errorMsg);
    }
  }

  void showMessage(String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateDeliveryData() async {
    try {
      List<DeliveryAddress> deliveryAddresses = await DeliveryAddress.loadForDelivery(
        User.currentUser.lastDraft,
        _selectedDeliveryFiasGuid,
        _selectedDeliveryDate,
        _manualDeliveryAddress
      );

      if (deliveryAddresses.isNotEmpty)
        _deliveryAddress = deliveryAddresses.first;

      setState(() {});
    } on ApiException catch(e) {
      showMessage(e.errorMsg);
    }
  }

  void _onPaymentTypeChange(val) {
    _paymentType = val;
    setState(() {});
    _confirmationTile.currentState?.expand();
  }

  Widget _buildNameTextField(BuildContext context) {
    TextEditingController controller = TextEditingController();
    controller.text = _name;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.0, right: 40.0, left: 40.0),
      child: TextField(
        controller: controller,
        style: _defaultTextStyle,
        onChanged: (String value) => _name = value,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Имя'
        ),
      ),
    );
  }

  Widget _buildPhoneTextField(BuildContext context) {
    TextEditingController controller = TextEditingController();

    controller.text = _phone;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.0, right: 40.0, left: 40.0),
      child: TextField(
        focusNode: _phoneFocusNode,
        controller: controller,
        style: _defaultTextStyle,
        onChanged: (String value) => _phone = value,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Телефон'
        ),
      ),
    );
  }

  Widget _buildEmailTextField(BuildContext context) {
    TextEditingController controller = TextEditingController();

    controller.text = _email;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.0, right: 40.0, left: 40.0),
      child: TextField(
        focusNode: _emailFocusNode,
        controller: controller,
        style: _defaultTextStyle,
        onChanged: (String value) => _email = value,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'E-mail',
          errorText: _contactErrorText
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressTextField(BuildContext context) {
    TextEditingController controller = TextEditingController();

    controller.text = _manualDeliveryAddress;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.0, right: 40.0, left: 40.0),
      child: TextField(
        controller: controller,
        style: _defaultTextStyle,
        onSubmitted: (String value) async {
          try {
            _manualDeliveryAddress = value;
            _deliveryAddressSuggestions = (await DadataApi.post(
              'suggest/address',
              body: {
                'count': 5,
                'locations_boost': [_currentLocation],
                'query': value
              }
            ))['suggestions'];
            setState(() {});
          } on DadataApiException catch(e) {
            showMessage(e.errorMsg);
          }
        },
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'Адрес доставки'
        ),
      ),
    );
  }

  List<Widget> _buildContactInfo(BuildContext context) {
    return <Widget>[
      _buildEmailTextField(context),
      _buildNameTextField(context),
      _buildPhoneTextField(context)
    ];
  }

  Widget _buildDeliveryDate(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 40.0, left: 40.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Желаемая дата доставки', style: TextStyle(fontSize: 10.0, color: Colors.grey))
              ]
            ),
            Row(
              children: <Widget>[
                Text(DateFormat.yMMMMd('ru').format(_selectedDeliveryDate)),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    size: 18.0
                  ),
                  onPressed: () async {
                    DateTime newDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDeliveryDate,
                      firstDate: _today,
                      lastDate: DateTime.now().add(Duration(days: 30))
                    );
                    if (newDate != null) {
                      _selectedDeliveryDate = newDate;
                      await _updateDeliveryData();
                    }
                  },
                )
              ],
            )
          ],
        )
    );
  }

  Widget _buildDeliveryAddressDropdown(BuildContext context) {
    if (_manualDeliveryAddress == null) {
      return Container();
    }

    if (_deliveryAddressSuggestions.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.0, right: 40.0, left: 40.0),
        child: DropdownButton(
          isExpanded: true,
          onChanged: (String value) async {
            _selectedDeliveryFiasGuid = value;
            await _updateDeliveryData();
          },
          value: _selectedDeliveryFiasGuid,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Container()
            )
          ]..addAll(
            _deliveryAddressSuggestions.map((dynamic suggestion) {

              return DropdownMenuItem<String>(
                value: suggestion['data']['fias_id'],
                child: Text(suggestion['value'], style: _defaultTextStyle)
              );
            })
          )
        )
      );
    }

    return Padding(
        padding: EdgeInsets.only(bottom: 16.0, right: 40.0, left: 40.0),
        child: Center(child: Text('Адрес не найден'))
    );
  }

  List<Widget> _buildDeliveryInfo(BuildContext context) {
    return <Widget>[
      _buildDeliveryDate(context),
      _buildDeliveryAddressTextField(context),
      _buildDeliveryAddressDropdown(context)
    ];
  }

  List<Widget> _buildPaymentTypeInfo(BuildContext context) {
    return <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _onPaymentTypeChange(PaymentTypes.cash);
            },
            child: Row(
              children: <Widget>[
                Radio(
                  value: PaymentTypes.cash,
                  groupValue: _paymentType,
                  onChanged: _onPaymentTypeChange,
                ),
                Expanded(child: Text('Наличными', style: _defaultTextStyle))
              ]
            )
          ),
          GestureDetector(
            onTap: () {
              _onPaymentTypeChange(PaymentTypes.cashless);
            },
            child: Row(
              children: <Widget>[
                Radio(
                  value: PaymentTypes.cashless,
                  groupValue: _paymentType,
                  onChanged: _onPaymentTypeChange,
                ),
                Expanded(child: Text('Безналичный перевод', style: _defaultTextStyle))
              ]
            )
          ),
          GestureDetector(
            onTap: () {
              _onPaymentTypeChange(PaymentTypes.card);
            },
            child: Row(
              children: <Widget>[
                Radio(
                  value: PaymentTypes.card,
                  groupValue: _paymentType,
                  onChanged: _onPaymentTypeChange,
                ),
                Expanded(child: Text('Банковская карта', style: _defaultTextStyle))
              ]
            )
          )
        ]
      )
    ];
  }

  Widget _buildDeliveryListTile(BuildContext context) {
    if (_deliveryAddress != null) {
      return ListTile(
        title: Text('Доставка на ${DateFormat.yMMMMd('ru').format(_deliveryAddress.date)}', style: _defaultTextStyle),
        trailing: Text(_deliveryAddress.deliveryCost.toStringAsFixed(2))
      );
    }

    return Container();
  }

  Widget _buildTotalListTile(BuildContext context) {
    double total = widget.products.map((Product product) => product.sum).fold(0, (curVal, el) => curVal + el);

    if (_deliveryAddress != null) {
      total += _deliveryAddress.deliveryCost;
    }

    return ListTile(
      title: Text('Итого:', style: _defaultTextStyle, textAlign: TextAlign.end),
      trailing: Text(total.toStringAsFixed(2))
    );
  }

  List<Widget> _buildConfirmationInfo(BuildContext context) {
    return [
      Column(
        children: widget.products.map<Widget>((Product product) {
          return ListTile(
            title: Text(product.wareName, style: _defaultTextStyle),
            subtitle: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Цена: ${product.price.toStringAsFixed(2)}\n',
                    style: TextStyle(color: Colors.grey, fontSize: 12.0)
                  ),
                  TextSpan(
                    text: 'Кол-во: ${product.quantity}',
                    style: TextStyle(color: Colors.grey, fontSize: 12.0)
                  )
                ]
              )
            ),
            trailing: Text(product.sum.toStringAsFixed(2))
          );
        }).toList()..add(
          _buildDeliveryListTile(context)
        )..add(
          _buildTotalListTile(context)
        )..add(
          Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: RaisedButton(
              child: Text('Заказать'),
              onPressed: _submitOrder
            )
          )
        )
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedDeliveryDate = _today;
    DadataApi.get('detectAddressByIp').then((res) {
      _currentLocation = res['location'];
    });

    _emailFocusNode.addListener(() async {
      _contactErrorText = null;

      if (_email != null && !User.currentUser.isLoggedIn && await User.userExists(_email)) {
        _contactErrorText = 'Авторизуйтесь, чтобы оформить заказ.';
      }
      setState(() {});
    });
    _phoneFocusNode.addListener(() async {
      if (_contactErrorText == null && _phone != null && _name != null && _email != null) {
        _contactTile.currentState?.collapse();
        _deliveryTile.currentState?.expand();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Оформление заказа')),
      body: ListView(
        children: <Widget>[
          AppExpansionTile(
            key: _contactTile,
            initiallyExpanded: true,
            title: Text('Контактная информация'),
            children: _buildContactInfo(context)
          ),
          AppExpansionTile(
            key: _deliveryTile,
            initiallyExpanded: false,
            title: Text('Доставка'),
            children: _buildDeliveryInfo(context)
          ),
          AppExpansionTile(
            key: _paymentTypeTile,
            initiallyExpanded: false,
            title: Text('Способ оплаты'),
            children: _buildPaymentTypeInfo(context)
          ),
          AppExpansionTile(
            key: _confirmationTile,
            initiallyExpanded: false,
            title: Text('Подтверждение заказа'),
            children: _buildConfirmationInfo(context)
          )
        ]
      )
    );
  }
}
