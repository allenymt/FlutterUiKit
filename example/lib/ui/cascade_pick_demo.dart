import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_ui_box/flutter_ui_kit.dart';

/// do what
/// @author yulun
/// @since 2020-08-06 18:37

// ignore: must_be_immutable
class CascadePickDemo extends StatelessWidget {
  List<int> one = [1, 2, 3, 4];

  List<int> two1 = [1, 2, 3, 4, 11, 12, 13, 14, 15, 16, 17, 18];
  List<int> two2 = [4, 5, 6, 7, 21, 22, 23, 24, 25, 25, 27, 28];
  List<int> two3 = [8, 9, 10, 11, 31, 32, 33, 34, 35, 36, 37, 38];
  List<int> two4 = [12, 13, 14, 15, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50];
  Map<int, List<int>> twoDataMap = Map();

  List<int> three1 = [16, 17, 18, 19, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three2 = [20, 21, 22, 23, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three3 = [24, 25, 26, 27, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three4 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three5 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three6 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three7 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three8 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three9 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three10 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three11 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three12 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three13 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  List<int> three14 = [28, 29, 30, 31, 61, 626, 63, 64, 65, 66, 67, 68, 69, 70];
  Map<int, List<int>> threeDataMap = Map();

  @override
  Widget build(BuildContext context) {
    _init();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("级联选择框"),
      ),
      body: CascadeSelectWidget<int>(
          columnNum: 3,
          buildPickData: (columnIndex, int lastColumnIndex) {
            List<int> result;
            if (columnIndex == 0) {
              result = one;
            } else if (columnIndex == 1) {
              result = twoDataMap[lastColumnIndex];
            } else if (columnIndex == 2) {
              result = threeDataMap[lastColumnIndex];
            } else {
              result = one;
            }
            return Future<List<int>>.value(result);
          },
          resultCallback: (data) {
            data.forEach((element) {
              print("select result is $element");
            });
          },
          buildItem: (cI, rI, data) {
            return Text(
              '$cI,$rI,$data',
              textAlign: TextAlign.center,
            );
          }),
    );
  }

  void _init() {
    if (twoDataMap.isEmpty) {
      twoDataMap[0] = two1;
      twoDataMap[1] = two2;
      twoDataMap[2] = two3;
      twoDataMap[3] = two4;
    }

    if (threeDataMap.isEmpty) {
      threeDataMap[0] = three1;
      threeDataMap[1] = three2;
      threeDataMap[2] = three3;
      threeDataMap[3] = three4;
      threeDataMap[4] = three10;
      threeDataMap[5] = three5;
      threeDataMap[6] = three6;
      threeDataMap[7] = three7;
      threeDataMap[8] = three8;
      threeDataMap[9] = three9;
      threeDataMap[10] = three11;
      threeDataMap[11] = three12;
      threeDataMap[12] = three13;
      threeDataMap[13] = three14;
    }
  }
}
