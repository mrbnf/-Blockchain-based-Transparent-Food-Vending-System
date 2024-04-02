import 'package:flutter/material.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/providers/supplychainProvider.dart';
import 'package:supplychain/widgets/iconCard.dart';
import 'package:supplychain/widgets/productWidget.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:hex/hex.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class DetailScreen extends StatefulWidget {
  static const routeName = '/detailScreen';

  final dynamic data;
  DetailScreen(this.data) {
    id = data[9];
    owner = data[0];
    type = data[2];
    quantity = data[3];
    price = data[6];
    minQuantity = data[7];
    quantityRemaining = data[4];
  }

  late BigInt? id;
  late EthereumAddress? owner;
  late BigInt? type;
  late BigInt? quantity;
  late BigInt? price;
  late BigInt? minQuantity;
  late BigInt? quantityRemaining;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final GlobalKey<FormState> _formkeyBuy = GlobalKey<FormState>();

  late String? imageUrl;

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

                        if (supl.publicKey.toString() == auth.getPublicKey) {
                          await coin.getCredential(privateKeyController.text);
                          nh = true;

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

    return nh;
  }

  Future<void> showInformationDialogBuy(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          bool inProgress = false;
          final quantityController = TextEditingController();

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              content: inProgress == false
                  ? Form(
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
                      ))
                  : const CircularProgressIndicator(),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (_formkeyBuy.currentState!.validate()) {
                        // await supl.getCredential(auth.getPrivateKey);
                        // await coin.getCredential(auth.getPrivateKey);
                        final pd = await ShowDialogEnterPrivateKey(context);

                        if (pd == true) {
                          if (supl.publicKey.toString() == auth.getPublicKey) {
                            try {
                              setState(() {
                                inProgress = true;
                              });
                              if (auth.getJobType == 'wholesaler') {
                                await supl.buyProductWholesaler(
                                    widget.id,
                                    BigInt.parse(quantityController.text),
                                    coin.contractAddress);
                              }
                              if (auth.getJobType == 'retailer') {
                                await supl.buyProductRetailer(
                                    widget.id,
                                    BigInt.parse(quantityController.text),
                                    coin.contractAddress);
                              }
                              if (auth.getJobType == 'customer') {
                                await supl.buyProductCustomers(
                                    widget.id,
                                    BigInt.parse(quantityController.text),
                                    coin.contractAddress);
                              }
                              setState(() {
                                inProgress = false;
                              });
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                duration: Duration(seconds: 10),
                                content: Text('Succeful transaction'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    // Some code to undo the change.
                                  },
                                ),
                              ));
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                duration: Duration(seconds: 10),
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
                      }
                    },
                    child: const Text('submit'))
              ],
            ),
          );
        });
  }

  var auth, coin, supl;

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    coin = Provider.of<CoinProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            IconsAndImage(size, widget.id!),
            TitleAndPrice(widget.id, widget.type, widget.price,
                widget.minQuantity, widget.owner, widget.quantityRemaining),
            Text(
              'Product traceability :',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(
                width: size.width * 0.9,
                height: 200,
                child: MoreDetails(widget.id!)),
            Row(
              children: [
                SizedBox(
                  width: size.width * 0.5,
                  height: 60,
                  child: FlatButton(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.only(topRight: Radius.circular(8))),
                    onPressed: () async {
                      await showInformationDialogBuy(context);
                    },
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontSize: 27, color: Colors.white),
                    ),
                    color: Color.fromRGBO(42, 156, 164, 1),
                  ),
                ),
                Container(
                  width: size.width * 0.5,
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(8))),
                  child: FlatButton(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(8))),
                    onPressed: () {},
                    child: const Text(
                      'More',
                      style: TextStyle(fontSize: 27),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TitleAndPrice extends StatelessWidget {
  TitleAndPrice(this.id, this.type, this.price, this.minQuantity, this.owner,
      this.quantityRemaining);
  final BigInt? id;
  final BigInt? type;
  late BigInt? price;
  late BigInt? minQuantity;
  late EthereumAddress? owner;
  late BigInt? quantityRemaining;

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var supl = Provider.of<SupplyChainProvider>(context, listen: false);
    return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  supl.productsTypes[int.parse(type.toString())],
                  style: const TextStyle(
                      fontSize: 27, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$price DZ/Kg',
                  style: const TextStyle(
                      color: Color.fromRGBO(42, 156, 164, 1),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Disponible',
                            style: TextStyle(color: Colors.grey, fontSize: 17)),
                        Text('$quantityRemaining Kg',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17))
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Location',
                            style: TextStyle(color: Colors.grey, fontSize: 17)),
                        FutureBuilder<List<dynamic>>(
                            future: supl.getLocation(id!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data![0][1].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                );
                                //Image.network(snapshot.data!.toString());
                              } else {
                                return const CircularProgressIndicator();
                              }
                            })
                      ],
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Minimum Quantity',
                            style: TextStyle(color: Colors.grey, fontSize: 17)),
                        Text(
                          '$minQuantity Kg',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                )
              ],
            ),
          ],
        ));
  }
}

class IconsAndImage extends StatelessWidget {
  const IconsAndImage(this.size, this.id);

  final BigInt id;

  final Size size;

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        height: size.height * 0.8,
        child: Row(children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 25,
                      )),
                ),
                const IconCard(Icons.favorite_border),
                const IconCard(Icons.shopping_cart),
                const IconCard(Icons.maps_home_work),
                const IconCard(Icons.message),
              ],
            ),
          )),
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(63), topLeft: Radius.circular(63)),
            child: Container(
                child: FutureBuilder<dynamic?>(
                    future: auth.laodImage(id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.network(
                          snapshot.data!.toString(),
                          fit: BoxFit.cover,
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
                height: size.height * 0.8,
                width: size.width * 0.75,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 10),
                        blurRadius: 60,
                        color: Colors.blue.withOpacity(0.25))
                  ],

                  // image: DecorationImage(
                  //     image: NetworkImage(
                  //         'https://lh3.googleusercontent.com/a-/AOh14GjvaCOh-3P7hymIw9hB3ObV9OoaYbIiHHMLB5GR=s288-p-rw-no'),
                  //     fit: BoxFit.cover)
                )),
          )
        ]),
      ),
    );
  }
}

class MoreDetails extends StatelessWidget {
  BigInt productId;
  MoreDetails(this.productId);

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    var coin = Provider.of<CoinProvider>(context, listen: false);
    var supl = Provider.of<SupplyChainProvider>(context, listen: false);
    return FutureBuilder<List<dynamic>?>(
      future: supl.searchTracability(productId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemBuilder: (context, index) => SizedBox(
              width: double.infinity,
              child: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                        'https://e7.pngegg.com/pngimages/436/585/png-clipart-computer-icons-user-account-graphics-account-icon-vector-icons-silhouette.png'),
                  ),
                  Column(
                    children: [
                      Text(snapshot.data![index][9],
                          style: TextStyle(fontSize: 15)),
                      Text(snapshot.data![index][10],
                          style: TextStyle(fontSize: 15))
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        snapshot.data![index][11].toString() + '   ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        snapshot.data![index][12].toString() + '   ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              )
                  // Column(
                  //   children: [
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  // Text(
                  //   snapshot.data![index][11].toString() + ' :  ',
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.bold, fontSize: 20),
                  // ),
                  // Text(snapshot.data![index][9],
                  //     style: TextStyle(fontSize: 18)),
                  // Text(snapshot.data![index][10],
                  //     style: TextStyle(fontSize: 18))
                  //       ],
                  //     ),
                  //     Text(
                  //       ' date : ' +
                  //           DateTime.fromMillisecondsSinceEpoch(
                  //                   int.parse(snapshot.data![index][8].toString()) *
                  //                       1000)
                  //               .toString(),
                  //       style: const TextStyle(
                  //           fontSize: 24, fontWeight: FontWeight.bold),
                  //     ),
                  //   ],
                  // ),
                  ),
            ),
            itemCount: snapshot.data!.length,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
