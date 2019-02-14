import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:selvis_flutter/app/app.dart';
import 'package:selvis_flutter/app/models/group.dart';
import 'package:selvis_flutter/app/models/product.dart';
import 'package:selvis_flutter/app/modules/api.dart';
import 'package:selvis_flutter/app/pages/sub_groups_page.dart';
import 'package:selvis_flutter/app/pages/product_page.dart';
import 'package:selvis_flutter/app/widgets/api_page_widget.dart';

class CatalogPage extends StatefulWidget {
  CatalogPage({Key key}) : super(key: key);

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with WidgetsBindingObserver {
  final TextEditingController _queryTextController = TextEditingController();
  GlobalKey<ApiPageWidgetState> _apiWidgetKey = GlobalKey();
  List<Group> _groups = [];

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: Text(App.application.config.packageInfo.appName)
    );
  }

  Widget _buildHeader(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      color: theme.bottomAppBarColor,
      child: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          cursorColor: theme.textSelectionColor,
          autocorrect: false,
          controller: _queryTextController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: _scanBarcode
            ),
            border: InputBorder.none,
            hintText: 'Поиск'
          )
        ),
        errorBuilder: (BuildContext ctx, error) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Произошла ошибка',
              style: TextStyle(color: theme.errorColor),
            ),
          );
        },
        noItemsFoundBuilder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Ничего не найдено',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.disabledColor, fontSize: 14.0),
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
            title: Text(suggestion.wareName, style: Theme.of(context).textTheme.caption)
          );
        },
        onSuggestionSelected: (suggestion) async {
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (context) => ProductPage(product: suggestion))
          );
        }
      )
    );
  }

  Widget _buildSliver(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int idx) {
          Group group = _groups[idx];

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SubGroupsPage(parentGroup: group)));
            },
            child: Column(
              children: <Widget>[
                SizedBox(
                  child: group.image,
                  height: 112,
                  width: 112
                ),
                Text(
                  group.title,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center
                )
              ]
            )
          );
        },
        childCount: _groups.length
      )
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverStickyHeader(
          header: _buildHeader(context),
          sliver: _buildSliver(context)
        )
      ]
    );
  }

  Future<void> _loadData() async {
    List<Group> topGroups = await Group.loadFromRemote();
    _groups = topGroups.map((group) => group.childrenList).expand((el) => el).toList();
  }

  void _scanBarcode() async {
    String errorMsg;

    try {
      Product product = await Product.loadByBarcode(await BarcodeScanner.scan());

      if (product != null) {
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => ProductPage(product: product))
        );
      } else {
        errorMsg = 'Товар не найден';
      }
    } on PlatformException catch (e) {
      errorMsg = 'Произошла неизвестная ошибка';

      if (e.code == BarcodeScanner.CameraAccessDenied) {
        errorMsg = 'Необходимо дать доступ к использованию камеры';
      }
    } on ApiException catch (e) {
      errorMsg = e.errorMsg;
    }

    if (errorMsg != null) {
      _apiWidgetKey.currentState?.showMessage(errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApiPageWidget(
      key: _apiWidgetKey,
      buildAppBar: _buildAppBar,
      bodyWithPadding: false,
      buildBody: _buildBody,
      loadData: _loadData,
    );
  }
}
