import 'package:digital_lock_v1_flutter/SQLite/sqlite_helpper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert' show utf8;
import 'package:wakelock/wakelock.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RMUTR Digital Lock V1',
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
  Completer<GoogleMapController> _controller = Completer();
  LatLng _center = const LatLng(13.7181689, 100.4968919);
  double latlngLat;
  double latlngLng;
  Marker marker;
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
    readMap();
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
          onPressed: () {
            print(connectionText);
            this.sendTxBuff("C2-" + tx_buff_str);
          }),
    );
  }

  Widget dlBtnStop() {
    return Container(
      width: 100.0,
      child: RaisedButton(
          color: Colors.red,
          child: Text("Stop"),
          onPressed: () {
            this.sendTxBuff("C0-" + tx_buff_str);
            if (targetDevice != null) {
              _initGps();
            }
          }),
    );
  }

  Widget dlBtnStart() {
    return Container(
      width: 100.0,
      child: RaisedButton(
        color: Colors.green,
        child: Text("Start"),
        onPressed: () => this.sendTxBuff("C1-" + tx_buff_str),
      ),
    );
  }

  Widget dlBtnChangePincode() {
    return Container(
      width: 100.0,
      child: RaisedButton(
        color: Colors.yellow[300],
        child: Text("Change Pincode"),
        onPressed: () => this.changePincodeDialog(),
      ),
    );
  }

  Widget dlBtnAlarm() {
    return Container(
      width: 100.0,
      child: OutlineButton(
        child: Text("Alarm"),
        onPressed: () => this.setAlarmDialog(),
      ),
    );
  }

  Widget dlKeyPad() {
    return ListView(
      children: <Widget>[
        Container(
          height: 20,
        ),
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
        Container(
          child: showLogo(),
        )
      ],
    );
  }

  List<Widget> mapButtom(BuildContext context) {
    return <Widget>[
      IconButton(
          icon: Icon(Icons.map),
          color: Colors.blue[100],
          iconSize: 35,
          onPressed: () {
            print('buttom refresh');
            setState(() {
              MaterialPageRoute materialPageRoute = MaterialPageRoute(
                builder: (BuildContext context) => googleMap(),
              );
              Navigator.of(context).push(materialPageRoute);
              _onAddMarkerButtonPressed();
            });
          })
    ];
  }

  Future readMap() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    latlngLat = double.parse(object[0].latSqlite);
    latlngLng = double.parse(object[0].lonSqlite);
    _center = LatLng(latlngLat, latlngLng);
    print('lat = ${object[0].latSqlite} lon = ${object[0].lonSqlite}');
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _center,
          zoom: 19,
          tilt: 30, //bearing: 192.8334901395799,
        ),
      ),
    );
  }

  Widget googleMap() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("last parking location"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15,
          tilt: 30,
        ),
        markers: Set.of((marker != null) ? [marker] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Widget showLogo() {
    return Image.asset('images/logo.png');
  }

  _initGps() async {
    LocationData locationData = await findLocationData();
    latlngLat = locationData.latitude;
    latlngLng = locationData.longitude;
    setState(() {
      _center = LatLng(latlngLat, latlngLng);
      _goToTheLake();
      _onAddMarkerButtonPressed();
      addMap();
    });
  }

  addMap() async {
    await SQLiteHelper().deleteDataWhereId(1).then((value) {});

    Map<String, dynamic> map = Map();

    map['latSqlite'] = latlngLat.toString();
    map['lonSqlite'] = latlngLng.toString();
    map['txSqlute'] = tx_buff_str;

    print('map ==> ${map.toString()}');

    CartModel cartModel = CartModel.fromJson(map);

    await SQLiteHelper().insertDataToSQLite(cartModel).then((value) {
      print('Insert Success');
    });
  }

  _onAddMarkerButtonPressed() {
    setState(() {
      marker = Marker(
        markerId: MarkerId("home"),
        position: _center,
        infoWindow: InfoWindow(
          title: 'This is a Title',
          snippet: 'This is a snippet',
        ),
        draggable: false,
        flat: true,
        icon: BitmapDescriptor.defaultMarker,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("RMUTR Digital Lock V1"),
        actions: mapButtom(context),
      ),
      body: dlKeyPad(),
    );
  }
}

class CartModel {
  int id;
  String latSqlite;
  String lonSqlite;

  CartModel({this.id, this.latSqlite, this.lonSqlite});

  CartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    latSqlite = json['latSqlite'];
    lonSqlite = json['lonSqlite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['latSqlite'] = this.latSqlite;
    data['lonSqlite'] = this.lonSqlite;
    return data;
  }
}
