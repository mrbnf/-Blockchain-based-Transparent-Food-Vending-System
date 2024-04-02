import 'dart:io';
import 'package:hex/hex.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/providers/supplychainProvider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hex/hex.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:hex/hex.dart';

class QrScanPage extends StatefulWidget {
  BigInt? id;
  QrScanPage({this.id});
  static const routeName = '/scan_qr';

  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool inProgress = false;
  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
            cutOutSize: MediaQuery.of(context).size.width * 0.8,
            borderWidth: 10,
            borderLength: 25,
            borderRadius: 10,
            borderColor: Colors.white),
      );
  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((barcode) async {
      try {
        setState(() {
          inProgress = true;
        });
        if (auth.getJobType == 'wholesaler') {
          await supl.wholeSalerConfirmSending(
              widget.id, hex.decode(barcode.code), coin.contractAddress);
        }
        if (auth.getJobType == 'retailer') {
          await supl.retailerConfirmSending(
              widget.id, hex.decode(barcode.code), coin.contractAddress);
        }
        if (auth.getJobType == 'farmer') {
          await supl.farmerConfirmSending(
              widget.id, hex.decode(barcode.code), coin.contractAddress);
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 3),
          content: Text('Succeful transaction'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        ));
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          inProgress = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        ));
      }

      // print('finished');
    });
  }

  var auth, supl, coin;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    coin = Provider.of<CoinProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          inProgress == false
              ? buildQrView(context)
              : CircularProgressIndicator()
        ],
      ),
    );
  }
}
