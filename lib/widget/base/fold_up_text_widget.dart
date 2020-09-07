import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

/// do what
/// @author yulun
/// @since 2020-08-27 13:53
/// 展开收起
class FoldUpTextWidget extends StatefulWidget {
  final String text;
  final List<InlineSpan> inlineSpanList;
  final int maxLines;
  final TextSpan Function(bool expand, GestureRecognizer gestureRecognizer)
      buildSpan;
  final TextStyle textStyle;
  final bool expanded;

  //这里有个官方Bug，测量时触发WidgetSpan的build方法，有个assert判断PlaceholderDimensions不为空，但实际上对测量和渲染无影响
  final int widgetSpanCount;

  FoldUpTextWidget(
      {Key key,
      this.text,
      this.inlineSpanList,
      @required this.maxLines,
      this.expanded = false,
      this.textStyle,
      @required this.buildSpan,
      this.widgetSpanCount = 0})
      : assert(maxLines != null),
        assert(buildSpan != null),
        assert(text != null || inlineSpanList != null),
        super(key: key);

  @override
  State<FoldUpTextWidget> createState() {
    return _FoldUpTextState();
  }
}

class _FoldUpTextState extends State<FoldUpTextWidget> {
  bool _expanded = false;
  TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _expanded = widget.expanded;
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _toggleExpanded;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final link = TextSpan(
      children: <TextSpan>[
        widget.buildSpan(_expanded, _tapGestureRecognizer),
      ],
    );

    final contentSpan =
        TextSpan(children: widget.inlineSpanList, text: widget.text);

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
        final linkWidth = linkTextPainter.width;

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
          textSpan = TextSpan(
            style: widget.textStyle,
            text: _expanded
                ? (widget.text ?? null)
                : (widget.text?.substring(0, endOffset) ?? null),
            children: []
              ..addAll(_expanded
                  ? (widget.inlineSpanList ?? [])
                  : (widget.inlineSpanList?.sublist(
                          0,
                          _computeClipIndexInSpanList(
                              widget.inlineSpanList, contentSpan, position)) ??
                      []))
              ..add(link),
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

  int _computeClipIndexInSpanList(List<InlineSpan> inlineSpanList,
      InlineSpan span, TextPosition clipOffset) {
    InlineSpan indexSpan = span.getSpanForPosition(clipOffset);
    int index = inlineSpanList.indexOf(indexSpan);
    return index;
  }
}

/// 文案高度测量辅助类
class TextMeasureHelper {
  static TextPainter measure({
    @required InlineSpan span,
    @required double minWidth,
    @required double maxWidth,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
    double textScaleFactor = 1.0,
    @required int maxLines,
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
      widgetSpanCount = findWidgetSpanCount(span).value;
    }
    if ((widgetSpanCount ?? 0) > 0) {
      List<PlaceholderDimensions> value = [];
      for (int i = 0; i < widgetSpanCount; i++) {
        value.add(PlaceholderDimensions(
            size: Size(1, 1), alignment: ui.PlaceholderAlignment.top));
      }
      textPainter.setPlaceholderDimensions(value);
    }
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter;
  }

  /// 查找span中WidgetSpan的数量
  static Accumulator findWidgetSpanCount(InlineSpan span,
      {Accumulator offset}) {
    if (offset == null) {
      offset = Accumulator();
    }
    if (span == null) {
      return offset;
    }
    if (span is TextSpan) {
      if (span.children != null) {
        for (InlineSpan child in span.children) {
          offset = findWidgetSpanCount(child, offset: offset);
        }
      }
    } else if (span is WidgetSpan) {
      offset.increment(1);
      return offset;
    }
    return offset;
  }
}

/// http链接文案构建辅助类
class LinkUrlTextHelper {
  static RegExp regExp = RegExp(
      "((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)*(#[a-zA-Z0-9\\&%_\\./-~-]*)?");

  static List<InlineSpan> parseHttpLink({
    String content,
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

        result.add(TextSpan(
            text: linkUrlConfig.linkText ?? "",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (linkUrlConfig.onLinkTap != null) {
                  linkUrlConfig.onLinkTap.call(url);
                }
              },
            style: linkUrlConfig.linkStyle));
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
  final String linkText;

  final Function(String linkUrl) onLinkTap;
  final TextStyle linkStyle;
  final TextStyle contentStyle;

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
      )});

  LinkUrlConfig.config(
      {this.linkText, this.onLinkTap, this.linkStyle, this.contentStyle});
}
