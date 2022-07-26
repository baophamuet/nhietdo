import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mod_do_an/component/styles/appbar.dart';
import 'package:mod_do_an/ui/ble/widgets/CardDeviceScan.dart';
import 'package:mod_do_an/ui/components/button/inkwell_custom.dart';

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> listIdConnect = [];
    return Scaffold(
      appBar: appBarStyle("Find Device"),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!.map((d) {
                    if (listIdConnect.indexOf(d.id.toString()) == -1) {
                      listIdConnect.add(d.id.toString());
                    }
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 30, top: 30, bottom: 30),
                      child: ListTile(
                        title: Text(
                          d.name,
                          style: TextStyle(
                              fontSize: 20, fontStyle: FontStyle.italic),
                        ),
                        subtitle: Text(d.id.toString()),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: d.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data ==
                                BluetoothDeviceState.connected) {
                              return RaisedButton(
                                child: Text("Open"),
                                color: Colors.amber,
                                onPressed: () => Navigator.of(context).pop(d),
                              );
                            }
                            return Text(snapshot.data.toString());
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(
                thickness: 2,
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!.map((r) {
                    if (listIdConnect.indexOf(r.device.id.toString()) != -1) {
                      return Container();
                    }
                    return ScanResultTile(
                        result: r,
                        onTap: () async {
                          await r.device.connect();
                          return Navigator.of(context).pop(r.device);
                        });
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
