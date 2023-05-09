import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mod_do_an/component/card/cart_sensor.dart';
import 'package:mod_do_an/component/styles/border.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mod_do_an/config/images.dart';
import 'package:mod_do_an/helper/bleHelper.dart';
import 'package:mod_do_an/models/sensor/accelerometer.dart';
import 'package:mod_do_an/models/user/user.dart';
import 'package:mod_do_an/repositories/sensor_repository.dart';
import 'package:mod_do_an/services/sensor_service.dart';
import 'package:mod_do_an/storage/secure_storge.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:async';

class AcceletometerScreen extends StatefulWidget {
  const AcceletometerScreen({Key? key, required this.accelerometerCharactis})
      : super(key: key);
  final BluetoothCharacteristic accelerometerCharactis;
  @override
  State<AcceletometerScreen> createState() => _AcceletometerScreenState();
}

class _AcceletometerScreenState extends State<AcceletometerScreen> {
  SensorService sensorService = new SensorService();
  SensorRepository sensorRepository = new SensorRepository();

  List<Data> listAccX = List<Data>.empty(growable: true);

  late ChartSeriesController _chartSeriesControllerX;
  late Timer _timer;
  int countPosition = 0;
  List<int> addPosition = [0, 0, 0, 0, 0, 0];
  bool isCallApi = false;
  String typePosition = "";
  static final ListColorByTemp = [
    [
      Color.fromARGB(255, 27, 103, 162),
      Color.fromARGB(255, 132, 140, 200),
      Color.fromARGB(255, 30, 142, 39),
    ],
    [
      Color.fromARGB(255, 147, 243, 123),
      Color.fromARGB(255, 194, 229, 161),
      Color.fromARGB(255, 30, 142, 39),
    ],
    [
      Color.fromARGB(255, 182, 156, 38),
      Color.fromARGB(255, 196, 154, 47),
      Color.fromARGB(255, 159, 76, 35),
    ],
    [
      Color.fromARGB(255, 176, 18, 18),
      Color.fromARGB(255, 196, 154, 47),
      Color.fromARGB(255, 159, 76, 35),
    ]
  ];
  double temp = 0;
  double maxTemp = 0;
  DateTime timeTemp = DateTime.now();
  double abnormalTime = 0;
  String audioasset = "assets/audio/soundNot.mp3";
  int i = 0;
  late Uint8List audiobytes;
  AudioPlayer player = AudioPlayer();
  List<Color> colorsBg = ListColorByTemp[1];
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      ByteData bytes =
          await rootBundle.load(audioasset); //load audio from assets
      audiobytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    });
    // TODO: implement initState
    super.initState();
    _timer = new Timer.periodic(Duration(milliseconds: 2000), (Timer timer) {
      widget.accelerometerCharactis.read();
      // setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  double parseData(int pre, int first, int se) {
    String res = "";
    if (pre == 0) {
      res = "-";
    }
    res += first.toString();
    if (se < 10) {
      res = res + "0" + se.toString();
    } else {
      res += se.toString();
    }
    return double.parse(res);
  }

  List<Color> checkTemp(double temp) {
    i = temp.toInt();
    if (temp <= 35.5) return ListColorByTemp[0];
    if (temp >= 38 && temp <= 39) return ListColorByTemp[2];
    if (temp > 39) return ListColorByTemp[3];
    return ListColorByTemp[1];
  }

  @override
  Widget build(BuildContext context) {
    List<String> labels = ['0', '20', '40', '60', '80', '100'];
    return StreamBuilder<List<int>>(
        stream: widget.accelerometerCharactis.value,
        initialData: widget.accelerometerCharactis.lastValue,
        builder: (c, snapshot) {
          DateTime nowD = DateTime.now();
          if (snapshot.data != null && snapshot.data!.length > 0) {
            Data newDataX = Data(
              nowD,
              parseData(
                      snapshot.data![0], snapshot.data![1], snapshot.data![2]) /
                  100,
            );
            if (newDataX.temperature > maxTemp) {
              maxTemp = newDataX.temperature;
              timeTemp = newDataX.time;
            }
            colorsBg = checkTemp(newDataX.temperature);
            if (temp < 35.5 || temp >= 38) abnormalTime = abnormalTime + 2;
            Future.sync(() async {
              String? upper = await SecureStorage().getUpperBound();
              String? under = await SecureStorage().getUnderBound();

              if (upper != null && newDataX.temperature > double.parse(upper)) {
                Fluttertoast.showToast(
                    msg: "Nhiệt độ đang cao hơn ngưỡng",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                await player.playBytes(audiobytes);
              }
              if (under != null && newDataX.temperature < double.parse(under)) {
                Fluttertoast.showToast(
                    msg: "Nhiệt nhỏ hơn ngưỡng",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    fontSize: 16.0);
                await player.playBytes(audiobytes);
              }
            });
            temp = newDataX.temperature;
            listAccX.add(newDataX);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colorsBg,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            temp.toString() + "°C",
                            style: TextStyle(fontSize: 60.w),
                          ),
                          SizedBox(
                            height: 50.w,
                          ),
                          Container(
                            child: SfCartesianChart(
                              backgroundColor: Colors.white,
                              plotAreaBackgroundColor: Colors.white,
                              primaryXAxis: DateTimeAxis(
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                intervalType: DateTimeIntervalType.seconds,
                                dateFormat: DateFormat.Hm(),
                                majorGridLines: MajorGridLines(
                                  color: Colors.grey[200],
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                minimum: temp - (temp - temp.toInt()) - 3,
                                maximum: temp - (temp - temp.toInt()) + 3,
                                interval: 0.1,
                                axisLine: AxisLine(
                                  color: Colors.grey[200],
                                ),
                                majorTickLines: MajorTickLines(
                                  color: Colors.grey[200],
                                ),
                                minorTickLines: MinorTickLines(
                                  color: Colors.grey[200],
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              series: <ChartSeries>[
                                LineSeries<Data, DateTime>(
                                  dataSource: listAccX,
                                  xValueMapper: (Data data, _) => data.time,
                                  yValueMapper: (Data data, _) =>
                                      data.temperature,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 50.w,
                          ),
                          Row(
                            children: [
                              Text(
                                "0",
                                style: TextStyle(fontSize: 20.w),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 16.w,
                                    showValueIndicator:
                                        ShowValueIndicator.always,
                                    // Thiết lập chiều rộng của slider
                                  ),
                                  child: Slider(
                                    value: 20,
                                    onChanged: (newValue) async {
                                      //   final value = await newValue;
                                    },
                                    activeColor: Colors.blue,
                                    inactiveColor: Colors.grey,
                                    min: 0,
                                    label:
                                        'Value: ${20}', // Hiển thị giá trị bên cạnh thanh trượt
                                    divisions: 5,
                                    max: 100,
                                    semanticFormatterCallback: (double value) {
                                      return labels[(value ~/ 20)];
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                "100 phút ",
                                style: TextStyle(fontSize: 20.w),
                              ),
                            ],
                          ),
                          Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              border: TableBorder
                                  .all(), // Allows to add a border decoration around your table
                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                      height: 60.h,
                                      color: Color.fromARGB(255, 157, 213, 241),
                                      child: Text(
                                        'Max 1h',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20.h),
                                      ),
                                    ),
                                    Container(
                                      height: 60.h,
                                      color: Color.fromARGB(255, 157, 213, 241),
                                      child: Text(
                                        'Thời gian',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20.h),
                                      ),
                                    ),
                                    Container(
                                      height: 60.h,
                                      color: Color.fromARGB(255, 157, 213, 241),
                                      child: Text(
                                        'Khoảng thời gian theo dõi',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20.h),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(children: [
                                  Text(
                                    maxTemp.toString(),
                                    style: TextStyle(fontSize: 20.h),
                                  ),
                                  Text(
                                    '${timeTemp.hour}h:${timeTemp.minute}m:${timeTemp.second}s'
                                        .toString(),
                                    style: TextStyle(fontSize: 20.h),
                                  ),
                                  Text(
                                    abnormalTime.toString(),
                                    style: TextStyle(fontSize: 20.h),
                                  ),
                                ]),
                              ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class Data {
  final DateTime time;
  final double temperature;

  Data(this.time, this.temperature);
}
