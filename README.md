# FlutterUiKit

个人flutter ui 工具盒.
    
    v0.0.1 级联选择框，支持日期选择，时间选择

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