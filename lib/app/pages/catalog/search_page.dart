import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _queryTextController = TextEditingController();

  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            autocorrect: false,
            controller: _queryTextController,
            style: theme.primaryTextTheme.title,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Поиск',
              hintStyle: theme.primaryTextTheme.title,
            )
          ),
          errorBuilder: (BuildContext ctx, error) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Произошла ошибка',
                style: TextStyle(color: Theme.of(context).errorColor),
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
            return value.isNotEmpty ? await Product.loadByName(value) : [];
          },
          itemBuilder: (BuildContext ctx, suggestion) {
            return ListTile(
              leading: SizedBox(
                child: suggestion.image,
                width: 48,
                height: 52
              ),
              isThreeLine: false,
              title: Text(suggestion.wareName, style: Theme.of(context).textTheme.caption),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ProductPage(product: suggestion))
                );
              }
            );
          },
          onSuggestionSelected: (suggestion) async {

          }
        ),
        actions: _buildActions(context),
      ),
      body: Container()
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      _queryTextController.text.isEmpty ?
        Container() :
        IconButton(icon: Icon(Icons.clear), onPressed: _reset)
      ];
  }

  void _reset() {
    _queryTextController.text = '';
    setState(() {});
  }
}
