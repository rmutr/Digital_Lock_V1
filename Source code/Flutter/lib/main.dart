import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert' show utf8;
import 'package:wakelock/wakelock.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DigitalLock(),
    );
  }
}

//-----------------------------------------------------------------------------
class DigitalLock extends StatefulWidget {
  @override
  _DigitalLockState createState() => _DigitalLockState();
}

class _DigitalLockState extends State<DigitalLock> {
//-----------------------------------------------------------------------------
  String tx_buff_str = "";
  TextEditingController txtCtrl_Pincode = TextEditingController();
  TextEditingController txtCtrl_AlarmTime = TextEditingController();

//-----------------------------------------------------------------------------
  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  final String TARGET_DEVICE_NAME = "Digital Lock V1";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  String connectionText = "";

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    startScan();
  }

  startScan() {
    setState(() {
      connectionText = "01 Start Scanning";
      print(connectionText);
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        stopScan();
        setState(() {
          connectionText = "02 Found Target Device";
          print(connectionText);
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "03 Device Connecting";
      print(connectionText);
    });

    await targetDevice.connect();
    setState(() {
      connectionText = "04 Device Connected";
      print(connectionText);
    });

    discoverServices();
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristic;
            writeData("Hi, ESP32");
            setState(() {
              connectionText = "05 All Ready with ${targetDevice.name}";
              print(connectionText);
            });
          }
        });
      }
    });
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "06 Device Disconnected";
      print(connectionText);
    });
  }

  writeData(String data) {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    targetCharacteristic.write(bytes);
  }

//-----------------------------------------------------------------------------
  void keepinTxBuff(String pstr) {
    if (tx_buff_str.length < 10) {
      tx_buff_str += pstr;
    }
  }

  void sendTxBuff(String pstr) {
    print(pstr);
    writeData(pstr);
  }

  Future<void> changePincodeDialog() async {
    this.txtCtrl_Pincode.text = "";

    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: Text("New Pincode"),
        content: TextField(controller: txtCtrl_Pincode),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                this.sendTxBuff(
                    "C3-" + tx_buff_str + "-" + txtCtrl_Pincode.text);
                Navigator.of(context).pop();
              },
              child: Text("Ok")),
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel")),
        ],
      ),
    );
  }

  Future<void> setAlarmDialog() async {
    this.txtCtrl_AlarmTime.text = "";

    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: Text("Time to alarm (sec.)"),
        content: TextField(controller: txtCtrl_AlarmTime),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                String btime_str = txtCtrl_AlarmTime.text;
                int btime_int = int.tryParse(btime_str) ?? 0;
                btime_str = btime_int.toString().padLeft(4, '0');
                this.sendTxBuff("C4-" + tx_buff_str + "-" + btime_str);
                Navigator.of(context).pop();
              },
              child: Text("Ok")),
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel")),
        ],
      ),
    );
  }

  Widget dlBtn_0() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("0"),
        onPressed: () => this.keepinTxBuff("0"),
      ),
    );
  }

  Widget dlBtn_1() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("1"),
        onPressed: () => this.keepinTxBuff("1"),
      ),
    );
  }

  Widget dlBtn_2() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("2"),
        onPressed: () => this.keepinTxBuff("2"),
      ),
    );
  }

  Widget dlBtn_3() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("3"),
        onPressed: () => this.keepinTxBuff("3"),
      ),
    );
  }

  Widget dlBtn_4() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("4"),
        onPressed: () => this.keepinTxBuff("4"),
      ),
    );
  }

  Widget dlBtn_5() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("5"),
        onPressed: () => this.keepinTxBuff("5"),
      ),
    );
  }

  Widget dlBtn_6() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("6"),
        onPressed: () => this.keepinTxBuff("6"),
      ),
    );
  }

  Widget dlBtn_7() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("7"),
        onPressed: () => this.keepinTxBuff("7"),
      ),
    );
  }

  Widget dlBtn_8() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("8"),
        onPressed: () => this.keepinTxBuff("8"),
      ),
    );
  }

  Widget dlBtn_9() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("9"),
        onPressed: () => this.keepinTxBuff("9"),
      ),
    );
  }

  Widget dlBtnCancel() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("Cancel"),
        onPressed: () => tx_buff_str = "",
      ),
    );
  }

  Widget dlBtnOk() {
    return Container(
      width: 80.0,
      child: RaisedButton(
        child: Text("Ok"),
        onPressed: () => this.sendTxBuff("C2-" + tx_buff_str),
      ),
    );
  }

  Widget dlBtnStop() {
    return Container(
      width: 100.0,
      child: RaisedButton(
        child: Text("Stop"),
        onPressed: () => this.sendTxBuff("C0-" + tx_buff_str),
      ),
    );
  }

  Widget dlBtnStart() {
    return Container(
      width: 100.0,
      child: RaisedButton(
        child: Text("Start"),
        onPressed: () => this.sendTxBuff("C1-" + tx_buff_str),
      ),
    );
  }

  Widget dlBtnChangePincode() {
    return Container(
      width: 100.0,
      child: RaisedButton(
        child: Text("Change Pincode"),
        onPressed: () => this.changePincodeDialog(),
      ),
    );
  }

  Widget dlBtnAlarm() {
    return Container(
      width: 100.0,
      child: RaisedButton(
        child: Text("Alarm"),
        onPressed: () => this.setAlarmDialog(),
      ),
    );
  }

  Widget dlKeyPad() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            dlBtn_1(),
            dlBtn_2(),
            dlBtn_3(),
            dlBtnStop(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            dlBtn_4(),
            dlBtn_5(),
            dlBtn_6(),
            dlBtnStart(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            dlBtn_7(),
            dlBtn_8(),
            dlBtn_9(),
            dlBtnChangePincode(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            dlBtnCancel(),
            dlBtn_0(),
            dlBtnOk(),
            dlBtnAlarm(),
          ],
        ),
      ],
    );
  }

//-----------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RMUTR Digital Lock V1"),
      ),
      body: dlKeyPad(),
    );
  }
}
