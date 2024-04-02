import 'package:flutter/material.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/screens/datailScreen.dart';
import 'package:web3dart/credentials.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';
import '../providers/supplychainProvider.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductWidgetNew extends StatelessWidget {
  final dynamic data;
  final int index;
  late bool? isForSale;
  late bool? isForStock;
  late bool? isForMarketPlace;

  ProductWidgetNew(this.data, this.isForMarketPlace, this.index, this.isForSale,
      this.isForStock) {
    id = data[9];
    owner = data[0];
    type = data[2];
    quantity = data[3];
    price = data[6];
    minQuantity = data[7];
    quantityRemaining = data[4];
    date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(data[8].toString()) * 1000);
  }
  late String? imageUrl;
  late BigInt? id;
  late EthereumAddress? owner;
  late BigInt type;
  late BigInt quantity;
  late BigInt price;
  late DateTime? date;
  late BigInt minQuantity;
  late BigInt quantityRemaining;
  var auth, supl, coin;

  final GlobalKey<FormState> _formkeyModify = GlobalKey<FormState>();

  Future<void> showModifyDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          final quantityController = TextEditingController();
          quantityController.text = quantity.toString();
          final priceController = TextEditingController();
          priceController.text = price.toString();
          final minQuantityController = TextEditingController();
          minQuantityController.text = minQuantity.toString();

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              content: Form(
                  key: _formkeyModify,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        //initialValue: quantity.toString(),
                        controller: quantityController,
                        validator: (value) {
                          return value != '' ? null : 'invalide field';
                        },
                        decoration: const InputDecoration(
                            hintText: 'modify the quantity  '),
                      ),
                      TextFormField(
                        // initialValue: price.toString(),
                        controller: priceController,
                        validator: (value) {
                          return value != '' ? null : 'invalide field';
                        },
                        decoration:
                            const InputDecoration(hintText: 'modify the price'),
                      ),
                      TextFormField(
                        //initialValue: minQuantity.toString(),
                        controller: minQuantityController,
                        validator: (value) {
                          return value != '' ? null : 'invalide field';
                        },
                        decoration: const InputDecoration(
                            hintText: 'modify the min Quantity'),
                      ),
                    ],
                  )),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (_formkeyModify.currentState!.validate()) {
                        await supl.getCredential(auth.getPrivateKey);
                        await coin.getCredential(auth.getPrivateKey);
                        try {
                          supl.modifyProduct(
                            id,
                            BigInt.parse(quantityController.text),
                            BigInt.parse(priceController.text),
                            BigInt.parse(minQuantityController.text),
                          );

                          Navigator.of(context).pop();
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
                      }
                    },
                    child: const Text('submit'))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    coin = Provider.of<CoinProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20))),
      width: size.width * 0.8,
      margin: const EdgeInsets.all(20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: double.infinity,
            height: size.height * 0.4,
            child: GestureDetector(
              onTap: () async {
                //print(auth.getJobType);
                //await supl.singnMessage('aziz benafghoul');
                if ((index == 0 && auth.getJobType == 'wholesaler') ||
                    (index == 1 && auth.getJobType == 'retailer') ||
                    (index == 2 && auth.getJobType == 'customer')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailScreen(data)),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: FutureBuilder<dynamic?>(
                    future: auth.laodImage(id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.network(
                          snapshot.data!.toString(),
                          fit: BoxFit.fill,
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
              ),
            )),
        Container(
            margin: EdgeInsets.all(22),
            //width: size.width * 0.8,

            decoration: BoxDecoration(
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.5),
                //     spreadRadius: 5,
                //     blurRadius: 7,
                //     offset: Offset(0, 3), // changes position of shadow
                //   ),
                // ],
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            //height: size.height * 0.1,

            // padding: EdgeInsets.all(17),

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
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 17)),
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
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 17)),
                            FutureBuilder<List<dynamic>>(
                                future: supl.getLocation(id),
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
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 17)),
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Date of adding',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 17)),
                            Text(
                              DateFormat.yMMMMEEEEd().format(date!),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                if (isForSale!)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      ElevatedButton(
                          //color: Colors.deepPurple,
                          onPressed: () async {
                            await showModifyDialog(context);
                          },
                          child: const Text(
                            'Modify',
                            style: TextStyle(fontSize: 16),
                          )),
                    ],
                  ),
              ],
            ))
      ]),
    );
  }
}
