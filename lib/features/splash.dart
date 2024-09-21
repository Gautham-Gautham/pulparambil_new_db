import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulparambil/New/NavigationBar/navigation_bar.dart';
import 'package:pulparambil/main.dart';
import '../menubar/menubar.dart';
import 'home_pages.dart';

Position? currentLoc;

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // getLocation1() async {
  //   try {
  //     currentLoc = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     print("======================location$currentLoc");
  //   } catch (err) {
  //     print("========================err${err.toString()}");
  //   }
  // }

  // Future<void> requestLocationPermission() async {
  //   PermissionStatus status;
  //
  //   do {
  //     status = await Permission.location.request();
  //
  //     if (status.isGranted) {
  //       // await getLocation1();
  //     }
  //     if (status.isPermanentlyDenied) {
  //       openAppSettings();
  //     }
  //   } while (status.isDenied);
  //   await Future.delayed(Duration(seconds: 2));
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          // MaterialPageRoute(builder: (context) => RsaHome()),
          MaterialPageRoute(builder: (context) => NavigationBarScreen()),
        );
      });
    });
    // getLocation1();
    // requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA3324A),
      body: Center(
        child: Container(
          height: height * 0.3,
          width: width * 0.3,
          child: Image.asset(
            'assets/images/pulparambil.png',
          ),
        ),
      ),
    );
  }
}
