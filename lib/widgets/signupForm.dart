import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/providers/supplychainProvider.dart';

class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _form = GlobalKey<FormState>();
  String _inputEmail = '';
  String _inputPassWord = '';
  String _inputConfirmPassWord = '';
  String _inputFirstName = '';
  String _inputFamillyName = '';
  String _inputPublicKey = '';
  String _inputPrivateKey = '';
  String _inputJob = '';
  String _inputGender = '';
  String _inputWilaya = '';
  String _inputPhoneNumber = '';
  String _inputCommune = '';

  List<String> wilayaList = [
    "Adrar",
    "Chlef",
    "Laghouat",
    "Oum El Bouaghi",
    "Batna",
    "Béjaïa",
    "Biskra",
    "Béchar",
    "Blida",
    "Bouira",
    "Tamanrasset",
    "Tébessa",
    "Tlemcen",
    "Tiaret",
    "Tizi Ouzou",
    "Alger",
    "Djelfa",
    "Jijel",
    "Sétif",
    "Saïda",
    "Skikda",
    "Sidi Bel Abbès",
    "Annaba",
    "Guelma",
    "Constantine",
    "Médéa",
    "Mostaganem",
    "M'Sila",
    "Mascara",
    "Ouargla ",
    "Oran",
    "Bayadh",
    "Illizi",
    "Bordj Bou Arreridj",
    "Boumerdès",
    "El Tarf",
    "Tindouf",
    "Tissemsilt",
    "El Oued",
    "Khenchela",
    "Souk Ahras",
    "Tipaza",
    "Aïn Defla",
    "Naâma",
    "Témouchent",
    "Ghardaïa",
    "Relizane",
    "Timimoun",
    "Bordj Badji Mokhtar",
    "Ouled Djellal",
    "Béni Abbès ",
    "In Salah ",
    "In Guezzam",
    "Touggourt",
    "Djanet",
    "El M'Ghair",
    "El Meniaa",
  ];
  DateTime date = DateTime(1920, 1, 1);
  late var currentState;

  Future<void>? _saveForm() async {
    currentState = _form.currentState;
    currentState.save();
  }

  var l;
  @override
  Widget build(BuildContext context) {
    //print('signup form rebuild');

    var auth = Provider.of<AuthProvider>(context);
    var supl = Provider.of<SupplyChainProvider>(context, listen: false);
    // l = supl.generatePrivateKey();
    // _inputPrivateKey = l[0];
    // _inputPublicKey = l[1];
    final publicController = TextEditingController();
    final privateController = TextEditingController();
    final kKey = GlobalKey<FormFieldState>();
    return auth.loogedIn == true
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(auth.isEmailVerified
                    ? 'your email is verified'
                    : 'your email are not verified'),
                Text(auth.instanse.currentUser.email),
                ElevatedButton(
                  child: const Text('send verification'),
                  onPressed: () async {
                    await auth.sendVerificationEmail();
                  },
                ),
                ElevatedButton(
                  child: const Text('loug out'),
                  onPressed: () async {
                    await auth.signOut();
                  },
                )
              ],
            ),
          )
        : Container(
            //height: 600,
            margin: EdgeInsets.all(30),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 5.0, color: Colors.black.withOpacity(0.5))
              ],
              //border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(
                      20.0) //                 <--- border radius here
                  ),
            ),
            child: Form(
              key: _form,
              child:
                  //SingleChildScrollView(
                  // child:
                  Column(
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Divider(
                    thickness: 5,
                    color: Colors.black,
                    endIndent: 20,
                    indent: 20,
                  ),
                  TextFormField(
                    onSaved: (value) {
                      _inputFirstName = value ?? '';
                    },
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  TextFormField(
                    onSaved: (value) {
                      _inputFamillyName = value ?? '';
                    },
                    decoration:
                        const InputDecoration(labelText: 'Familly Name'),
                  ),
                  TextFormField(
                    onSaved: (value) {
                      _inputEmail = value ?? '';
                    },
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    obscureText: true,
                    onSaved: (value) {
                      _inputPassWord = value ?? '';
                    },
                    decoration:
                        const InputDecoration(labelText: 'Your Password'),
                  ),
                  TextFormField(
                    obscureText: true,
                    onSaved: (value) {
                      _inputConfirmPassWord = value ?? '';
                    },
                    decoration: const InputDecoration(
                        labelText: 'Confirm Your Password'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Birth Date : ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black.withOpacity(0.5))),
                        Text('${date.year}/${date.month}/${date.day}',
                            style: TextStyle(fontSize: 18)),
                        IconButton(
                            onPressed: () async {
                              DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100));
                              if (newDate == null) return;
                              setState(() {
                                date = newDate;
                              });
                            },
                            icon: Icon(Icons.date_range))
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black.withOpacity(0.4),
                    indent: 5,
                    endIndent: 5,
                    thickness: 1,
                  ),
                  DropdownButtonFormField(
                      hint: const Text('Gender'),
                      items: ['Male', 'Female']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onSaved: (value) {},
                      onChanged: (value) {
                        _inputGender = value.toString();
                      }),

                  TextFormField(
                    initialValue: '+213',
                    onSaved: (value) {
                      _inputPhoneNumber = value ?? '';
                    },
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                  ),
                  DropdownButtonFormField(
                      hint: const Text('your Type'),
                      items: <String>[
                        'farmer',
                        'wholesaler',
                        'retailer',
                        'customer'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onSaved: (value) {},
                      onChanged: (value) {
                        if (value == 'farmer') {
                          _inputJob = 'farmer';
                        } else if (value == 'wholesaler') {
                          _inputJob = 'wholesaler';
                        } else if (value == 'retailer') {
                          _inputJob = 'retailer';
                        } else if (value == 'customer') {
                          _inputJob = 'customer';
                        }
                      }),
                  DropdownButtonFormField(
                      hint: const Text('Wilaya'),
                      items: wilayaList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onSaved: (value) {},
                      onChanged: (value) {
                        setState(() {
                          _inputWilaya = value.toString();
                          kKey.currentState?.reset();
                        });
                      }),
                  DropdownButtonFormField(
                      key: kKey,
                      hint: Text('Commune'),
                      items: supl
                          .communeForWilaya(_inputWilaya)
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onSaved: (value) {},
                      onChanged: (value) {
                        _inputCommune = value.toString();
                      }),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 8,
                          child: TextFormField(
                            readOnly: true,
                            controller: publicController,
                            //initialValue: _inputPublicKey,
                            onSaved: (value) {
                              _inputPublicKey = value ?? '';
                            },
                            decoration:
                                const InputDecoration(labelText: 'Public Key'),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: IconButton(
                              onPressed: () {
                                final g = supl.generatePrivateKey();
                                _inputPrivateKey = g[0];
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: Text('Attention'),
                                          content: Container(
                                            height: 200,
                                            child: Column(
                                              children: [
                                                SelectableText(
                                                    'This is your private Key keep it secret   :'),
                                                SelectableText(g[0])
                                              ],
                                            ),
                                          ),
                                        ));
                                privateController.text = g[0];
                                publicController.text = g[1];
                                ;
                              },
                              icon: Icon(
                                Icons.vpn_key,
                                size: 20,
                              )),
                        ),
                      ]),
                  // TextFormField(
                  //   controller: privateController,
                  //   //initialValue: _inputPrivateKey,
                  //   onSaved: (value) {
                  //     _inputPrivateKey = value ?? '';
                  //   },
                  //   decoration: const InputDecoration(labelText: 'Private Key'),
                  // ),

                  const SizedBox(
                    height: 15,
                  ),
                  auth.inProgress
                      ? const CircularProgressIndicator()
                      : Container(),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveForm();
                      try {
                        await auth.signUp(
                            _inputEmail,
                            _inputPassWord,
                            _inputFirstName,
                            _inputFamillyName,
                            _inputPublicKey,
                            _inputPrivateKey,
                            _inputJob,
                            _inputGender,
                            '${date.year}/${date.month}/${date.day}',
                            _inputPhoneNumber,
                            '$_inputWilaya/$_inputCommune');
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
                    child: const Text(
                      'Confirme',
                      style: TextStyle(fontSize: 18),
                    ),
                    // color: Colors.blue,
                  ),
                ],
              ),
              // )
            ),
          );
  }
}
