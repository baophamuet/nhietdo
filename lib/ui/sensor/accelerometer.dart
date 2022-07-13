import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mod_do_an/helper/bleHelper.dart';
import 'package:mod_do_an/models/sensor/accelerometer.dart';
import 'package:mod_do_an/models/sensor/sale.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AccelerometerScreen extends StatefulWidget {
  const AccelerometerScreen({Key? key, required this.server}) : super(key: key);
  final BluetoothDevice server;

  @override
  State<AccelerometerScreen> createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen> {
  static final clientID = 0;
  BluetoothConnection? connection;
  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;
  String _messageBuffer = '';
  List<AccelerometerChartModel> listAccX =
      List<AccelerometerChartModel>.empty(growable: true);
  List<AccelerometerChartModel> listAccY =
      List<AccelerometerChartModel>.empty(growable: true);
  List<AccelerometerChartModel> listAccZ =
      List<AccelerometerChartModel>.empty(growable: true);
  late ChartSeriesController _chartSeriesControllerX;
  late ChartSeriesController _chartSeriesControllerY;
  late ChartSeriesController _chartSeriesControllerZ;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;

      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(listAccX.length);
    return Scaffold(
        body: Center(
            child: Container(
                height: 400,
                child: SfCartesianChart(
                    title: ChartTitle(text: 'Biểu đồ giá trị 3 trục'),
                    onZooming: ((zoomingArgs) => {print(zoomingArgs)}),
                    legend: Legend(isVisible: true),

                    // Initialize category axis
                    primaryXAxis: DateTimeAxis(
                        autoScrollingMode: AutoScrollingMode.end,
                        visibleMinimum: listAccX.length > 50
                            ? listAccX[listAccX.length - 50].time
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
                          yValueMapper: (AccelerometerChartModel accValue, _) =>
                              accValue.value,
                          xValueMapper: (AccelerometerChartModel accValue, _) =>
                              (accValue.time)),
                      LineSeries<AccelerometerChartModel, DateTime>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            _chartSeriesControllerY = controller;
                          },
                          color: Colors.amber,
                          // Bind data source
                          dataSource: listAccY,
                          yValueMapper: (AccelerometerChartModel accValue, _) =>
                              accValue.value,
                          xValueMapper: (AccelerometerChartModel accValue, _) =>
                              (accValue.time)),
                      LineSeries<AccelerometerChartModel, DateTime>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            _chartSeriesControllerZ = controller;
                          },
                          // Bind data source
                          dataSource: listAccZ,
                          yValueMapper: (AccelerometerChartModel accValue, _) =>
                              accValue.value,
                          xValueMapper: (AccelerometerChartModel accValue, _) =>
                              (accValue.time))
                    ]))));
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    String valueData = "";
    if (~index != 0 && dataString != null) {
      valueData = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);
      print(valueData);
      List values = valueData.split("%");

      setState(() {
        DateTime nowD = DateTime.now();

        _messageBuffer = dataString.substring(index);
        if (values.length == 3) {
          listAccX.add(AccelerometerChartModel(
              value: double.parse(values[0]), time: nowD));
          listAccY.add(AccelerometerChartModel(
              value: double.parse(values[1]), time: nowD));
          listAccZ.add(AccelerometerChartModel(
              value: double.parse(values[2]), time: nowD));
          _chartSeriesControllerX.updateDataSource(
              addedDataIndex: listAccX.length - 1);
        }
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
