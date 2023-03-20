import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
String googleApiKey = 'AIzaSyAmOn6ZUZ56d27p_rh_tyHco4DhXaIefjw';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is d.
        primarySwatch: Colors.blue,
      ),
      home:  MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  CameraPosition? _kGooglePlex;
  Position? currentLocation;
  var long;
  var lat;
  bool? permGrant;
  Future<void> getLatLang() async
  {
    await Geolocator.getCurrentPosition()
        .then((value) async
    {

      currentLocation = value;
      lat = currentLocation!.latitude;
      long = currentLocation!.longitude;
      _kGooglePlex = CameraPosition(
          target: LatLng(lat, long),
          zoom: 8
      );
      // markers.add(
      //   Marker(
      //
      //       markerId: MarkerId('1'),
      //       infoWindow: const InfoWindow(title: 'Current Location'),
      //       position: _kGooglePlex!.target,
      //   ),);
      markers.add(
        Marker(
          visible: false,
          markerId: MarkerId('3'),
          infoWindow: const InfoWindow(title: 'my driver'),
          position: LatLng(30.5, 30.9),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan)
        ),);
      markers.add(
         Marker(
            markerId: MarkerId('2'),
          visible: false,
          infoWindow: InfoWindow(title: 'driver'),
          icon: await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(
                size: Size(0.5, 0.5)
              ),
              'assets/images/onboard1.png'
          ),
          position: LatLng(30.5, 30.5),
          draggable: true,
          onDragEnd: (LatLng latLng)
          {
            print(latLng.longitude);
            print(latLng.latitude);
          }

        ),);

      setState(() {
        permGrant = true;
      });
    }).catchError((error)
    {
      setState(() {
        permGrant = false;
      });
    });
    setState(() {});
  }

  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  StreamSubscription<Position>? positionStream;


  changeMarker(newLat,newLng)
  {
    markers.remove(Marker(markerId: MarkerId('1')));
    markers.add(
      Marker(
        markerId: MarkerId('1'),
        infoWindow: const InfoWindow(title: 'Current Location'),
        position: LatLng(newLat, newLng),
      ),);
    setState(() {});
  }

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyBWB1JR4gnnhypAmwDFckN0anoRUTH5SAY";
  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      width:3 ,
        polylineId: id, color: Colors.blue, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }
  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(30.5, 30.9),
        PointLatLng(30.2, 30.9),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    // if (result.points.isNotEmpty) {
    //   result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(30.5, 30.9));
        polylineCoordinates.add(LatLng(30.2, 30.9));
    //   });
    // }
    _addPolyLine();
  }

  @override
  void initState() {
    positionStream = Geolocator.getPositionStream().listen((event)
    {
      print(event == null? 'unKnown':event.latitude.toString()+'');
      if(event != null)
        changeMarker(event.latitude, event.longitude);
      googleMapController!.animateCamera(CameraUpdate.newLatLng(
        LatLng(event.latitude, event.longitude)
      ));
    });
    _getPolyline();
    getLatLang();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  permGrant == null ?
          const Center(child: CircularProgressIndicator(),):
          permGrant == false?
              Error():
      GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex!,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        markers: markers,
        onTap: (latLng)
        {
          markers.remove(Marker(markerId: MarkerId('3')));
          markers.add(
            Marker(
                markerId: MarkerId('3'),
                infoWindow: const InfoWindow(title: 'my driver'),
                position: latLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan)
            ),);
          setState(() {});
        },
        polylines: Set<Polyline>.of(polylines.values),
        myLocationEnabled: true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,

      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0,bottom: 10.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white.withOpacity(0.5),
            child: Icon(Icons.location_searching),
              onPressed: ()
              {
                googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                    target: LatLng(21.412390, 39.85),
                    zoom: 13
                    )
                  )
                );
              }),
        ),
      ),
    );
  }
}

class Error extends StatelessWidget {
  const Error({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:  Center(child: Text('Error Location Permission denied'),),
    );
  }
}


void navigateTo(context, Widget widget) => Navigator.push(
  context,
  MaterialPageRoute(builder: (BuildContext context) => widget),
);

void navigateAndFinish(context, Widget widget) => Navigator.pushAndRemoveUntil(
    context, MaterialPageRoute(builder: (BuildContext context) => widget),
        (route) {
      return false;
    });


/*
PermissionStatus? _status;
  Future getPermission() async
  {
    // var status = await Permission.location.status;
    // print('object');
    // print(status.name);
    // if (status.isDenied || await Permission.location.isRestricted) {
    //   if(Permission.location.request().)
    //   Permission.location.request().then((value)
    //   {
    //     print('object1');
    //
    //   });
    // }





    // bool services;
    // LocationPermission? permission;
    //
    // Geolocator.requestPermission().then((value)
    // {
    //   print(value.name);
    //   Geolocator.openLocationSettings().then((value)
    //   {
    //    Geolocator.isLocationServiceEnabled().then((value)
    //    {
    //      print(value);
    //    });
    //   });
    // });

    // await Geolocator.checkPermission().then((appLocationPermission)
    // {
    //   if(appLocationPermission == LocationPermission.denied){
    //     print('denied');
    //     navigateAndFinish(context, Error());
    //   }
    //   else if (appLocationPermission == LocationPermission.whileInUse||
    //       appLocationPermission == LocationPermission.always){
    //     print('while in use');
    //     Geolocator.isLocationServiceEnabled().then((locServEnabled)
    //     {
    //       print(locServEnabled);
    //       if(! locServEnabled) {
    //         Geolocator.requestPermission().then((requestPermission) {
    //           if(requestPermission == LocationPermission.denied){
    //             print('denied');
    //             navigateAndFinish(context, Error());
    //           }
    //           else if (
    //           requestPermission == LocationPermission.whileInUse ||
    //               requestPermission == LocationPermission.always
    //           ) {
    //             print('while in use always');
    //           }
    //           else print(requestPermission.name);
    //         });
    //       }
    //     });
    //
    //   }
    //   else print(appLocationPermission.name);
    // });

    // await Geolocator.isLocationServiceEnabled()
    // .then((value)
    // {
    //   services = value;
    //   print('object11111111');
    //   print(services);
    //   if(services == false){
    //     print('object22222222');
    //     Geolocator.checkPermission()
    //         .then((value)
    //     {
    //       permission = value;
    //       print('object3333333333333333333');
    //       print(value.toString());
    //       print(permission == LocationPermission.denied?'true':'false');
    //       print(permission == LocationPermission.whileInUse?'true':'false');
    //       if( permission == LocationPermission.denied){
    //         print('object444444444');
    //
    //         Geolocator.requestPermission()
    //             .then((value)
    //         {
    //           permission = value;
    //           print(permission!.name);
    //           print('object55555555');
    //         }).catchError((error)
    //         {
    //           print('6666666666');
    //           print(error.toString());
    //         });
    //       }
    //     }).catchError((error)
    //     {
    //       print('object0000000');
    //     });
    //   }
    // });
    //
    // return permission;
  }
 */