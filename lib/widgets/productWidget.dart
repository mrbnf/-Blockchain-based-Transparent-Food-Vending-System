import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';
import '../providers/supplychainProvider.dart';
import '../providers/authProvider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/providers/supplychainProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProductWidget extends StatelessWidget {
  late BigInt? id;
  late EthereumAddress? owner;
  late BigInt? type;
  late BigInt? Quantity;
  late BigInt? price;
  late BigInt? minQuantity;
  late BigInt? date;
  late BigInt? QuantityRemaining;
  late bool? isForMarketPlace;
  late bool? isForStock;
  late int? currentIndex;
  var supl;
  var auth;
  ProductWidget(
      {@required this.isForMarketPlace,
      @required this.isForStock,
      @required this.currentIndex,
      @required this.id,
      @required this.owner,
      @required this.type,
      @required this.Quantity,
      @required this.price,
      @required this.minQuantity,
      @required this.QuantityRemaining,
      @required this.date});

  final GlobalKey<FormState> _formkeyBuy = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkeySell = GlobalKey<FormState>();

  Future<void> showInformationDialogBuy(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          final quantityController = TextEditingController();

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              content: Form(
                  key: _formkeyBuy,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: quantityController,
                        validator: (value) {
                          return value != '' ? null : 'invalide field';
                        },
                        decoration: const InputDecoration(
                            hintText: 'enter the quantity'),
                      ),
                    ],
                  )),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (_formkeyBuy.currentState!.validate()) {
                        await supl.getCredential(auth.getPrivateKey);
                        await coin.getCredential(auth.getPrivateKey);
                        if (currentIndex == 0 &&
                            auth.getJobType == 'Wholesaler') {
                          supl.buyProductWholesaler(
                              id,
                              BigInt.parse(quantityController.text),
                              coin.contractAddress);
                        }
                        if (currentIndex == 1 &&
                            auth.getJobType == 'Retailer') {
                          supl.buyProductRetailer(
                              id,
                              BigInt.parse(quantityController.text),
                              coin.contractAddress);
                        }
                        if (currentIndex == 2 &&
                            auth.getJobType == 'Customer') {
                          supl.buyProductCustomers(
                              id,
                              BigInt.parse(quantityController.text),
                              coin.contractAddress);
                        }

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('submit'))
              ],
            ),
          );
        });
  }

  Future<File> compressImage(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');
    final result = await FlutterImageCompress.compressAndGetFile(path, newPath,
        quality: quality);

    return result!;
  }

  Future<void> showInformationDialogSell(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          final quantityController = TextEditingController();
          final priceController = TextEditingController();
          File? imageDialog;
          UploadTask? uploadTask;

          bool inProgress = false;
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              content: inProgress == false
                  ? Form(
                      key: _formkeySell,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: quantityController,
                            validator: (value) {
                              return value != '' ? null : 'invalide field';
                            },
                            decoration: const InputDecoration(
                                hintText: 'enter the min quantity'),
                          ),
                          TextFormField(
                            controller: priceController,
                            validator: (value) {
                              return value != '' ? null : 'invalide field';
                            },
                            decoration: const InputDecoration(
                                hintText: 'enter the price'),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                try {
                                  final image = await ImagePicker()
                                      .pickImage(source: ImageSource.camera);
                                  if (image == null) {
                                    return;
                                  }

                                  var file = await ImageCropper().cropImage(
                                      sourcePath: image.path,
                                      aspectRatio: const CropAspectRatio(
                                          ratioX: 1, ratioY: 1));
                                  if (file == null) {
                                    return;
                                  }

                                  file = await compressImage(file.path, 35);

                                  // final imageTemporary = File(image.path);
                                  final imageTemporary = file;
                                  setState(() {
                                    imageDialog = imageTemporary;
                                  });
                                } catch (e) {
                                  throw Exception('fail to pick image');
                                }
                              },
                              child: Text(imageDialog == null
                                  ? 'take photo'
                                  : ' modify photo')),
                          if (imageDialog == null)
                            const Text('image not ulpaoded')
                          else
                            const Text('image uplaoded')
                        ],
                      ))
                  : const CircularProgressIndicator(),
              actions: [
                if (inProgress == false)
                  TextButton(
                      onPressed: () async {
                        if (_formkeySell.currentState!.validate()) {
                          if (imageDialog != null) {
                            setState(() {
                              inProgress = true;
                            });

                            await supl.getCredential(auth.getPrivateKey);

                            if (auth.getJobType == 'Wholesaler') {
                              supl.wholeSalerFromStockToSale(
                                  id,
                                  BigInt.parse(priceController.text),
                                  BigInt.parse(quantityController.text));
                            }
                            if (auth.getJobType == 'Retailer') {
                              supl.retailerFromStockToSale(
                                  id,
                                  BigInt.parse(priceController.text),
                                  BigInt.parse(quantityController.text));
                            }
                            final path = 'files/$id';
                            final ref =
                                FirebaseStorage.instance.ref().child(path);

                            uploadTask = ref.putFile(imageDialog!);
                            final snapshot =
                                await uploadTask!.whenComplete(() => null);

                            final urlDaownlaod =
                                await snapshot.ref.getDownloadURL();
                            print(urlDaownlaod);
                            inProgress = false;
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('uplaod photo please')));
                          }
                        }
                      },
                      child: const Text('submit'))
              ],
            ),
          );
        });
  }

  var url;
  Future<dynamic> laodImage() async {
    try {
      return await FirebaseStorage.instance
          .ref()
          .child('files/$id')
          .getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  var coin;

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    coin = Provider.of<CoinProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);

    //print(id);
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3.0,
                blurRadius: 5.0),
          ]),
      child: Column(
        children: [
          Text(
            type == BigInt.from(0)
                ? 'potato'
                : type == BigInt.from(1)
                    ? 'onion'
                    : 'carotte',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          // Image.network(
          //     'https://i.picsum.photos/id/9/250/250.jpg?hmac=tqDH5wEWHDN76mBIWEPzg1in6egMl49qZeguSaH9_VI'),
          if (isForStock == false)
            FutureBuilder<dynamic?>(
                future: laodImage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.network(snapshot.data!.toString());
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          // Image.network(url != null
          //     ? url.toString()
          //     : 'https://i.picsum.photos/id/9/250/250.jpg?hmac=tqDH5wEWHDN76mBIWEPzg1in6egMl49qZeguSaH9_VI'),
          Text(
            'price  :  ' + price.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('owner   :  ' + owner.toString()),
          Text(
            ' Quantity  remaining:   ' + QuantityRemaining.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'min Quantity :   ' + minQuantity.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'date :   ' + date.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (isForMarketPlace! &&
              ((currentIndex == 0 && auth.getJobType == 'Wholesaler') ||
                  (currentIndex == 1 && auth.getJobType == 'Retailer') ||
                  (currentIndex == 2 && auth.getJobType == 'Customer')))
            ElevatedButton(
                //color: Colors.deepPurple,
                onPressed: () async {
                  await showInformationDialogBuy(context);
                },
                child: const Text(
                  'Buy',
                  style: TextStyle(fontSize: 16),
                )),
          if (isForStock!)
            ElevatedButton(
                //color: Colors.deepPurple,
                onPressed: () async {
                  await showInformationDialogSell(context);
                },
                child: const Text(
                  'Sell',
                  style: TextStyle(fontSize: 16),
                )),
        ],
      ),
    );
  }
}
