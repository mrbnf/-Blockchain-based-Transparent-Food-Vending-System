import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/providers/supplychainProvider.dart';
import 'package:web3dart/web3dart.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);
  static const routeName = '/wallet';

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  var auth, supl, coin;

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    coin = Provider.of<CoinProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder<BigInt?>(
                future:
                    coin.balance(EthereumAddress.fromHex(auth.getPublicKey)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      width: size.width * 0.8,
                      height: size.height * 0.25,
                      decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.75),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          )),
                      child: Center(
                        child: Text(
                          snapshot.data == null
                              ? ' Balance  : ' + 0.toString()
                              : ' Balance  : ' + snapshot.data.toString(),
                          style: TextStyle(fontSize: 35),
                        ),
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              FutureBuilder<BigInt?>(
                future: coin.balanceToSendBlocked(
                    EthereumAddress.fromHex(auth.getPublicKey)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      width: size.width * 0.8,
                      height: size.height * 0.25,
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.75),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          )),
                      child: Center(
                        child: Text(
                          snapshot.data == null
                              ? ' Pending to send  : ' + 0.toString()
                              : ' Pending  to send : ' +
                                  snapshot.data.toString(),
                          style: TextStyle(fontSize: 35),
                        ),
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              FutureBuilder<BigInt?>(
                future: coin.balanceToReceiveBlocked(
                    EthereumAddress.fromHex(auth.getPublicKey)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      width: size.width * 0.8,
                      height: size.height * 0.25,
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.75),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          )),
                      child: Center(
                        child: Text(
                          snapshot.data == null
                              ? 'Pending to receive : ' + 0.toString()
                              : 'Pending to receive  : ' +
                                  snapshot.data.toString(),
                          style: TextStyle(fontSize: 35),
                        ),
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
