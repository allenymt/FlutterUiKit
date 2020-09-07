# FlutterUiKit

个人flutter ui 工具盒.
    
    v0.0.1 级联选择框，自定义支持日期选择，时间选择，省市级地址选择

# AnimationHeightViewWidget
    自适应高度容器，例如pageview左右滑动时 ，可以让pageview高度自动变化
    
# CascadeSelectWidget
    重写了系统的Picker,开放了更多的自定义属性
    
# FoldUpTextWidget 
    文本展开收起控件，支持配置最大行数，展开收起按钮样式，支持识别网页链接并替换

# PreloadPageView
    预加载的pageView，参考了 https://github.com/octomato/preload_page_view

# flutter_keyboard_visibility
    监听键盘弹出的插件
    github地址： https://github.com/allenyulun/flutter_keyboard_visibility
    在原有库的基础上，针对Android扩展了对混合栈的支持，需要的同学自取
    参考地址 https://github.com/adee42/flutter_keyboard_visibility，

# demo请见 
    https://github.com/allenyulun/flutter_just_test，对所有的Ui工具都会有演示
    
## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Installation
```yaml
dependencies:
  flutter_ui_box: ^0.0.1
```

### Import

```dart
import 'package:flutter_ui_kit/flutter_ui_kit.dart';
```

## Usage

```日期选择框```
```dart
 showModalBottomSheet<String>(
        context: context,
        // 圆角
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        // 背景色
        backgroundColor: Colors.white,
        builder: (context) {
          return DateSelectDialog(_date ?? '');
        }).then((value) async {
      if (isNotEmpty(value) ) {
        setState(() {
          _date = value;
        });
      }
    });
```

## License

MIT License