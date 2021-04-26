import 'package:flutter/material.dart';

import 'ui/animation_pageview_demo.dart';
import 'ui/bottom_dialog_test.dart';
import 'ui/cascade_pick_demo.dart';
import 'ui/data_select_dialog.dart';
import 'ui/fold_up_demo.dart';
import 'ui/infinite_pageview_demo.dart';
import 'ui/prelaod_pageview_demo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WidgetDemoPageList(),
    );
  }
}

class WidgetDemoPageList extends StatefulWidget {
  @override
  _WidgetDemoPageListState createState() => _WidgetDemoPageListState();
}

class _WidgetDemoPageListState extends State<WidgetDemoPageList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Demo列表'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('级联选择框'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return CascadePickDemo();
              }));
            },
          ),
          ListTile(
            title: Text('日期选择框'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return CascadeTestWidget();
              }));
            },
          ),
          ListTile(
            title: Text('高度自适应banner'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AnimationPageViewWidget();
              }));
            },
          ),
          ListTile(
            title: Text('预加载pageView'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PreLoadPageViewDemo();
              }));
            },
          ),
          ListTile(
            title: Text('底部弹框demo'),
            onTap: () {
              Navigator.of(context).push(DialogRoute(builder: (context) {
                return BottomDialogDemo();
              }));
            },
          ),
          ListTile(
            title: Text('折叠文本demo'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FoldUpDemo();
              }));
            },
          ),
          ListTile(
            title: Text('折叠文本demo'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Scaffold(
                  body: Center(
                      child: GestureDetector(
                    onTap: () {
                      print('tab parent');
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          print('tab child');
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  )),
                );
              }));
            },
          ),

          ListTile(
            title: Text('无限轮播-自动轮播-PageView demo'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return InfinitePageViewDemo();
              }));
            },
          ),
        ],
      ),
    );
  }
}

class DialogRoute extends PopupRoute {
  DialogRoute({
    this.barrierColor,
    this.barrierLabel,
    this.builder,
    bool semanticsDismissible,
    RouteSettings settings,
  }) : super(
          settings: settings,
        ) {
    _semanticsDismissible = semanticsDismissible;
  }

  final WidgetBuilder builder;
  bool _semanticsDismissible;

  @override
  final String barrierLabel;

  @override
  final Color barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  bool get semanticsDismissible => _semanticsDismissible ?? false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }
}
