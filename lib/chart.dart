import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_store/flutter_cache_store.dart';
import 'dart:io';
import 'dart:convert';
import "dart:collection";

import 'package:intl/intl.dart';



class LineChartSample2 extends StatefulWidget {
  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  
  final String DATA_URL = 'https://w3qa5ydb4l.execute-api.eu-west-1.amazonaws.com/prod/finnishCoronaData';

  List<FlSpot> _spots;
  @override
  void initState() { 
    super.initState();
    fetchData().then((spots) {
      setState(() {
        _spots = spots;
      });
    });
  }

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    if (_spots == null) {
      return CircularProgressIndicator();
    }
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(18),
                ),
                color: const Color(0xff232d37)),
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<FlSpot>> fetchData() async {
    final store = await CacheStore.getInstance();
    File file = await store.getFile(DATA_URL);
    Map<String, dynamic> jsonData = json.decode(file.readAsStringSync());
    List<dynamic> confirmed = jsonData["confirmed"];
    SplayTreeMap<String, int> perDay = SplayTreeMap<String, int>();
    for (var i = 0; i < confirmed.length; i++) {
      String d = confirmed[i]["date"].substring(0, 10);
      if (perDay.containsKey(d)) {
        perDay[d]++;
      } else {
        perDay[d] = 1;
      }
    }
    List<FlSpot> spots = new List();
    int i = 0;
    for (String key in perDay.keys) {
      i++;
      spots.add(_parseSpot(i, perDay[key]));
    }
    // perDay.forEach((k,v) => spots.add(_parseSpot(k, v)));
    return spots;
  }

  FlSpot _parseSpot(int index, int value) {
    return new FlSpot(index.toDouble(), value.toDouble());
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle:
              TextStyle(color: const Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 16),
          getTitles: (value) {
             return '';
          },
          interval: 10.0,
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(
            color: const Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            /*
            int valueInt = value.toInt();
            if (valueInt < 100) return '100';
            if (valueInt >= 100 && valueInt < 200) return '200';
            if (valueInt >= 200 && valueInt < 300) return '300';
            */
            return value.toString();
          },
          interval: 30,
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData:
          FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 1,
      maxX: _spots.length.toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: _spots,
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}