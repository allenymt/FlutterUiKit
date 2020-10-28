import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_box/flutter_ui_kit.dart';

/// do what
/// @author yulun
/// @since 2020-09-08 09:25

class FoldUpDemo extends StatelessWidget {
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
        title: Text("文本展开收起控件"),
      ),
      body: Container(
          margin: EdgeInsets.only(left: 0, top: 20, right: 0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 30,
              ),
              FoldUpTextWidget(
                maxLines: 4,
                buildSpan: (expand, gestureRecognizer, [style]) {
                  return TextSpan(
                      text: expand ? " ..收起" : " ..展开",
                      recognizer: gestureRecognizer,
                      style: TextStyle(color: Colors.blueAccent, fontSize: 12));
                },
                textStyle: TextStyle(color: Colors.black, fontSize: 18),
                inlineSpanList: []
                  ..add(SizedWidgetSpan(
                    width: 30,
                    height: 30,
                    child: Image.asset(
                      "assets/images/test.png",
                      width: 30,
                      height: 30,
                    ),
                    alignment: ui.PlaceholderAlignment.middle,
                  ))
                  ..add(TextSpan(
                      text: "我是绿色的测试文案", style: TextStyle(color: Colors.green)))
                  ..add(TextSpan(
                      text: "我是红色的测试文案", style: TextStyle(color: Colors.red)))
                  ..add(TextSpan(
                      text: "我是黄色的测试文案123123",
                      style: TextStyle(color: Colors.yellow)))
                  ..add(TextSpan(
                      text: "我是黑色的测试文案", style: TextStyle(color: Colors.black)))
                  ..add(TextSpan(
                      text: "我我是大字号的测试文案",
                      style: TextStyle(color: Colors.orange, fontSize: 22)))
                  ..add(TextSpan(
                      text: "我我是小字号的测试文案",
                      style: TextStyle(color: Colors.orange, fontSize: 10)))
                  ..add(TextSpan(
                      text:
                          "第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine",
                      style: TextStyle(color: Colors.green))),
              ),
            ],
          )),
    );
  }

  /// 动态真实的文案
  List<InlineSpan> _buildText(BuildContext context) {
    String content =
        "第一行文案很长直接超过maxLine第https://www.baidu.com一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文案很长直接超过maxLine第一行文https://www.baidu.com案很长直接超过maxLine";
    //"${feedCard?.feed?.feedContent?.trim()}sdfas sdf dsfd fl水电费啦水电费可都是粉色发爱是方大师方大师方大师发第三方第三方说的发送到方大师方大师方大师方大师方大师发的沙发垫是否第三方都是方大师方大师方大师发第三方士大夫都是方大师方大师方大师";
    if (isEmpty(content)) return [];
    return LinkUrlTextHelper.parseHttpLink(
      content: content,
      linkUrlConfig: LinkUrlConfig.defaultConfig(onLinkTap: (url) {
        // 跳转h5
      }),
    );
  }
}
