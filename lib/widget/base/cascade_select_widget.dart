import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// do what
/// @author yulun
/// @since 2020-08-06 09:58
/// 级联选择器，支持联动，支持自定义列数

/// 结果回调，每一列的数据结果
typedef PickResultCallback<T>(List<T> result);

/// 子item构造，业务方自己实现
/// columnIndex 当前在第几列
/// rowIndex 当前是构造的第几行
/// currentSelectIndex 当前选中的index,和rowIndex不一定相等的
/// 当前的数据
typedef Widget BuildItem<T>(
    int? columnIndex, int buildIndex , T data);

/// 级联选择框
// ignore: must_be_immutable
class CascadeSelectWidget<T> extends StatefulWidget {
  /// 有几列
  final int columnNum;

  /// 构造单列数据
  final Future<List<T>> Function(int columnIndex, int lastColumnIndex)
      buildPickData;

  /// 结果回调
  final PickResultCallback<T>? resultCallback;

  /// 子item构造
  final BuildItem<T> buildItem;

  /// 每列初始化的位置
  final List<int>? initIndex;

  /// 样式定制
  PickerStyle? pickerStyle;

  CascadeSelectWidget(
      {Key? key,
      required this.columnNum,
      required this.buildPickData,
      this.resultCallback,
      required this.buildItem,
      this.initIndex,
      PickerStyle? pickerStyle})
      : assert(columnNum != null),
        assert(buildPickData != null),
        assert(buildItem != null),
        super(key: key) {
    this.pickerStyle = pickerStyle ?? PickerStyle.defaultStyle();
  }

  @override
  State<CascadeSelectWidget> createState() {
    return _CascadeSelectState<T>();
  }
}

class _CascadeSelectState<T> extends State<CascadeSelectWidget<T>> {
  ///存储当前这一列选中的位置
  List<int> _currentColumnSelectIndex = [];

  /// 当前展示的所有数据
  /// column -> List<T>
  Map<int, List<T>> showData = {};

  @override
  void initState() {
    super.initState();
    if (widget.initIndex?.isNotEmpty ?? false) {
      _currentColumnSelectIndex = [];
      _currentColumnSelectIndex.addAll(widget.initIndex!);
    } else {
      _currentColumnSelectIndex = List.filled(widget.columnNum + 1, 0);
    }
    _refreshData(init: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showData.isEmpty ) return Container();

    List<Widget> children = [];
    for (int index = 0; index < widget.columnNum; index++) {
      children.add(_buildColumnWidget(index));
    }
    return Row(
      children: children,
    );
  }

  /// 其中一列选中项发送改变时，后面的列都要刷新
  Future<void> _refreshData({bool init = false}) async {
    int length = widget.columnNum;
    for (int index = 0; index < length; index++) {
      showData[index] = await widget.buildPickData(
          index, _currentColumnSelectIndex[index == 0 ? 0 : index - 1]);
    }
    setState(() {});

    /// 初始化的时候通知一次
    if (init) {
      notifyResult();
    }
  }

  /// 单列widget
  Widget _buildColumnWidget(int columnIndex) {
    int len = showData[columnIndex]?.length ?? 0;
    int initItem = (_currentColumnSelectIndex[columnIndex]) >= len
        ? (len - 1)
        : (_currentColumnSelectIndex[columnIndex]);
    if (initItem < 0) initItem = 0;
    List<T> pickData = showData[columnIndex] ?? [];
    return _PickerWidget<T>(
        key: ValueKey((pickData.isNotEmpty)
            ? "${pickData.elementAt(0).hashCode}_$columnIndex"
            : columnIndex.toString()),
        columnIndex: columnIndex,
        data: showData[columnIndex] ?? [],
        initSelectIndex: initItem,
        buildItem: widget.buildItem,
        pickerStyle: widget.pickerStyle,
        notifyResult: (columnIndex, selectIndex) async {
          _currentColumnSelectIndex[columnIndex ?? 0] = selectIndex;
          if (columnIndex != widget.columnNum - 1) {
            await _refreshData();
          }
          notifyResult();
        });
  }

  /// 结果回调
  void notifyResult() async {
    List<T> resultList = [];
    showData.forEach((key, value) {
      int selectItem = _currentColumnSelectIndex[key];
      if ((value.isNotEmpty) && value.length > selectItem)
        resultList.add(value.elementAt(selectItem));
    });
    widget.resultCallback!(resultList);
  }
}

/// 单列选择器
class _PickerWidget<T> extends StatefulWidget {
  final int? columnIndex;
  final List<T>? data;
  final int? initSelectIndex;
  final BuildItem<T> buildItem;
  final Function(int? columnIndex, int selectIndex)? notifyResult;
  final PickerStyle? pickerStyle;

  _PickerWidget(
      {Key? key,
      this.columnIndex,
      this.data,
      this.initSelectIndex,
      required this.buildItem,
      this.pickerStyle,
      this.notifyResult})
      : assert(buildItem != null),
        super(key: key);

  @override
  State<_PickerWidget<T>> createState() {
    return _PickerState<T>();
  }
}

class _PickerState<T> extends State<_PickerWidget<T>> {
  int? get columnIndex => widget.columnIndex;

  List<T>? get data => widget.data;

  int? get initSelectIndex => widget.initSelectIndex;

  BuildItem<T> get buildItem => widget.buildItem;

  Function(int? columnIndex, int selectIndex)? get notifyResult =>
      widget.notifyResult;

  Color? get bgColor => widget.pickerStyle?.bgColor;

  double? get itemExtent => widget.pickerStyle?.itemExtent;

  FixedExtentScrollController? _fixedExtentScrollController;

  @override
  void initState() {
    super.initState();
    _fixedExtentScrollController =
        FixedExtentScrollController(initialItem: initSelectIndex!);
  }

  @override
  void dispose() {
    super.dispose();
    _fixedExtentScrollController?.dispose();
    _fixedExtentScrollController = null;
  }

  @override
  Widget build(BuildContext context) {
    return _buildColumnWidget();
  }

  Widget _buildColumnWidget() {
    if (data?.isEmpty ?? true) {
      return Expanded(flex: 1, child: Container());
    }
    return Expanded(
      flex: 1,
      child: CupertinoPicker.builder(
        key: ValueKey(data?.length ?? 0),
        backgroundColor: bgColor,
        diameterRatio: widget.pickerStyle!.diameterRatio!,
        squeeze: widget.pickerStyle!.squeeze!,
        magnification: widget.pickerStyle!.magnification!,
        useMagnifier: widget.pickerStyle!.useMagnifier!,
        offAxisFraction: widget.pickerStyle!.offAxisFraction!,
        itemExtent: itemExtent!,
        scrollController: _fixedExtentScrollController,
        childCount: data!.length,
        itemBuilder: (context, index) {
          return Container(
              alignment: Alignment.center,
              child: buildItem(
                  columnIndex, index, data!.elementAt(index)));
        },
        onSelectedItemChanged: (index) {
          notifyResult!(columnIndex, index);
        },
      ),
    );
  }
}

/// 选择框style
class PickerStyle {
  /// 直径比，把滚轮理解成1个圆，越大，边缘处越清晰,越小，单例滚筒越有曲面的感觉
  double? diameterRatio;

  /// 拥挤度，越大越拥挤
  double? squeeze;

  /// 选中态的放大率
  double? magnification;

  /// 横向偏移值，左右摇摆
  double? offAxisFraction;

  /// 是否使用放大镜
  bool? useMagnifier;

  /// 背景色
  Color? bgColor;

  /// 行高
  double? itemExtent;

  PickerStyle(
      {this.diameterRatio,
      this.squeeze,
      this.magnification,
      this.offAxisFraction,
      this.useMagnifier,
      this.bgColor,
      this.itemExtent});

  factory PickerStyle.defaultStyle() {
    return PickerStyle(
      diameterRatio: 1.07,
      squeeze: 1.45,
      magnification: 1.0,
      offAxisFraction: 0.0,
      useMagnifier: false,
      bgColor: Colors.transparent,
      itemExtent: 44,
    );
  }
}
