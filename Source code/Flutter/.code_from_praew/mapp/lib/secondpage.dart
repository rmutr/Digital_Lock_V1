import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps/gps.dart';
import 'package:location/location.dart';

//หน้าแผนที่

class SecondPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _SecondPageState();
  }
}

class _SecondPageState extends State<SecondPage> {
  final String titleString = "Second Page";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Google Map'),
          backgroundColor: Colors.blue,
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 20,
          ),
          myLocationEnabled: true,
          markers: ewtcMarker(),
        ),
      ),
    );
  }
}

final LatLng _center = const LatLng(13.7207, 100.3693);

LocationData currentLocation;
GoogleMapController mapController;
GpsLatlng latlng;

Future<LocationData> getCurrentLocation() async {
  Location location = Location();
  try {
    return await location.getLocation();
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {}
    return null;
  }
}

void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
}

Set<Marker> ewtcMarker() {
  return <Marker>[
    Marker(
      markerId: MarkerId('idEWTC'),
      
    )
  ].toSet();
  
}
