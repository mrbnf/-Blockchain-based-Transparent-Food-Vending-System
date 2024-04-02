import 'package:flutter/material.dart';

import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/screens/datailScreen.dart';
import 'package:supplychain/screens/qr_scan_page.dart';
import 'package:web3dart/credentials.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';
import '../providers/supplychainProvider.dart';

class ToSendWidget extends StatelessWidget {
  final dynamic data;

  ToSendWidget(this.data) {
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
                // await supl.getCredential(auth.getPrivateKey);
                // await coin.getCredential(auth.getPrivateKey);
                //final pd = await ShowDialogEnterPrivateKey(context);
                // if (pd == true &&
                //     supl.publicKey.toString() == auth.getPublicKey) {
                // await supl.getCredential(
                //     '2331053310f952a049246793e324f5922499f5bb1d4946d5148ba9efa5542aad');
                // await coin.getCredential(
                //     '2331053310f952a049246793e324f5922499f5bb1d4946d5148ba9efa5542aad');
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => QrScanPage(
                //           id: id,
                //         ),
                //       ));
                // }
                try {
                  await supl.getCredential(auth.getPrivateKey);
                  await coin.getCredential(auth.getPrivateKey);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrScanPage(
                          id: id,
                        ),
                      ));
                } catch (erreur) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(erreur.toString()),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        // Some code to undo the change.
                      },
                    ),
                  ));
                }

                // await supl.getCredential(
                //     auth.getPrivateKey);
                // await coin.getCredential(
                //     auth.getPrivateKey);
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => QrScanPage(
                //         id: id,
                //       ),
                //     ));
                // print('finished');

                //await showInformationQrImage(context);
              },
              child: Container(
                  //width: size.width * 0.8,
                  padding: EdgeInsets.all(9),
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
                            SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<List<String>?>(
                              future: auth.getInformationFromPublicAddress(
                                  owner.toString()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundImage: NetworkImage(
                                            'https://e7.pngegg.com/pngimages/436/585/png-clipart-computer-icons-user-account-graphics-account-icon-vector-icons-silhouette.png'),
                                      ),
                                      Column(
                                        children: [
                                          Text(snapshot.data![1],
                                              style: TextStyle(fontSize: 15)),
                                          Text(snapshot.data![0],
                                              style: TextStyle(fontSize: 15))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            snapshot.data![2].toString() +
                                                '   ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
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
