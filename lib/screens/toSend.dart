import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/widgets/toSendWidget.dart';
import 'package:web3dart/web3dart.dart';
import '../providers/supplychainProvider.dart';
import '../providers/authProvider.dart';
import '../widgets/productWidget.dart';

class ToSendScreen extends StatefulWidget {
  const ToSendScreen({Key? key}) : super(key: key);
  static const routeName = '/toSend';

  @override
  _ToSendScreenState createState() => _ToSendScreenState();
}

class _ToSendScreenState extends State<ToSendScreen> {
  var supl;

  Future<List<dynamic>> farmerTosend() async {
    int i = 0;
    List<BigInt> listIdFirstType =
        await supl.farmersToSend(EthereumAddress.fromHex(auth.getPublicKey));
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  Future<List<dynamic>> wholeSalerToSend() async {
    int i = 0;
    List<BigInt> listIdFirstType =
        await supl.wholeSalerToSend(EthereumAddress.fromHex(auth.getPublicKey));
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  Future<List<dynamic>> retailerToSend() async {
    int i = 0;

    List<BigInt> listIdFirstType =
        await supl.retailerToSend(EthereumAddress.fromHex(auth.getPublicKey));
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  // Future<List<dynamic>> retailerStockk() async {
  //   int i = 0;
  //   List<BigInt> listIdFirstType = await supl.retailerStock(supl.publicKey);
  //   List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
  //   for (var e in list1) {
  //     e.add(listIdFirstType[i]);
  //     i++;
  //   }
  //   return list1;
  // }

  // Future<List<dynamic>> wholeSalerStockk() async {
  //   int i = 0;
  //   List<BigInt> listIdFirstType = await supl.wholeSalerStock(supl.publicKey);
  //   List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
  //   for (var e in list1) {
  //     e.add(listIdFirstType[i]);
  //     i++;
  //   }
  //   return list1;
  // }
  var auth;
  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('To send')),
      body: FutureBuilder<List<dynamic>?>(
        future: auth.getJobType == 'farmer'
            ? farmerTosend()
            : auth.getJobType == 'wholesaler'
                ? wholeSalerToSend()
                : retailerToSend(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) => SizedBox(
                  width: double.infinity,
                  child: ToSendWidget(snapshot.data![index])
                  // ProductWidget(
                  //     isForMarketPlace: false,
                  //     isForStock: true,
                  //     currentIndex: 0,
                  //     id: snapshot.data![index][8],
                  //     owner: snapshot.data![index][0],
                  //     type: snapshot.data![index][2],
                  //     Quantity: snapshot.data![index][3],
                  //     price: snapshot.data![index][6],
                  //     minQuantity: snapshot.data![index][7],
                  //     QuantityRemaining: snapshot.data![index][4]),
                  ),
              itemCount: snapshot.data!.length,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
