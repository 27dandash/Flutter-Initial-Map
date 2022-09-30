import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Initial Google Maps ',
      home: MapInitial(),
    );
  }
}

class MapInitial extends StatefulWidget {
  const MapInitial({super.key});

  @override
  State<MapInitial> createState() => MapInitialState();
}

class MapInitialState extends State<MapInitial> {


  late GoogleMapController _controller;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:const Text(
          'initial Maps',
          style:  TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 820,
            child: GoogleMap(
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
              compassEnabled: true,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              //  mapType: MapType.hybrid,
              markers: markers.values.toSet(),
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) async {
                _controller = controller;


                const LocationSettings locationSettings = LocationSettings(
                  accuracy: LocationAccuracy.best,
                  distanceFilter: 100,
                );

                Geolocator.getPositionStream(
                  locationSettings: locationSettings,
                ).listen(
                        (Position value) {
                      final marker = Marker(
                        markerId: const MarkerId('place_name'),
                        position: LatLng(
                          value.latitude,
                          value.longitude,
                        ),
                        infoWindow: const InfoWindow(
                          title: 'title',
                          snippet: 'address',
                        ),
                      );

                      setState(() {
                        markers[const MarkerId('place_name')] = marker;
                      });

                      _controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              value.latitude,
                              value.longitude,
                            ),
                            zoom: 17.0,
                          ),
                        ),
                      );
                    });

                determinePosition().then((value) {
                  _controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          value.latitude,
                          value.longitude,
                        ),
                        zoom: 16.0,
                      ),
                    ),
                  );
                });
              },
            ),
          ),



        ],
      ),


      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

  void _goToTheLake() async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  }
}

// AIzaSyACbkNR08VnxiIfnekxOfMV6TLuCcNoox8

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
