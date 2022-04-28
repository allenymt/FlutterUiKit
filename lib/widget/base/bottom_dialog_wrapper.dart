import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// do what
/// @author yulun
/// @since 2020-06-10 17:05
/// 底部弹框 容器
/// 支持拖动关闭 相比于系统的bottomSheet ， 优化了容器中即使是列表也能拖动关闭
class BottomDialogWrapper<T extends Object> extends StatefulWidget {
  ///背景色
  final Color barrierColor;

  ///底部弹框child
  final Widget? child;

  /// 另一种方式 暴露context构建child ,推荐这种方式
  final WidgetBuilder? buildChild;

  /// 动画执行时长
  final int duration;

  /// Y方向动画执行的高度,如果业务方知道高度可以设置下，默认执行200个像素的高度变化
  /// 一般不用设置，除非高度远远大于200，才需要设置
  /// 这里的200是逻辑单位
  final double transformHeight;

  /// 点击空白处 消失对话框，可以在这里自定义返回值
  final T Function()? exitCallBack;

  /// 是否启用滑动关闭
  final bool enableDrag;

  /// 如果child里有列表，需要业务方告知滚动的列表在第几层，默认是第0层，如果是nested 一般是第一层
  final int dragScrollDep;

  BottomDialogWrapper({
    this.child,
    this.barrierColor = const Color(0x55000000),
    this.duration = 300,
    this.exitCallBack,
    this.buildChild,
    this.transformHeight = 200,
    this.enableDrag = true,
    this.dragScrollDep = 0,
  }) : assert(child != null || buildChild != null);

  @override
  State createState() => _BottomDialogWrapperState<T>();

  /// 获取 _BottomDialogWrapperState
  static _BottomDialogWrapperState? of(BuildContext context) {
    if (context.widget is BottomDialogWrapper)
      return (context as StatefulElement).state as _BottomDialogWrapperState<dynamic>?;
    final _BottomDialogWrapperState? state =
        context.findAncestorStateOfType<_BottomDialogWrapperState>();
    return state;
  }
}

class _BottomDialogWrapperState<T> extends State<BottomDialogWrapper>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  AnimationController? get animationController => _animationController;

  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: Duration(milliseconds: widget.duration),
        vsync: this); //AnimationController
    _animation = ColorTween(begin: Color(0x00000000), end: widget.barrierColor)
        .animate(_animationController!);
    animationController!.addStatusListener(_handleStatusChange);

    /// 执行出现动画
    _insert();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0x00000000),
      body: Stack(
        children: <Widget>[
          /// 背景色动画
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return GestureDetector(
                child: Container(
                  color: _animation.value,
                ),
                onTap: () {
                  T? result;
                  if (widget.exitCallBack != null) {
                    result = widget.exitCallBack!() as T?;
                  }
                  remove(result);
                },
              );
            },
          ),

          /// 实际渲染的child
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildAnimationChild(context, constraints);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 动画包一层
  Widget _buildAnimationChild(
      BuildContext context, BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0,
              widget.transformHeight -
                  _animationController!.value * widget.transformHeight),
          child: child,
        );
      },
      child: BottomDragWrapper(
        builder: (context) {
          return widget.child == null
              ? widget.buildChild!(context)
              : widget.child!;
        },
        enableDrag: widget.enableDrag,
        animationController: _animationController,
        onDragStart: _handleDragStart,
        onDragEnd: _handleDragEnd,
        onClosing: () {
          T? result;
          if (widget.exitCallBack != null) {
            result = widget.exitCallBack!() as T?;
          }
          remove(result);
        },
        dragScrollDep: widget.dragScrollDep,
      ),
    );
  }

  /// 开始执行出现动画
  void _insert() {
    _animationController!.forward();
  }

  /// 动画方式关闭自己
  void remove([T? result]) {
    _animationController!
        .reverse()
        .then((_) => Navigator.of(context).pop(result));
  }

  /// 关闭自己 同remove
  void popSelf([T? result]) {
    remove(result);
  }

  /// 拖动开始处理
  void _handleDragStart(DragStartDetails details) {}

  /// 拖动结束处理
  void _handleDragEnd(DragEndDetails details, {bool? isClosing}) {}

  /// 动画状态有变化
  void _handleStatusChange(AnimationStatus status) {}
}

const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

/// 底部框拖动事件处理 参考系统的bottomSheet
class BottomDragWrapper extends StatefulWidget {
  const BottomDragWrapper({
    Key? key,
    this.animationController,
    required this.enableDrag,
    this.onDragStart,
    this.onDragEnd,
    required this.onClosing,
    required this.builder,
    this.dragScrollDep,
  })  : assert(enableDrag != null),
        assert(onClosing != null),
        assert(builder != null),
        super(key: key);

  final AnimationController? animationController;

  final VoidCallback onClosing;

  final WidgetBuilder builder;

  final bool enableDrag;

  final BottomSheetDragStartHandler? onDragStart;

  final BottomSheetDragEndHandler? onDragEnd;

  final int? dragScrollDep;

  @override
  _BottomDragWrapperState createState() => _BottomDragWrapperState();
}

class _BottomDragWrapperState extends State<BottomDragWrapper> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomWrapperSheet child');

  bool _enableDragHook = false;

  double get _childHeight {
    final RenderBox renderBox =
        _childKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway =>
      widget.animationController!.status == AnimationStatus.reverse;

  void _handleDragStart(DragStartDetails details) {
    if (widget.onDragStart != null) {
      widget.onDragStart!(details);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(widget.enableDrag);
    if (_dismissUnderway) return;
    widget.animationController!.value -=
        details.primaryDelta! / (_childHeight);
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(widget.enableDrag);
    if (_dismissUnderway) return;
    bool isClosing = false;
    if (details.velocity.pixelsPerSecond.dy > _minFlingVelocity) {
      final double flingVelocity =
          -details.velocity.pixelsPerSecond.dy / _childHeight;
      if (widget.animationController!.value > 0.0) {
        widget.animationController!.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        isClosing = true;
      }
    } else if (widget.animationController!.value < _closeProgressThreshold) {
      if (widget.animationController!.value > 0.0)
        widget.animationController!.fling(velocity: -1.0);
      isClosing = true;
    } else {
      widget.animationController!.forward();
    }

    if (widget.onDragEnd != null) {
      widget.onDragEnd!(
        details,
        isClosing: isClosing,
      );
    }

    if (isClosing) {
      widget.onClosing();
    }
  }

  bool extentChanged(DraggableScrollableNotification notification) {
    if (notification.extent == notification.minExtent) {
      widget.onClosing();
    }
    return false;
  }

  bool scrollChanged(ScrollNotification notification) {
    if (notification.depth == widget.dragScrollDep &&
        (notification.metrics.pixels) == 0 && (notification.metrics.atEdge)) {
      _enableDragHook = true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomSheet = NotificationListener<DraggableScrollableNotification>(
      key: _childKey,
      onNotification: extentChanged,
      child: NotificationListener<ScrollNotification>(
        onNotification: scrollChanged,
        child: widget.builder(context),
      ),
    );

    bottomSheet = !widget.enableDrag
        ? bottomSheet
        : GestureDetector(
            onVerticalDragStart: _handleDragStart,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: bottomSheet,
            excludeFromSemantics: true,
          );

    return RawGestureDetector(
      child: bottomSheet,
      gestures: {
        BottomWrapperMultipleGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            BottomWrapperMultipleGestureRecognizer>(
            () => BottomWrapperMultipleGestureRecognizer(),
            (BottomWrapperMultipleGestureRecognizer instance) {
          instance.onEnd = (_) {
            if (!widget.enableDrag){
              return;
            }
            if (_enableDragHook) {
              _handleDragEnd(_);
              _enableDragHook = false;
            }
          };
          instance.onUpdate = (_) {
            if (!widget.enableDrag){
              return;
            }
            if (_enableDragHook) {
              _handleDragUpdate(_);
            }
          };
          instance.onStart = (_) {
            if (!widget.enableDrag){
              return;
            }
            if (_enableDragHook) {
              _handleDragStart(_);
            }
          };
        })
      },
    );
  }
}

class BottomWrapperMultipleGestureRecognizer extends VerticalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
