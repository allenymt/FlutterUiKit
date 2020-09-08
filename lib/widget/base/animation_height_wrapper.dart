import 'dart:async';

import 'package:flutter/material.dart';

/// do what
/// @author yulun
/// @since 2020-08-25 14:19
/// 滑动 高度自适应带动画 容器
/// 当前场景是针对pageview
// ignore: must_be_immutable
class AnimationHeightViewWidget<T extends Widget> extends StatefulWidget {
  T pageViewChild;

  final double Function(int currentIndex) computeAspectRadio;

  final Function(ScrollNotification scrollNotification) notifyScroll;

  final int itemCount;

  final int currentPageIndex;

  AnimationHeightViewWidget(
      {this.pageViewChild,
      this.computeAspectRadio,
      this.notifyScroll,
      this.itemCount,
      this.currentPageIndex})
      : assert(pageViewChild != null),
        assert(computeAspectRadio != null),
        assert(itemCount > 0);

  @override
  State<StatefulWidget> createState() {
    return _AnimationHeightViewWidgetState();
  }
}

class _AnimationHeightViewWidgetState extends State<AnimationHeightViewWidget> {
  StreamController<double> _streamController;
  Stream<double> _headerStream;

  List<double> _hisAspectRadioList;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _hisAspectRadioList = List.filled(widget.itemCount, 0);
    _streamController = StreamController.broadcast();
    _headerStream = _streamController.stream;
  }

  @override
  void dispose() {
    super.dispose();
    _streamController?.close();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = StreamBuilder(
      stream: _headerStream,
      builder: (context, snapshot) {
        return AspectRatio(
          aspectRatio:
              snapshot?.data ?? widget.computeAspectRadio(_currentIndex) ?? 1.0,
          child: widget.pageViewChild,
        );
      },
    );
    child = NotificationListener<ScrollNotification>(
      child: child,
      onNotification: (scrollNotification) {
        if (widget.notifyScroll != null) {
          widget?.notifyScroll(scrollNotification);
        }
        if (scrollNotification.depth == 0)
          _computeRadioToRadio(scrollNotification);
        return true;
      },
    );
    return Listener(
      child: child,
      onPointerDown: (event) {
        _currentIndex = widget.currentPageIndex;
//          print("_currentIndex is $_currentIndex");
      },
    );
  }

  void _computeRadioToRadio(ScrollNotification scroll) {
    int beforeIndex = _currentIndex;
    int nextIndex;

    //选中态左边界
    double _currentLeftPixels = beforeIndex * scroll.metrics.viewportDimension;

    //右滑
    if (scroll.metrics.pixels > _currentLeftPixels) {
      nextIndex = beforeIndex + 1;
    } else if (scroll.metrics.pixels < _currentLeftPixels) {
      //左滑
      nextIndex = beforeIndex - 1;
    } else {
      return;
    }
    nextIndex = nextIndex.clamp(0, widget.itemCount - 1);

//    print(
//        "compute ,beforeIndex is $beforeIndex , nextIndex is $nextIndex");

    double beforeRadio = getRadio(beforeIndex);
    double nextRadio = getRadio(nextIndex);

    double animationValue = beforeRadio +
        (nextRadio - beforeRadio) *
            ((scroll.metrics.pixels -
                        beforeIndex * scroll.metrics.viewportDimension)
                    .abs() /
                scroll.metrics.viewportDimension);
//    print(
//        "compute currentRadio is ${beforeRadio},nextRadio is ${nextRadio}  new radio is $animationValue，scroll.metrics.pixels is ${scroll.metrics.pixels} ,"
//            "beforeIndex is $beforeIndex,nextIndex is $nextIndex, animation is ${((scroll.metrics.pixels -
//            beforeIndex * scroll.metrics.viewportDimension)
//            .abs() /
//            scroll.metrics.viewportDimension)}");
    _streamController.add(animationValue);
  }

  double getRadio(int index) {
    if (_hisAspectRadioList[index] > 0) {
      return _hisAspectRadioList[index];
    }
    double radio = widget.computeAspectRadio(index);
    _hisAspectRadioList[index] = radio;
    return radio;
  }
}
