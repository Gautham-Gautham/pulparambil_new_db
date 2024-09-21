import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pulparambil/features/page_five.dart';
import 'package:pulparambil/features/page_foure.dart';
import 'package:pulparambil/features/page_three.dart';
import 'package:pulparambil/features/page_two.dart';
import '../features/page_one.dart';
import '../features/pulaparambil.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _progress = 0;
  final Uri uri = Uri.parse("https://aurifyae.github.io/pulparambil-app/");
  late InAppWebViewController inAppWebViewController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // title: Text('PULPARAMBIL', style: TextStyle(color: Color(0xFFD3AF37),fontStyle: FontStyle.italic)),
          backgroundColor: Color(0xFF1F0B0A),
          // backgroundColor: Color(0xFFA3324A),
          leading: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Icon(CupertinoIcons.increase_indent, color:Color(0xFFD3AF37)),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF1F0B0A),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Replace with your image asset
                    Image.asset(
                      'assets/images/pulparambil.png', // Add your image path here
                      height: 80, // Adjust the height as needed
                    ),
                    SizedBox(height: 10), // Space between image and text
                    Text(
                      'PULPARAMBIL',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFD3AF37),
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.black), // Changed color to black
                title: Text('Rate alert'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Pagetwo()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.newspaper_outlined, color: Colors.black), // Changed color to black
                title: Text('News'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Pagethree()),
                  );
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.person_pin, color: Colors.black), // Changed color to black
              //   title: Text('Profile'),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => Pagefoure()),
              //     );
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.person_pin, color: Colors.black), // Changed color to black
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.home_work_outlined, color: Colors.black), // Changed color to black
                title: Text('Bank details'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Pagefive()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(uri),
              ),
              // onWebViewCreated: (controller) {
              //   inAppWebViewController = controller;
              // },
              // onProgressChanged: (controller, progress) {
              //   setState(() {
              //     _progress = progress / 100;
              //   });
              // },
            ),
            // _progress < 1
            //     ? LinearProgressIndicator(value: _progress)
            //     : SizedBox(),
          ],
        ),
      ),
    );
  }
}

