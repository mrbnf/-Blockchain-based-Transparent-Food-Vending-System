import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/widgets/productWidgetNew.dart';
import 'package:web3dart/web3dart.dart';
import '../providers/supplychainProvider.dart';
import '../providers/authProvider.dart';
import '../widgets/productWidget.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({Key? key}) : super(key: key);
  static const routeName = '/sale';

  @override
  _SaleScreenState createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  var supl;

  Future<List<dynamic>> farmersProductForSaling() async {
    int i = 0;
    List<BigInt> listIdFirstType = await supl
        .farmersProductsForSale(EthereumAddress.fromHex(auth.getPublicKey));
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);

    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }

    return list1;
  }

  Future<List<dynamic>> wholesalersProductForSaling() async {
    int i = 0;
    List<BigInt> listIdFirstType = await supl
        .wholeSalerproductsForSale(EthereumAddress.fromHex(auth.getPublicKey));
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);

    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }

    return list1;
  }

  Future<List<dynamic>> retailersProductForSaling() async {
    int i = 0;
    List<BigInt> listIdFirstType = await supl
        .retailersproductsForSale(EthereumAddress.fromHex(auth.getPublicKey));
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);

    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }

    return list1;
  }

  var auth;
  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('My Shop')),
      body: FutureBuilder<List<dynamic>?>(
        future: auth.getJobType == 'farmer'
            ? farmersProductForSaling()
            : auth.getJobType == 'wholesaler'
                ? wholesalersProductForSaling()
                : retailersProductForSaling(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) => SizedBox(
                width: double.infinity,

                child: ProductWidgetNew(
                    snapshot.data![index], false, 0, true, false),
                // ProductWidget(
                //     isForMarketPlace: false,
                //     isForStock: false,
                //     currentIndex: 0,
                //     id: snapshot.data![index][8],
                //     owner: snapshot.data![index][0],
                //     type: snapshot.data![index][2],
                //     Quantity: snapshot.data![index][3],
                //     price: snapshot.data![index][6],
                //     minQuantity: snapshot.data![index][7],
                //     QuantityRemaining: snapshot.data![index][4])
              ),
              //  ),
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
