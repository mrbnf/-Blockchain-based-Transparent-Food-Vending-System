import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/screens/datailScreen.dart';
import 'package:web3dart/credentials.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';
import '../providers/supplychainProvider.dart';
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

class StockWidget extends StatelessWidget {
  final dynamic data;

  StockWidget(this.data) {
    id = data[9];
    owner = data[0];
    type = data[2];
    quantity = data[3];
    price = data[6];
    minQuantity = data[7];
    quantityRemaining = data[4];
  }
  late String? imageUrl;
  late BigInt? id;
  late EthereumAddress? owner;
  late BigInt? type;
  late BigInt? quantity;
  late BigInt? price;
  late BigInt? minQuantity;
  late BigInt? quantityRemaining;
  var auth, supl, coin;

  Future<void> showInformationQrImage(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return FutureBuilder<String?>(
              future: supl.singnMessage(id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                      child: QrImage(
                    data: snapshot.data!,
                    backgroundColor: Colors.white,
                    size: 200,
                  ));
                  // return Image.network(snapshot.data!.toString());
                } else {
                  return const CircularProgressIndicator();
                }
              });
        });
  }

  final GlobalKey<FormState> _formPrivatekey = GlobalKey<FormState>();
  Future<bool?> ShowDialogEnterPrivateKey(BuildContext context) async {
    bool b = false;
    bool nh = false;
    await showDialog(
        context: context,
        builder: (context) {
          final privateKeyController = TextEditingController();
          bool b = false;
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              content: Form(
                  key: _formPrivatekey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: privateKeyController,
                        validator: (value) {
                          return value != '' ? null : 'invalide field';
                        },
                        decoration: const InputDecoration(
                            hintText: 'enter Private Key'),
                      ),
                      if (b) Text('Invalid private key')
                    ],
                  )),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (_formPrivatekey.currentState!.validate()) {
                        //await supl.getCredential(auth.getPrivateKey);
                        //await coin.getCredential(auth.getPrivateKey);
                        try {
                          await supl.getCredential(privateKeyController.text);
                        } catch (e) {
                          setState(() {
                            b = true;
                          });
                        }

                        print('heyyy  1');
                        if (supl.publicKey.toString() == auth.getPublicKey) {
                          await coin.getCredential(privateKeyController.text);
                          nh = true;

                          print('heyyy  1');
                          Navigator.of(context).pop();
                        }
                      } else {
                        setState(() {
                          b = true;
                        });

                        //Navigator.of(context).pop();
                      }
                    },
                    child: const Text('submit'))
              ],
            ),
          );
        });
    print('hey 2');
    return nh;
  }

  Future<void> showInformationDialogSell(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          final quantityController = TextEditingController();
          quantityController.text = quantity.toString();
          final minQuantityController = TextEditingController();
          final priceController = TextEditingController();
          final locationController = TextEditingController();
          File? imageDialog;
          UploadTask? uploadTask;
          final kKey = GlobalKey<FormFieldState>();
          String _commune = '';
          String _wilaya = '';
          bool inProgress = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
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
                                hintText: 'modify the  quantity'),
                          ),
                          TextFormField(
                            controller: minQuantityController,
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
                          DropdownButtonFormField(
                              hint: Text('Wilaya'),
                              //value: _wilaya,
                              items: supl.wilayas.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onSaved: (value) {},
                              onChanged: (value) {
                                setState(() {
                                  _wilaya = value.toString();
                                  kKey.currentState?.reset();
                                });
                              }),
                          DropdownButtonFormField(
                              key: kKey,
                              hint: Text('Commune'),
                              items: supl
                                  .communeForWilaya(_wilaya)
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onSaved: (value) {},
                              onChanged: (value) {
                                _commune = value.toString();
                              }),
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

                            //await supl.getCredential(auth.getPrivateKey);
                            final pd = await ShowDialogEnterPrivateKey(context);
                            try {
                              if (pd == true &&
                                  supl.publicKey.toString() ==
                                      auth.getPublicKey) {
                                if (quantityController.text !=
                                    quantity.toString()) {
                                  await supl.modifyProduct(
                                    id,
                                    BigInt.parse(quantityController.text),
                                    BigInt.parse(priceController.text),
                                    BigInt.parse(minQuantityController.text),
                                  );
                                }

                                if (auth.getJobType == 'wholesaler') {
                                  supl.wholeSalerFromStockToSale(
                                      id,
                                      BigInt.parse(priceController.text),
                                      BigInt.parse(minQuantityController.text),
                                      '$_wilaya/$_commune');
                                }
                                if (auth.getJobType == 'retailer') {
                                  supl.retailerFromStockToSale(
                                      id,
                                      BigInt.parse(priceController.text),
                                      BigInt.parse(minQuantityController.text),
                                      '$_wilaya/$_commune');
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
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  duration: Duration(seconds: 3),
                                  content: Text('Succeful transaction'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      // Some code to undo the change.
                                    },
                                  ),
                                ));
                              }
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.toString()),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    // Some code to undo the change.
                                  },
                                ),
                              ));
                            }
                          }
                        }
                      },
                      child: const Text('submit'))
              ],
            );
          });
        });
  }

  final GlobalKey<FormState> _formkeySell = GlobalKey<FormState>();

  Future<File> compressImage(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');
    final result = await FlutterImageCompress.compressAndGetFile(path, newPath,
        quality: quality);

    return result!;
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    coin = Provider.of<CoinProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: const EdgeInsets.all(20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () async {
                await supl.getCredential(auth.getPrivateKey);
                await coin.getCredential(auth.getPrivateKey);
                await showInformationQrImage(context);
              },
              child: Container(
                  //width: size.width * 0.8,
                  padding: EdgeInsets.all(9),
                  //width: size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5.0, color: Colors.black.withOpacity(0.5))
                    ],
                    //border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(
                            20.0) //                 <--- border radius here
                        ),
                  ),

                  // padding: EdgeInsets.all(17),

                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      supl.productsTypes[
                                          int.parse(type.toString())],
                                      style: const TextStyle(
                                          fontSize: 27,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      ' $quantity Kg',
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                      )
                    ],
                  )),
            )),
      ]),
    );
  }
}
