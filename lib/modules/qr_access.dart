import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QrAccess extends StatefulWidget {
  @override
  _QrAccessState createState() => _QrAccessState();
}

class _QrAccessState extends State<QrAccess> {
  final GlobalKey qrKey = GlobalKey();
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (result == null) {
        setState(() {
          result = scanData;
        });

        // QR 코드가 인식되면 스캔을 멈추고 웹뷰 페이지를 띄웁니다.
        if (result != null) {
          controller.pauseCamera(); // 스캔 멈춤
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPage(url: result!.code),
            ),
          ).then((value) {
            // 웹뷰 페이지에서 뒤로 돌아왔을 때 스캔을 다시 시작합니다.
            controller.resumeCamera(); // 스캔 다시 시작
            setState(() {
              result = null; // 결과 초기화
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class WebViewPage extends StatelessWidget {
  final String? url;

  WebViewPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR result')),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
