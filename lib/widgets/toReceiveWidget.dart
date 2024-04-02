import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/screens/datailScreen.dart';
import 'package:web3dart/credentials.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';
import '../providers/supplychainProvider.dart';

class ToReceiveWidget extends StatelessWidget {
  final dynamic data;

  ToReceiveWidget(this.data) {
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

  Future<void> showInformationQrImage(BuildContext context) async {
    print(id);
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
                final pd = await ShowDialogEnterPrivateKey(context);
                try {
                  if (pd == true &&
                      supl.publicKey.toString() == auth.getPublicKey) {
                    await showInformationQrImage(context);
                  }
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
              },
              child: Container(
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
                            SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<List<String>?>(
                              future: supl
                                  .getInformationFromPublicAddressParent(id),
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
