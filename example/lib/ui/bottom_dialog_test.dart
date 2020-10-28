import 'package:flutter/material.dart';
import 'package:flutter_ui_box/flutter_ui_kit.dart';

// ignore: must_be_immutable
class BottomDialogDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BottomDialogDemoState();
  }
}

class _BottomDialogDemoState extends State<BottomDialogDemo> {
  List<int> testDate = [1, 2, 3];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BottomDialogWrapper(
        buildChild: (context) {
          return _buildListChild(context);
//        return _buildNormalChild(context);
        },
        transformHeight: 450,
      ),
    );
  }

  Widget _buildListChild(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 450,
          color: Color(0xFFFFFFFF),
          child: ScrollConfiguration(
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return Center(
                    child: Text('$index'),
                  );
                },
                itemCount: 100),
            behavior: OverScrollBehavior(),
          ),
        )
      ],
    );
    ;
  }

  Widget _buildNormalChild(BuildContext context) {
    return Container(
        height: 550,
        width: MediaQuery.of(context).size.width,
        color: Color(0xFFFFFFFF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                BottomDialogWrapper.of(context).popSelf("我取消了");
              },
              child: Text(
                "取消",
                style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ));
  }
}
