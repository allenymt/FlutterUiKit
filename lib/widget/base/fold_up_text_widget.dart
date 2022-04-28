import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

/// do what
/// @author yulun
/// @since 2020-08-27 13:53
/// 展开收起
class FoldUpTextWidget extends StatefulWidget {
  final String? text;
  final List<InlineSpan>? inlineSpanList;
  final int maxLines;
  final TextSpan Function(bool expand, GestureRecognizer? gestureRecognizer,
      [TextStyle? textStyle]) buildSpan;
  final TextStyle? textStyle;
  final bool expanded;

  //这里有个官方Bug，测量时触发WidgetSpan的build方法，有个assert判断PlaceholderDimensions不为空，但实际上对测量和渲染无影响
  final int widgetSpanCount;

  FoldUpTextWidget(
      {Key? key,
      this.text,
      this.inlineSpanList,
      required this.maxLines,
      this.expanded = false,
      this.textStyle,
      this.buildSpan = _defaultSpanBuilder,
      this.widgetSpanCount = 0})
      : assert(maxLines != null),
        assert(buildSpan != null),
        assert(text != null || inlineSpanList != null),
        super(key: key);

  @override
  State<FoldUpTextWidget> createState() {
    return _FoldUpTextState();
  }

  static TextSpan _defaultSpanBuilder(
      bool expand, GestureRecognizer? gestureRecognizer,
      [TextStyle? textStyle]) {
    if (expand) {
      return TextSpan(children: [
        TextSpan(
          recognizer: gestureRecognizer,
          text: "  收起",
          style: TextStyle(
              color: Color(0xFF4A90E2),
              fontSize: textStyle?.fontSize ?? 13,
              fontWeight: textStyle?.fontWeight ?? FontWeight.w500),
        ),
      ]);
    } else {
      return TextSpan(children: [
        TextSpan(
          text: '...',
          style: textStyle,
        ),
        TextSpan(
          text: "  展开",
          recognizer: gestureRecognizer,
          style: TextStyle(
              color: Color(0xFF4A90E2),
              fontSize: textStyle?.fontSize ?? 13,
              fontWeight: textStyle?.fontWeight ?? FontWeight.w500),
        ),
      ]);
    }
  }
}

class _FoldUpTextState extends State<FoldUpTextWidget> {
  bool _expanded = false;
  TapGestureRecognizer? _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _expanded = widget.expanded;
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _toggleExpanded;
  }

  @override
  void dispose() {
    _tapGestureRecognizer!.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final link = TextSpan(
      children: <TextSpan>[
        widget.buildSpan(_expanded, _tapGestureRecognizer, widget.textStyle),
      ],
    );

    final contentSpan = TextSpan(
      children: widget.inlineSpanList,
      text: widget.text,
      style: widget.textStyle,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        final double minWidth = constraints.minWidth;

        //测量展开收起按钮的宽度
        TextPainter linkTextPainter = TextMeasureHelper.measure(
          span: link,
          minWidth: minWidth,
          maxWidth: maxWidth,
          maxLines: widget.maxLines,
          bFindWidgetSpanCount: true,
        );

        /// 预留1个icon的宽度
        final linkWidth = linkTextPainter.width + 6;

        //测量实际文案
        TextPainter contentTextPainter = TextMeasureHelper.measure(
          span: contentSpan,
          minWidth: minWidth,
          maxWidth: maxWidth,
          maxLines: widget.maxLines,
          bFindWidgetSpanCount: true,
        );

        final textSize = contentTextPainter.size;
        final position = contentTextPainter.getPositionForOffset(Offset(
          textSize.width - linkWidth,
          textSize.height,
        ));
        final endOffset = contentTextPainter.getOffsetBefore(position.offset);
        TextSpan textSpan;
        if (contentTextPainter.didExceedMaxLines) {
          List<InlineSpan>? spanList = _computeClipIndexInSpanList(
              widget.inlineSpanList ?? [], contentSpan, position);
          spanList?.add(link);
          textSpan = TextSpan(
            style: widget.textStyle,
            text: _expanded
                ? (widget.text ?? null)
                : (widget.text?.substring(0, endOffset) ?? null),
            children: _expanded ? (widget.inlineSpanList ?? []) : spanList,
          );
        } else {
          textSpan = contentSpan;
        }

        return RichText(
          text: textSpan,
          softWrap: true,
          overflow: TextOverflow.clip,
        );
      },
    );
    return result;
  }

  ///inlineSpanList 内容的spanlist
  ///span 实际展示的span
  ///clipOffset 裁剪的位置
  List<InlineSpan>? _computeClipIndexInSpanList(List<InlineSpan> inlineSpanList,
      InlineSpan span, TextPosition clipOffset) {
    List<InlineSpan> newInlineSpanList = []..addAll(inlineSpanList);
    InlineSpan? indexSpan = span.getSpanForPosition(clipOffset);
    int index = indexSpan == null ? 0 : inlineSpanList.indexOf(indexSpan);

    double prePosition = 0;
    for (int startIndex = 0; startIndex < index; startIndex++) {
      prePosition = prePosition +
          TextMeasureHelper.computeWidgetSpanWidth(inlineSpanList[startIndex])!;
    }

    try {
      if (indexSpan is TextSpan) {
        TextSpan txtSpan = indexSpan;
        String newText =
            txtSpan.text!.substring(0, clipOffset.offset - prePosition.floor());
        TextSpan newTxtSpan = TextSpan(
          text: newText,
          children: txtSpan.children,
          style: txtSpan.style,
          recognizer: txtSpan.recognizer,
          semanticsLabel: txtSpan.semanticsLabel,
        );
        newInlineSpanList[index] = newTxtSpan;
      }
    } catch (e) {
      print(e);
    }

    return newInlineSpanList.sublist(0, index + 1);
  }
}

/// 文案高度测量辅助类
class TextMeasureHelper {
  static TextPainter measure({
    required InlineSpan span,
    required double minWidth,
    required double maxWidth,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
    double textScaleFactor = 1.0,
    required int maxLines,
    int widgetSpanCount = 0,
    bool bFindWidgetSpanCount = false,
  }) {
    TextPainter textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );

    //这里有个官方Bug，测量时触发WidgetSpan的build方法，有个assert判断PlaceholderDimensions不为空，但实际上对测量和渲染无影响
    if (bFindWidgetSpanCount && widgetSpanCount <= 0) {
      List<PlaceholderDimensions>? value = buildWidgetSpanPlaceHolder(span);
      textPainter.setPlaceholderDimensions(value);
    }
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter;
  }

  /// 查找span中WidgetSpan的数量
  static List<PlaceholderDimensions>? buildWidgetSpanPlaceHolder(
      InlineSpan span,
      {List<PlaceholderDimensions>? values}) {
    if (values == null) {
      values = [];
    }
    if (span == null) {
      return values;
    }
    if (span is TextSpan) {
      if (span.children != null) {
        for (InlineSpan child in span.children!) {
          values = buildWidgetSpanPlaceHolder(child, values: values);
        }
      }
    } else if (span is SizedWidgetSpan) {
      values.add(PlaceholderDimensions(
          size: Size(span.width ?? 1, span.height ?? 1),
          alignment: ui.PlaceholderAlignment.top));
      return values;
    } else if (span is WidgetSpan) {
      values.add(PlaceholderDimensions(
          size: Size(1, 1), alignment: ui.PlaceholderAlignment.top));
      return values;
    }
    return values;
  }

  static double? computeWidgetSpanWidth(InlineSpan? span, {double? width}) {
    if (width == null) {
      width = 0;
    }
    if (span == null) {
      return width;
    }
    if (span is TextSpan) {
      width = width + (span.text?.runes?.length ?? 0);
      if (span.children != null) {
        for (InlineSpan child in span.children!) {
          width = width! + computeWidgetSpanWidth(child, width: width)!;
        }
      }
    }
//    else if (span is VdWidgetSpan) {
//      width = width + span.width ?? 1;
//      return width;
//    }
    else if (span is WidgetSpan) {
      width = width + 1;
    }
    return width;
  }
}

/// http链接文案构建辅助类
class LinkUrlTextHelper {
  static RegExp regExp = RegExp(
      "((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{1,3})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)*(#[a-zA-Z0-9\\&%_\\./-~-]*)?");

  static List<InlineSpan> parseHttpLink({
    required String content,
    LinkUrlConfig linkUrlConfig = const LinkUrlConfig.defaultConfig(),
  }) {
    assert(content != null && content.length > 0);
    List<InlineSpan> result = [];
    List<Match> matches = regExp.allMatches(content).toList();
    if (matches.length == 0) {
      //没有超链接
      result.add(TextSpan(text: content, style: linkUrlConfig.contentStyle));
    } else {
      //有超链接
      int index = 0;
      for (int i = 0; i < matches.length; i++) {
        Match m = matches[i];
        if (m.start > index) {
          result.add(TextSpan(
              text: content.substring(
                  index, m.start > content.length ? content.length : m.start),
              style: linkUrlConfig.contentStyle));
        }
        String url = content.substring(
            m.start, m.end > content.length ? content.length : m.end);

        if (linkUrlConfig.enableLinkIcon!) {
          result.add(
            WidgetSpan(
                child: Image.asset(linkUrlConfig.linkIconPath!),
                alignment: ui.PlaceholderAlignment.middle),
          );
        }
        result.add(
          TextSpan(
              text: linkUrlConfig.linkText ?? "",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (linkUrlConfig.onLinkTap != null) {
                    linkUrlConfig.onLinkTap!.call(url);
                  }
                },
              style: linkUrlConfig.linkStyle),
        );

        index = m.end;
      }

      if (content.length > index) {
        result.add(TextSpan(
            text: content.substring(index, content.length),
            style: linkUrlConfig.contentStyle));
      }
    }
    return result;
  }
}

/// http链接构建配置
class LinkUrlConfig {
  final String? linkText;

  final Function(String linkUrl)? onLinkTap;
  final TextStyle? linkStyle;
  final TextStyle? contentStyle;
  final bool? enableLinkIcon;
  final String? linkIconPath;

  const LinkUrlConfig.defaultConfig(
      {this.linkText = "网页链接",
      this.onLinkTap,
      this.linkStyle = const TextStyle(
        color: Color(0xFF199AED),
        fontSize: 15,
      ),
      this.contentStyle = const TextStyle(
        color: Color(0xFF333333),
        fontSize: 15,
      ),
      this.enableLinkIcon = true,
      this.linkIconPath});

  LinkUrlConfig.config(
      {this.linkText,
      this.onLinkTap,
      this.linkStyle,
      this.contentStyle,
      this.enableLinkIcon,
      this.linkIconPath});
}

/// WidgetSpan 宽高需要build后才能计算
class SizedWidgetSpan extends WidgetSpan {
  final double? width;
  final double? height;

  SizedWidgetSpan({
    this.width,
    this.height,
    required Widget child,
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
    TextBaseline? baseline,
    TextStyle? style,
  }) : super(
            child: child,
            alignment: alignment,
            baseline: baseline,
            style: style);
}
