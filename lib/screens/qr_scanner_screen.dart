import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedData;

  void _openLink() async {
    if (scannedData != null && Uri.tryParse(scannedData!)?.isAbsolute == true) {
      final Uri url = Uri.parse(scannedData!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open the link. Try copying it."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (scannedData != null) {
      FlutterClipboard.copy(scannedData!).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Copied to clipboard!"),
          backgroundColor: Colors.green,
        ));
      });
    }
  }

  void _resetScanner() {
    setState(() {
      scannedData = null;
    });
    cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildScannerView(),
          _buildResultSection(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("QR Code Scanner"),
      backgroundColor: Colors.deepPurple,
      actions: [
        IconButton(
          icon: Icon(Icons.flash_on),
          onPressed: () => cameraController.toggleTorch(),
        ),
      ],
    );
  }

  Widget _buildScannerView() {
    return Expanded(
      flex: 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture barcode) {
              if (barcode.barcodes.isEmpty) return;

              final String? scannedValue = barcode.barcodes.first.rawValue;
              if (scannedValue == null) return;

              setState(() {
                scannedData = scannedValue;
              });
              cameraController.stop();
            },
          ),
          Positioned(
            bottom: 50,
            child: Container(
              width: 200,
              height: 2,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (scannedData != null) _buildScannedData() else _buildScanMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedData() {
    return Column(
      children: [
        Text(
          "Scanned Data:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        SizedBox(height: 8),
        Text(
          scannedData!,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildScanMessage() {
    return Text(
      "Scan a QR Code",
      style: TextStyle(fontSize: 18, color: Colors.white70),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _resetScanner,
          icon: Icon(Icons.qr_code_scanner),
          label: Text("Scan Again"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        Spacer(),
        if (Uri.tryParse(scannedData!)?.isAbsolute == true) ...[
          ElevatedButton.icon(
            onPressed: _openLink,
            icon: Icon(Icons.open_in_browser),
            label: Text("Open Link"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          Spacer(),
        ],
        ElevatedButton.icon(
          onPressed: _copyToClipboard,
          icon: Icon(Icons.copy),
          label: Text("Copy Link"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}
