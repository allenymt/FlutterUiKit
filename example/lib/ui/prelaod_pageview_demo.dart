import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_box/flutter_ui_kit.dart';

/// do what
/// @author yulun
/// @since 2020-09-01 10:12
class PreLoadPageViewDemo extends StatefulWidget {
  @override
  State<PreLoadPageViewDemo> createState() {
    return _PreLoadPageViewtState();
  }
}

class _PreLoadPageViewtState extends State<PreLoadPageViewDemo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget child = PreloadPageView.builder(
      itemCount: 10,
      controller: PageController(),
      itemBuilder: (context, index) {
        print("index is $index");
        return GestureDetector(
          onTap: () {
            print("tap index is $index");
          },
          child: Center(child: Text("$index")),
        );
      },
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      preloadPagesCount: 2,
    );

    child = Stack(
      children: <Widget>[
        child,
        Positioned(
          bottom: 18,
          right: 15,
          child: Text.rich(TextSpan(
            children: [
              TextSpan(
                  text: "${_currentIndex + 1}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
              TextSpan(
                  text: "10",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black))
            ],
          )),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("预加载pageview"),
      ),
      body: Center(
        child: child,
      ),
    );
  }
}
