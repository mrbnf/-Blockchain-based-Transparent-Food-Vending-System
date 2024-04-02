import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/providers/coinProvider.dart';
import 'package:supplychain/providers/supplychainProvider.dart';
import 'package:supplychain/screens/firstPage.dart';
import 'package:supplychain/screens/historyScreen.dart';
import 'package:supplychain/screens/saleScreen.dart';
import 'package:supplychain/screens/settingScreen.dart';
import 'package:supplychain/screens/stockScreen.dart';
import 'package:supplychain/screens/toReceive.dart';
import 'package:supplychain/screens/toSend.dart';
import 'package:supplychain/screens/wallet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supplychain/widgets/productWidgetNew.dart';
import 'package:supplychain/widgets/searchWidget.dart';
import 'package:web3dart/web3dart.dart';
import '../widgets/productWidget.dart';

class HomeScreen extends StatefulWidget {
  int currentIndex;
  HomeScreen(this.currentIndex);
  static const routeName = '/login';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var supl;
  var auth, coin;
  //int currentIndex = widget.currentIndex;

  Future<List<dynamic>> farmersProductMarquetPlace() async {
    List<dynamic> list = [];
    for (var productName in supl.productsTypes) {
      int i = 0;
      List<BigInt> listIdForType = await supl.farmersProductsListe(productName);
      List<dynamic> listTemp = await supl.productDatafromList(listIdForType);

      for (var e in listTemp) {
        e.add(listIdForType[i]);
        i++;
      }
      list.addAll(listTemp);
    }
    return list;
  }

  Future<List<dynamic>> wholeSalersProductMarquetPlace() async {
    List<dynamic> list = [];
    for (var productName in supl.productsTypes) {
      int i = 0;
      List<BigInt> listIdForType =
          await supl.wholesalersProductsListe(productName);
      List<dynamic> listTemp = await supl.productDatafromList(listIdForType);

      for (var e in listTemp) {
        e.add(listIdForType[i]);
        i++;
      }
      list.addAll(listTemp);
    }
    return list;
  }

  Future<List<dynamic>> retailersProductMarquetPlace() async {
    List<dynamic> list = [];
    for (var productName in supl.productsTypes) {
      int i = 0;
      List<BigInt> listIdForType =
          await supl.retailersProductsListe(productName);
      List<dynamic> listTemp = await supl.productDatafromList(listIdForType);

      for (var e in listTemp) {
        e.add(listIdForType[i]);
        i++;
      }
      list.addAll(listTemp);
    }
    return list;
  }

  final GlobalKey<FormState> _formkeyAddProduct = GlobalKey<FormState>();

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

  Future<void> showInformationDialogFarmerAddProduct(
      BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          File? imageDialog;
          UploadTask? uploadTask;
          String _productType = '';

          bool inProgress = false;
          final quantityController = TextEditingController();
          final minquantityController = TextEditingController();
          final priceController = TextEditingController();
          final locationController = TextEditingController();
          final kKey = GlobalKey<FormFieldState>();
          String _commune = '';
          String _wilaya = '';
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: inProgress == false
                  ? Form(
                      key: _formkeyAddProduct,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField(
                              hint: const Text('Product Type'),
                              items: supl.productsTypes
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onSaved: (value) {},
                              onChanged: (value) {
                                _productType = value.toString();
                              }),
                          DropdownButtonFormField(
                              hint: Text('Wilaya'),
                              //value: _wilaya,
                              items: supl.wilayas.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onSaved: (value) {},
                              onChanged: (value) {
                                setState(() {
                                  _wilaya = value.toString();
                                  kKey.currentState?.reset();
                                });
                              }),
                          DropdownButtonFormField(
                              key: kKey,
                              hint: Text('Commune'),
                              items: supl
                                  .communeForWilaya(_wilaya)
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onSaved: (value) {},
                              onChanged: (value) {
                                _commune = value.toString();
                              }),
                          TextFormField(
                            controller: priceController,
                            validator: (value) {
                              return value != '' ? null : 'invalide field';
                            },
                            decoration: const InputDecoration(
                                hintText: 'Enter the price'),
                          ),
                          TextFormField(
                            controller: quantityController,
                            validator: (value) {
                              return value != '' ? null : 'invalide field';
                            },
                            decoration: const InputDecoration(
                                hintText: 'Enter the quantity'),
                          ),
                          TextFormField(
                            controller: minquantityController,
                            validator: (value) {
                              return value != '' ? null : 'invalide field';
                            },
                            decoration: const InputDecoration(
                                hintText: 'Enter the min quantity'),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                try {
                                  final image = await ImagePicker()
                                      .pickImage(source: ImageSource.camera);
                                  if (image == null) {
                                    return;
                                  }

                                  var file = await ImageCropper().cropImage(
                                      sourcePath: image.path,
                                      aspectRatio: const CropAspectRatio(
                                          ratioX: 1, ratioY: 1));
                                  if (file == null) {
                                    return;
                                  }

                                  file = await compressImage(file.path, 35);

                                  // final imageTemporary = File(image.path);
                                  final imageTemporary = file;
                                  setState(() {
                                    imageDialog = imageTemporary;
                                  });
                                } catch (e) {
                                  throw Exception('fail to pick image');
                                }
                              },
                              child: Text(imageDialog == null
                                  ? 'Take Photo'
                                  : ' Modify Photo')),
                          if (imageDialog == null)
                            const Text('Image Not Ulpaoded')
                          else
                            const Text('Image Uplaoded')
                        ],
                      ))
                  : const CircularProgressIndicator(),
              actions: [
                if (inProgress == false)
                  TextButton(
                      onPressed: () async {
                        if (_formkeyAddProduct.currentState!.validate()) {
                          if (imageDialog != null) {
                            setState(() {
                              inProgress = true;
                            });

                            //await supl.getCredential(auth.getPrivateKey);
                            final pd = await ShowDialogEnterPrivateKey(context);

                            if (pd == true &&
                                supl.publicKey.toString() ==
                                    auth.getPublicKey) {
                              final idNewProduct = await supl.farmerAddProduct(
                                  _productType,
                                  BigInt.parse(quantityController.text),
                                  BigInt.parse(priceController.text),
                                  BigInt.parse(minquantityController.text),
                                  '$_wilaya/$_commune');
                              print(idNewProduct);
                              final path = 'files/$idNewProduct';
                              final ref =
                                  FirebaseStorage.instance.ref().child(path);

                              uploadTask = ref.putFile(imageDialog!);
                              final snapshot =
                                  await uploadTask!.whenComplete(() => null);

                              final urlDaownlaod =
                                  await snapshot.ref.getDownloadURL();
                              //print(urlDaownlaod);
                              inProgress = false;
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
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Capture photo please !')));
                            }

                            //print(id);

                          }
                        }
                      },
                      child: const Text('submit'))
              ],
            );
          });
        });
  }

  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 50);
      if (image == null) {
        return;
      }

      var file = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
      if (file == null) {
        return;
      }

      file = await compressImage(file.path, 35);
      final imageTemporary = File(image.path);
      this.image = imageTemporary;
    } catch (e) {
      throw Exception('fail to pick image');
    }
  }

  Future<File> compressImage(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');
    final result = await FlutterImageCompress.compressAndGetFile(path, newPath,
        quality: quality);

    return result!;
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthProvider>(context, listen: false);
    supl = Provider.of<SupplyChainProvider>(context, listen: false);
    coin = Provider.of<CoinProvider>(context, listen: false);
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text('home'),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.louGout();
              await supl.lougout();

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirstScreen(),
                  ));
              // print('finished');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: auth.getJobType == 'farmer'
          ? FloatingActionButton(
              onPressed: () async {
                // await supl.getCredential(auth.getPrivateKey);
                // await supl.getCredential(
                //     'c5c79f19d21a3841e2216c58a2c95bdb99f2575b988e91408c0ab58b6fe03c7c');
                // await supl.singnMessage(BigInt.from(1003));
                //await supl.searchTracability(BigInt.from(1006));

                //pickImage();
                showInformationDialogFarmerAddProduct(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          const SizedBox(height: 17),
          //const SearchWidget(),
          //const SizedBox(height: 17),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: widget.currentIndex == 0
                  ? farmersProductMarquetPlace()
                  : widget.currentIndex == 1
                      ? wholeSalersProductMarquetPlace()
                      : retailersProductMarquetPlace(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemBuilder: (context, index) => SizedBox(
                      width: double.infinity,
                      child: ProductWidgetNew(snapshot.data![index], true,
                          widget.currentIndex, false, false),
                      // ),
                      //Text(snapshot.data![index].toString()),
                      // ProductWidget(
                      //     isForMarketPlace: true,
                      //     isForStock: false,
                      //     currentIndex: currentIndex,
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
          ),
        ],
      ),
      drawer: const NavigationDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (value) {
          widget.currentIndex = value;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(widget.currentIndex)),
          );
        },
        items: const [
          BottomNavigationBarItem(label: 'Farmer', icon: Icon(Icons.ac_unit)),
          BottomNavigationBarItem(
              label: 'Wholesaler', icon: Icon(Icons.ac_unit)),
          BottomNavigationBarItem(label: 'Retailer', icon: Icon(Icons.ac_unit))
        ],
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(context),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }
}

Widget buildHeader(BuildContext context) => Material(
      color: Colors.black,
      child: InkWell(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
              top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 52,
                backgroundImage: NetworkImage(
                    'https://e7.pngegg.com/pngimages/436/585/png-clipart-computer-icons-user-account-graphics-account-icon-vector-icons-silhouette.png'),
              ),
              const SizedBox(height: 12),
              Text(
                Provider.of<AuthProvider>(context).getFamillyName +
                    '  ' +
                    Provider.of<AuthProvider>(context).getFirstName,
                style: const TextStyle(fontSize: 28, color: Colors.white),
              ),
              Text(
                Provider.of<AuthProvider>(context).getEmail,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
Widget buildMenuItems(BuildContext context) => Wrap(
      runSpacing: 16,
      children: [
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text(
            'My Wallet',
          ),
          onTap: () async {
            var auth = Provider.of<AuthProvider>(context, listen: false);
            var coin = Provider.of<CoinProvider>(context, listen: false);
            var supl = Provider.of<SupplyChainProvider>(context, listen: false);
            // await coin.getCredential(auth.getPrivateKey);
            // await supl.getCredential(
            //     '04eee48c29485fd2ba4fd9993d098a7f5180c020dea04421104c4c4a18226548');
            // final li = await supl.getLocation(BigInt.from(1001));
            // // print(li);

            //final i = await supl.indexInListProduct('Tomatoes');
            //print(i);
            // //print(supl.publicKey.toString());
            // await coin.getCredential(
            //     '04eee48c29485fd2ba4fd9993d098a7f5180c020dea04421104c4c4a18226548');
            // await supl.sendEther(
            //     EthereumAddress.fromHex(
            //         '0x29b73aa3f2e4193e67ae446f7e598ee289f08802'),
            //     1);
            // await coin.mint(
            //     EthereumAddress.fromHex(auth.getPublicKey), BigInt.from(50000));
            // await coin.getCredential(auth.getPrivateKey);

            // await supl.singnMessage(BigInt.from(1002));
            // await coin.blockAmount(
            //     EthereumAddress.fromHex(
            //         '0xDeECcf290c4e44A88C3914929789b6d9B04914b2'),
            //     EthereumAddress.fromHex(auth.getPublicKey),
            //     BigInt.from(1002),
            //     BigInt.from(10000));
            // await supl.mintDeep(EthereumAddress.fromHex(auth.getPublicKey),
            //     coin.contractAddress, BigInt.from(5000));
            Navigator.of(context).pushNamed(WalletScreen.routeName);
          },
        ),
        ListTile(
          leading: const Icon(Icons.history_outlined),
          title: const Text('My history'),
          onTap: () {
            Navigator.of(context).pushNamed(HistoryScreen.routeName);
          },
        ),
        if (Provider.of<AuthProvider>(context).getJobType != 'customer')
          ListTile(
            leading: const Icon(Icons.shop_outlined),
            title: const Text('My Shop'),
            onTap: () {
              Navigator.of(context).pushNamed(SaleScreen.routeName);
            },
          ),
        if (Provider.of<AuthProvider>(context).getJobType != 'customer' &&
            Provider.of<AuthProvider>(context).getJobType != 'farmer')
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('My stock'),
            onTap: () {
              Navigator.of(context).pushNamed(StockScreen.routeName);
            },
          ),
        if (Provider.of<AuthProvider>(context).getJobType != 'customer')
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('To send'),
            onTap: () {
              Navigator.of(context).pushNamed(ToSendScreen.routeName);
            },
          ),
        if (Provider.of<AuthProvider>(context).getJobType != 'farmer')
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('To receive'),
            onTap: () {
              Navigator.of(context).pushNamed(ToReceiveScreen.routeName);
            },
          ),
        const Divider(
          color: Colors.black54,
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Setting'),
          onTap: () {
            Navigator.of(context).pushNamed(SettingScreen.routeName);
          },
        )
      ],
    );
