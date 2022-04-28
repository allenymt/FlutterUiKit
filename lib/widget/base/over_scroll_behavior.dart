import 'package:flutter/material.dart';

/// do what
/// @author yulun
/// @since 2020-09-29 16:48
/// 对于ClampingScrollPhysics android的滚动来说 去掉到顶或到底后的默认阴影
class OverScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
        return child;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          child: child,
          //不显示头部水波纹
          showLeading: false,
          //不显示尾部水波纹
          showTrailing: false,
          axisDirection: axisDirection,
          color: Theme.of(context).accentColor,
        );
      default:
        break;
    }
    return child;
  }
}
