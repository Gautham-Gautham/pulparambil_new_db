import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Pagefive extends StatefulWidget {
  const Pagefive({super.key});

  @override
  State<Pagefive> createState() => _PagefiveState();
}

class _PagefiveState extends State<Pagefive>with AutomaticKeepAliveClientMixin {
  double _progress = 0;
  final uri =
  Uri.parse("https://aurifyae.github.io/pulparambil-app/bankdetails");
  late InAppWebViewController inAppWebViewController;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1F0B0A),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color:Color(0xFFD3AF37),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(uri),
              ),
              onWebViewCreated: (controller) {
                inAppWebViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
