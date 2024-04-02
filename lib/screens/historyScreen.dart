import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/widgets/toReceiveWidget.dart';
import 'package:supplychain/widgets/toSendWidget.dart';
import 'package:web3dart/web3dart.dart';
import '../providers/supplychainProvider.dart';
import '../providers/authProvider.dart';
import '../widgets/productWidget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  static const routeName = '/history';

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var supl;
  Future<List<dynamic>> farmersHistoryy() async {
    int i = 0;
    List<BigInt> listIdFirstType =
        await supl.getHistorySelled(auth.getPublicKey);
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  Future<List<dynamic>> wholesalerHistoryy(bool b) async {
    int i = 0;
    List<BigInt> listIdFirstType;
    if (b == true) {
      listIdFirstType = await supl.getHistoryBuyed(auth.getPublicKey);
    } else {
      listIdFirstType = await supl.getHistorySelled(auth.getPublicKey);
    }
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  Future<List<dynamic>> retailerHistoryy(bool b) async {
    int i = 0;
    List<BigInt> listIdFirstType = b
        ? await supl.getHistoryBuyed(auth.getPublicKey)
        : await supl.getHistorySelled(auth.getPublicKey);
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  Future<List<dynamic>> customerHistoryy() async {
    int i = 0;
    List<BigInt> listIdFirstType =
        await supl.getHistoryBuyed(auth.getPublicKey);
    List<dynamic> list1 = await supl.productDatafromList(listIdFirstType);
    for (var e in list1) {
      e.add(listIdFirstType[i]);
      i++;
    }
    return list1;
  }

  bool buyedOrSelled = false;
  var auth;
  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    if (auth.getJobType == 'farmer') {
      buyedOrSelled = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My History'),
      ),
      body: Column(
        children: [
          if (auth.getJobType == 'wholesaler' || auth.getJobType == 'retailer')
            ElevatedButton(
              onPressed: () {
                if (buyedOrSelled == true) {
                  setState(() {
                    buyedOrSelled = false;
                  });
                } else {
                  setState(() {
                    buyedOrSelled = true;
                  });
                }
              },
              child: Text(buyedOrSelled ? '  show sell list' : 'show buy list'),
            ),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: auth.getJobType == 'farmer'
                  ? farmersHistoryy()
                  : auth.getJobType == 'wholesaler'
                      ? wholesalerHistoryy(buyedOrSelled)
                      : auth.getJobType == 'retailer'
                          ? retailerHistoryy(buyedOrSelled)
                          : customerHistoryy(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemBuilder: (context, index) => SizedBox(
                        width: double.infinity,
                        child: auth.getJobType == 'farmer'
                            ? ToSendWidget(snapshot.data![index])
                            : auth.getJobType == 'customer'
                                ? ToReceiveWidget(snapshot.data![index])
                                : buyedOrSelled
                                    ? ToReceiveWidget(snapshot.data![index])
                                    : ToSendWidget(snapshot.data![index])),
                    itemCount: snapshot.data!.length,
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
