import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/widgets/stockWidget.dart';
import 'package:web3dart/web3dart.dart';
import '../providers/supplychainProvider.dart';
import '../providers/authProvider.dart';
import '../widgets/productWidget.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({Key? key}) : super(key: key);
  static const routeName = '/stock';

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  var supl;
  var auth;

  Future<List<dynamic>> retailerStockk() async {
    int i = 0;
    List<BigInt> listIdFirstType =
        await supl.retailerStock(EthereumAddress.fromHex(auth.getPublicKey));
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  Future<List<dynamic>> wholeSalerStockk() async {
    int i = 0;
    List<BigInt> listIdFirstType =
        await supl.wholeSalerStock(EthereumAddress.fromHex(auth.getPublicKey));
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('My Stock')),
      body: FutureBuilder<List<dynamic>?>(
        future: auth.getJobType == 'wholesaler'
            ? wholeSalerStockk()
            : retailerStockk(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) => SizedBox(
                  width: double.infinity,
                  child: StockWidget(snapshot.data![index])

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
