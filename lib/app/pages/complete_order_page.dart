import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:selvis_flutter/app/models/delivery_address.dart';
import 'package:selvis_flutter/app/models/order.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/models/user.dart';
import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/utils/nullify.dart';
import 'package:selvis_flutter/app/widgets/app_expansion_tile.dart';

class CompleteOrderPage extends StatefulWidget {
  final List<Product> products;

  CompleteOrderPage({Key key, @required this.products}) : super(key: key);

  @override
  _CompleteOrderPageState createState() => _CompleteOrderPageState();
}

class _CompleteOrderPageState extends State<CompleteOrderPage> {
  final TextEditingController _deliveryAddressController = TextEditingController();
  final DateTime _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final TextStyle _defaultTextStyle = TextStyle(fontSize: 14.0, color: Colors.black);
  final TextStyle _textFieldStyle = TextStyle(fontSize: 16.0);
  final TextStyle _rowTextStyle = TextStyle(fontSize: 12.0, color: Colors.grey);
  final GlobalKey<AppExpansionTileState> _contactTile = GlobalKey<AppExpansionTileState>();
  final GlobalKey<AppExpansionTileState> _deliveryTile = GlobalKey<AppExpansionTileState>();
  final GlobalKey<AppExpansionTileState> _paymentTypeTile = GlobalKey<AppExpansionTileState>();
  final GlobalKey<AppExpansionTileState> _confirmationTile = GlobalKey<AppExpansionTileState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  String _contactErrorText;
  String _email = User.currentUser.isLoggedIn ? User.currentUser.email : '';
  String _name = '';
  String _phone = User.currentUser.isLoggedIn ? User.currentUser.phone : '';
  String _deliveryAddressText = '';
  PaymentTypes _paymentType = PaymentTypes.cash;
  List<String> _pickupAddresses = [];
  List<DeliveryAddress> _deliveryAddresses = [];
  DateTime _deliveryDate;
  DeliveryAddress _deliveryAddress;
  UserAddress _userAddress;
  List<DateTime> _deliveryDates = [];
  String _deliveryNotes;

  String fieldsErrorMsg() {
    String result = '';

    if (_email == '') result = 'Не заполнен E-mail';
    if (_name == '') result = 'Не заполнено Имя';
    if (_phone == '') result = 'Не заполнен телефон';
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
        _deliveryAddress.serviceId,
        _paymentType,
        _deliveryAddress.date,
        _phone,
        _email,
        _name,
        deliveryNotes: _deliveryNotes,
        deliveryAddressText: _deliveryAddressText,
        addressId: _userAddress?.addressId
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

  void _onPaymentTypeChange(val) {
    _paymentType = val;
    setState(() {});
    _confirmationTile.currentState?.expand();
  }

  Widget _buildName(BuildContext context) {
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
          labelText: 'Имя',
          labelStyle: _textFieldStyle
        ),
      ),
    );
  }

  Widget _buildPhone(BuildContext context) {
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
          labelText: 'Телефон',
          labelStyle: _textFieldStyle
        ),
      ),
    );
  }

  Widget _buildEmail(BuildContext context) {
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
          labelStyle: _textFieldStyle,
          errorText: _contactErrorText
        ),
      ),
    );
  }

  List<Widget> _buildContactInfo(BuildContext context) {
    return <Widget>[
      _buildEmail(context),
      _buildName(context),
      _buildPhone(context)
    ];
  }

  Widget _buildDeliveryDate(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 40.0, left: 40.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Желаемая дата получения', style: TextStyle(fontSize: 12.0, color: Colors.grey))
            ]
          ),
          Row(
            children: <Widget>[
              Text(DateFormat.yMMMMd('ru').format(_deliveryDate)),
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  size: 18.0
                ),
                onPressed: () async {
                  DateTime newDate = await showDatePicker(
                    context: context,
                    initialDate: _deliveryDate,
                    firstDate: _today,
                    lastDate: DateTime.now().add(Duration(days: 30)),
                    selectableDayPredicate: (DateTime val) => _deliveryDates.any((deliveryDay) => deliveryDay == val)
                  );
                  if (newDate != null) {
                    _deliveryDate = newDate;
                    _updateDeliveryAddresses();
                  }
                },
              )
            ],
          )
        ],
      )
    );
  }

  Widget _buildDeliveryAddress(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 40.0, left: 40.0, bottom: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Способ получения', style: _rowTextStyle)
            ]
          ),
          _buildDeliveryAddressDropdown(context),
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Text('Адрес получения', style: _rowTextStyle)
            ]
          )
        ]..addAll(_buildAddressSelect(context))..add(_buildNotesTextField(context))
      )
    );
  }

  List<Widget> _buildAddressSelect(context) {
    if (_deliveryAddress == null)
      return [Container()];

    if (_deliveryAddress.isPickup)
      return [_buildPickupAddressDropdown(context)];

    return [
      _buildDeliveryAddressTextField(context),
      _buildUserAddressDropdown(context)
    ];
  }

  Widget _buildNotesTextField(context) {
    TextEditingController controller = TextEditingController();
    controller.text = _deliveryNotes;

    return TextField(
      controller: controller,
      style: _defaultTextStyle,
      onChanged: (String value) => _deliveryNotes = value,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Комментарий',
        labelStyle: _textFieldStyle
      ),
    );
  }

  Widget _buildPickupAddressDropdown(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      onChanged: (String value) {
        _deliveryAddressText = value;

        setState(() {});
      },
      value: _deliveryAddressText,
      items: _pickupAddresses.map((String address) {
        return DropdownMenuItem<String>(
          value: address,
          child: Text(address, style: _defaultTextStyle)
        );
      }).toList()
    );
  }

  Widget _buildDeliveryAddressDropdown(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      onChanged: (DeliveryAddress value) {
        _deliveryAddress = value;
        _deliveryAddressText = _deliveryAddress.isPickup ? _pickupAddresses.first : '';

        setState(() {});
      },
      value: _deliveryAddress,
      items: _deliveryAddresses.map((DeliveryAddress address) {
        return DropdownMenuItem<DeliveryAddress>(
          value: address,
          child: Text(address.title, style: _defaultTextStyle)
        );
      }).toList()
    );
  }

  Widget _buildUserAddressDropdown(BuildContext context) {
    List<UserAddress> addresses = User.currentUser.addresses;

    if (addresses.isEmpty) {
      return Container();
    }

    return DropdownButton(
      isExpanded: true,
      onChanged: (UserAddress userAddress) async {
        _deliveryAddressText = userAddress.address;
        _userAddress = userAddress;
        setState(() {});
      },
      value: _userAddress,
      items: addresses.map((UserAddress userAddress) {
        return DropdownMenuItem<UserAddress>(
          value: userAddress,
          child: Text(userAddress.address, style: _defaultTextStyle)
        );
      }).toList()
    );
  }

  Widget _buildDeliveryAddressTextField(BuildContext context) {
    _deliveryAddressController.text = _deliveryAddressText;

    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _deliveryAddressController,
        style: _defaultTextStyle
      ),
      errorBuilder: (BuildContext ctx, error) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Произошла ошибка',
            style: TextStyle(color: Theme.of(context).errorColor, fontSize: 14.0),
          ),
        );
      },
      noItemsFoundBuilder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Ничего не найдено',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 14.0),
          ),
        );
      },
      suggestionsCallback: (String value) async {
        List<dynamic> res = await Api.post(
          'orderEditor/suggestAddress',
          body: {
            'deliveryAddressText': value
          }
        );
        return res;
      },
      itemBuilder: (BuildContext ctx, suggestion) {
        return ListTile(title: Text(suggestion['value'], style: Theme.of(context).textTheme.caption));
      },
      onSuggestionSelected: (suggestion) async {
        _deliveryAddressController.text = suggestion['value'];
        _deliveryAddressText = _deliveryAddressController.text;
        setState(() {});
      }
    );
  }

  List<Widget> _buildDeliveryInfo(BuildContext context) {
    return <Widget>[
      _buildDeliveryDate(context),
      _buildDeliveryAddress(context)
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
                Expanded(child: Text('Оплата наличными', style: _defaultTextStyle))
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
                Expanded(child: Text('Безналичный расчет', style: _defaultTextStyle))
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
                Expanded(child: Text('Оплата картой', style: _defaultTextStyle))
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
        title: Text('Доставка ${DateFormat.yMMMMd('ru').format(_deliveryAddress.date)}', style: _defaultTextStyle),
        subtitle: Text(
          _deliveryAddress.message ?? _deliveryAddressText,
          style: _rowTextStyle
        ),
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
                    style: _rowTextStyle
                  ),
                  TextSpan(
                    text: 'Кол-во: ${product.quantity}',
                    style: _rowTextStyle
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
              color: Theme.of(context).accentColor,
              child: Text('Заказать', style: Theme.of(context).primaryTextTheme.button),
              onPressed: _submitOrder
            )
          )
        )
      )
    ];
  }

  Future<void> _updateDeliveryAddresses() async {
    _deliveryAddresses = await DeliveryAddress.loadForDelivery(
      User.currentUser.lastDraft,
      _deliveryDate
    );

    if (_deliveryAddresses.isNotEmpty) _deliveryAddress = _deliveryAddresses.first;
    if (_deliveryAddress != null && _deliveryAddress.isPickup) _deliveryAddressText = _pickupAddresses.first;
    setState(() {});
  }

  Future<void> _loadData() async {
    try {
      _deliveryDate = _today;
      _deliveryDates = (await Api.get(
        '/orderEditor/getDeliveryDates',
        params: {
          'guid': User.currentUser.lastDraft,
          'deliveryDate': DateFormat('yyyy-MM-dd').format(DateTime.now())
        }
      )).map<DateTime>((val) => Nullify.parseDate(val)).toList();
      _pickupAddresses = List<String>.from(await Api.get('/scripts/pickups.json'));

      if (User.currentUser.addresses.isNotEmpty) {
        UserAddress userAddress = User.currentUser.addresses.first;

        _deliveryAddressText = userAddress.address;
        _userAddress = userAddress;
        _name = userAddress.legalName;
      }

      if (_deliveryDates.isNotEmpty) _deliveryDate = _deliveryDates.first;

      await _updateDeliveryAddresses();

      setState(() {});
    } on ApiException catch(e) {
      showMessage(e.errorMsg);
    }
  }

  @override
  void initState() {
    super.initState();

    _loadData();

    _emailFocusNode.addListener(() async {
      _contactErrorText = null;

      if (_email != '' && !User.currentUser.isLoggedIn && await User.userExists(_email)) {
        _contactErrorText = 'Авторизуйтесь, чтобы оформить заказ.';
      }
      setState(() {});
    });
    _phoneFocusNode.addListener(() async {
      if (_contactErrorText == null && _phone != '' && _name != '' && _email != '') {
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
