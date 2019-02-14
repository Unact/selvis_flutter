import 'package:flutter/material.dart';

import 'package:selvis_flutter/app/modules/api.dart';

class ApiPageWidget extends StatefulWidget {
  final Function buildPersistentFooterButtons;
  final Function buildBottomNavigationBar;
  final Function buildAppBar;
  final Function buildBody;
  final Function loadData;
  final bool bodyWithPadding;

  ApiPageWidget({
    Key key,
    @required this.buildAppBar,
    @required this.buildBody,
    this.bodyWithPadding = true,
    this.buildBottomNavigationBar,
    this.buildPersistentFooterButtons,
    this.loadData,
  }) : super(key: key);

  @override
  ApiPageWidgetState createState() => ApiPageWidgetState();
}

class ApiPageWidgetState extends State<ApiPageWidget> with WidgetsBindingObserver {
  static const _kRefreshWaitMs = 200;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  void showMessage(String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadData() async {
    try {
      await widget?.loadData();
    } on ApiException catch(e) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(e.errorMsg)));
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: _kRefreshWaitMs)).then((_) {
      if (widget.loadData != null) {
        _refreshIndicatorKey.currentState?.show();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshIndicatorKey.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.buildAppBar(context),
      persistentFooterButtons: widget.buildPersistentFooterButtons != null ?
        widget.buildPersistentFooterButtons(context) :
        null,
      bottomNavigationBar: widget.buildBottomNavigationBar != null ?
        widget.buildBottomNavigationBar(context) :
        null,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _loadData,
        child: Container(
          padding: widget.bodyWithPadding ? EdgeInsets.only(left: 8.0, right: 8.0) : EdgeInsets.all(0),
          child: widget.buildBody(context)
        )
      )
    );
  }
}
