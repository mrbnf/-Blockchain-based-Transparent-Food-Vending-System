import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/providers/acountProvider.dart';
import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/providers/supplychainProvider.dart';
import 'package:supplychain/screens/firstPage.dart';
import 'package:supplychain/screens/historyScreen.dart';
import 'package:supplychain/screens/home.dart';
import 'package:supplychain/screens/qr_scan_page.dart';
import 'package:supplychain/screens/saleScreen.dart';
import 'package:supplychain/screens/settingScreen.dart';
import 'package:supplychain/screens/stockScreen.dart';
import 'package:supplychain/screens/toReceive.dart';
import 'package:supplychain/screens/toSend.dart';
import 'package:supplychain/screens/wallet.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool inLogin = true;
  int _blackPrimaryValue = 0xFF000000;
  MaterialColor primaryBlack = MaterialColor(
    0xFF000000,
    <int, Color>{
      50: Color(0xFF000000),
      100: Color(0xFF000000),
      200: Color(0xFF000000),
      300: Color(0xFF000000),
      400: Color(0xFF000000),
      500: Color(0xFF000000),
      600: Color(0xFF000000),
      700: Color(0xFF000000),
      800: Color(0xFF000000),
      900: Color(0xFF000000),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //create: (context) => AccountProvider(),
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider()),
        ChangeNotifierProvider.value(value: CoinProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SupplyChainProvider>(
          update: (context, auth, previousMessages) =>
              SupplyChainProvider(auth),
          create: (BuildContext context) => SupplyChainProvider(AuthProvider()),
        ),
        ChangeNotifierProvider.value(value: AccountProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: primaryBlack,
        ),
        home: FirstScreen(),
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(0),
          WalletScreen.routeName: (ctx) => const WalletScreen(),
          HistoryScreen.routeName: (ctx) => const HistoryScreen(),
          SaleScreen.routeName: (ctx) => const SaleScreen(),
          StockScreen.routeName: (ctx) => const StockScreen(),
          SettingScreen.routeName: (ctx) => const SettingScreen(),
          ToSendScreen.routeName: (ctx) => const ToSendScreen(),
          ToReceiveScreen.routeName: (ctx) => const ToReceiveScreen(),
          QrScanPage.routeName: (ctx) => QrScanPage()
        },
      ),
    );
  }
}
