import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
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
  List<AccelerometerChartModel> listAccX =
      List<AccelerometerChartModel>.empty(growable: true);
  List<AccelerometerChartModel> listAccY =
      List<AccelerometerChartModel>.empty(growable: true);
  List<AccelerometerChartModel> listAccZ =
      List<AccelerometerChartModel>.empty(growable: true);
  late ChartSeriesController _chartSeriesControllerX;
  late ChartSeriesController _chartSeriesControllerY;
  late ChartSeriesController _chartSeriesControllerZ;
  List<PositionCountModal> positions = [
    PositionCountModal(value: 0, name: "ngửa", code: 1),
    PositionCountModal(value: 0, name: "trái", code: 2),
    PositionCountModal(value: 0, name: "phải", code: 3),
    PositionCountModal(value: 0, name: "sấp", code: 4),
    PositionCountModal(value: 0, name: "chưa rõ", code: 5),
    PositionCountModal(value: 0, name: "không nằm", code: 6),
  ];
  late Timer _timer;
  int countPosition = 0;
  List<int> addPosition = [0, 0, 0, 0, 0, 0];
  bool isCallApi = false;
  String typePosition = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = new Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
        stream: widget.accelerometerCharactis.value,
        initialData: widget.accelerometerCharactis.lastValue,
        builder: (c, snapshot) {
          DateTime nowD = DateTime.now();
          if (snapshot.data != null && snapshot.data!.length > 0) {
            AccelerometerChartModel newDataX = AccelerometerChartModel(
                value: parseData(snapshot.data![0], snapshot.data![1],
                        snapshot.data![2]) /
                    1000,
                time: nowD);
            AccelerometerChartModel newDataY = AccelerometerChartModel(
                value: parseData(snapshot.data![3], snapshot.data![4],
                        snapshot.data![5]) /
                    1000,
                time: nowD);
            AccelerometerChartModel newDataZ = AccelerometerChartModel(
                value: parseData(snapshot.data![6], snapshot.data![7],
                        snapshot.data![8]) /
                    1000,
                time: nowD);
            listAccX.add(newDataX);
            listAccY.add(newDataY);
            listAccZ.add(newDataZ);

            int positionCode = BleHelper.getPositionSleep(
              newDataX.value,
              newDataY.value,
              newDataZ.value,
            );

            print("positionCode ");
            print(positionCode);

            if (positionCode == 1) typePosition = "Ngửa";
            if (positionCode == 2) typePosition = "Nghiêng Trái";
            if (positionCode == 3) typePosition = "Nghiêng Phải";
            if (positionCode == 4) typePosition = "Sấp";
            if (positionCode == 5) typePosition = "Chưa rõ";
            if (positionCode == 6) typePosition = "Không phải tư thế nằm";

            countPosition++;
            addPosition[positionCode - 1]++;

            if (countPosition == 20) {
              positions[positionCode - 1].value +=
                  addPosition[positionCode - 1];
              countPosition = 0;
            }

            if (listAccX.length > 1000 && !isCallApi) {
              isCallApi = true;
              Future.sync(() async {
                String valueData = "";
                for (int i = 0; i < 1000; i++) {
                  valueData += listAccX[i].value.toString();
                  valueData += "%";
                  valueData += listAccY[i].value.toString();
                  valueData += "%";
                  valueData += listAccZ[i].value.toString();
                  valueData += "@";
                  valueData += listAccX[i].time.toString();
                  if (i != 999) valueData += "/";
                }

                ProfileUser user = await SecureStorage().getUser();
                print(user.customerId);
                CreateAccelerometerModel acc = CreateAccelerometerModel(
                    value: valueData, customer: user.customerId);
                final res = await sensorRepository.createAccelerometer(acc);
                isCallApi = false;
                if (res.statusCode == HttpStatus.created) {
                  List<AccelerometerChartModel> newListAccX = listAccX;
                  List<AccelerometerChartModel> newListAccY = listAccY;
                  List<AccelerometerChartModel> newListAccZ = listAccZ;

                  newListAccX.removeRange(0, 1000);
                  newListAccY.removeRange(0, 1000);
                  newListAccZ.removeRange(0, 1000);

                  listAccX = newListAccX;
                  listAccY = newListAccY;
                  listAccZ = newListAccZ;
                }
              });
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                    decoration: borderStyle,
                    margin: new EdgeInsets.symmetric(horizontal: 10.0),
                    height: 350.h,
                    width: 350.w,
                    child: SfCartesianChart(
                        title: ChartTitle(text: 'Biểu đồ giá trị 3 trục'),
                        onZooming: ((zoomingArgs) => {print(zoomingArgs)}),
                        legend: Legend(
                            isVisible: true,
                            alignment: ChartAlignment.center,
                            position: LegendPosition.bottom),

                        // Initialize category axis
                        primaryXAxis: DateTimeAxis(
                            autoScrollingMode: AutoScrollingMode.end,
                            visibleMinimum: listAccX.length > 120
                                ? listAccX[listAccX.length - 120].time
                                : null,
                            // edgeLabelPlacement: EdgeLabelPlacement.shift,
                            majorGridLines: const MajorGridLines(width: 0),
                            name: "Thời gian",
                            isVisible: true,
                            title: AxisTitle(
                                text: "Thời gian (s)",
                                alignment: ChartAlignment.far)),
                        series: <LineSeries<AccelerometerChartModel, DateTime>>[
                          LineSeries<AccelerometerChartModel, DateTime>(
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                _chartSeriesControllerX = controller;
                              },
                              // Bind data source
                              dataSource: listAccX,
                              color: Colors.greenAccent,
                              name: "X",
                              yValueMapper:
                                  (AccelerometerChartModel accValue, _) =>
                                      accValue.value,
                              xValueMapper:
                                  (AccelerometerChartModel accValue, _) =>
                                      (accValue.time)),
                          LineSeries<AccelerometerChartModel, DateTime>(
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                _chartSeriesControllerY = controller;
                              },
                              color: Colors.amber,
                              name: "Y",
                              // Bind data source
                              dataSource: listAccY,
                              yValueMapper:
                                  (AccelerometerChartModel accValue, _) =>
                                      accValue.value,
                              xValueMapper:
                                  (AccelerometerChartModel accValue, _) =>
                                      (accValue.time)),
                          LineSeries<AccelerometerChartModel, DateTime>(
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                _chartSeriesControllerZ = controller;
                              },
                              // Bind data source
                              dataSource: listAccZ,
                              name: "Z",
                              yValueMapper:
                                  (AccelerometerChartModel accValue, _) =>
                                      accValue.value,
                              xValueMapper:
                                  (AccelerometerChartModel accValue, _) =>
                                      (accValue.time))
                        ])),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: borderStyle,
                      height: 160.h,
                      width: 350.w,
                      child: SfCartesianChart(
                          title: ChartTitle(
                              text: 'Thời gian vs tư thế',
                              textStyle: TextStyle(fontSize: 8.sp)),
                          primaryXAxis: CategoryAxis(),
                          series: <ChartSeries<PositionCountModal, String>>[
                            // Renders column chart
                            ColumnSeries<PositionCountModal, String>(
                                dataSource: positions,
                                xValueMapper: (PositionCountModal data, _) =>
                                    data.name,
                                yValueMapper: (PositionCountModal data, _) =>
                                    (data.value / 60 / 10).round())
                          ]),
                    ),
                    // Container(
                    //   decoration: borderStyle,
                    //   height: 150.h,
                    //   width: 150.h,
                    // )
                  ],
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text("Tư thế hiện tại của bạn là :"),
                SizedBox(
                  height: 10.h,
                ),
                Text(typePosition,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        });
  }
}
