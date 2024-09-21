import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Pagefoure extends StatefulWidget {
  const Pagefoure({super.key});

  @override
  State<Pagefoure> createState() => _PagefoureState();
}

class _PagefoureState extends State<Pagefoure>with AutomaticKeepAliveClientMixin {
  double _progress = 0;
  final uri = Uri.parse("https://aurifyae.github.io/pulparambil-app/aboutus");
  late InAppWebViewController inAppWebViewController;
  @override
  void initState() {
    super.initState();
    _requestPhoneCallPermission();
    _requestWhatsAppPermission();
  }

  Future<void> _requestPhoneCallPermission() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      await Permission.phone.request();
    }
  }

  Future<void> _requestWhatsAppPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      await Permission.sms.request();
    }
  }

  @override
  Widget build(BuildContext context)  {
    super.build(context);  // Add this line
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1F0B0A),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFFD3AF37)),
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
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var url = navigationAction.request.url.toString();

                if (url.startsWith("tel:")) {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch phone call.')),
                    );
                  }
                  return NavigationActionPolicy.CANCEL;
                } else if (url.startsWith("whatsapp:")) {
                  var whatsappUrl = url.replaceFirst("whatsapp:", "https://wa.me/");
                  if (await canLaunch(whatsappUrl)) {
                    await launch(whatsappUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch WhatsApp.')),
                    );
                  }
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
            _progress < 1
                ? LinearProgressIndicator(value: _progress)
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
