import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/providers/acountProvider.dart';
import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/providers/supplychainProvider.dart';
import 'package:supplychain/screens/home.dart';
import 'package:supplychain/widgets/resetPassword.dart';

class LoginForm extends StatefulWidget {
  // bool loogedIn = false;

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _form = GlobalKey<FormState>();
  late var currentState;
  String _inputEmail = '';
  String _inputPassWord = '';

  // bool inProgress = false;
  // late var instanse;

  // Future signIn(String email, String password) async {
  //   try {
  //     setState(() {
  //       inProgress = true;
  //     });
  //     await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(email: email, password: password);

  //     instanse = FirebaseAuth.instance;
  //     setState(() {
  //       inProgress = false;
  //       widget.loogedIn = true;
  //     });
  //   } catch (erreur) {
  //     setState(() {
  //       widget.loogedIn = false;
  //       inProgress = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(erreur.toString()),
  //       action: SnackBarAction(
  //         label: 'Undo',
  //         onPressed: () {
  //           // Some code to undo the change.
  //         },
  //       ),
  //     ));
  //     print(erreur.toString());
  //   }
  // }

  // Future<void> signOut() async {
  //   await instanse.signOut();
  //   setState(() {
  //     widget.loogedIn = false;
  //   });
  // }

  Future<void>? _saveForm() async {
    currentState = _form.currentState;
    currentState.save();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: true);
    var supl = Provider.of<SupplyChainProvider>(context, listen: false);
    var acount = Provider.of<AccountProvider>(context, listen: false);
    print('loginForm rebuild');
    return auth.onRestPassword == true
        ? ResetPasswordForm()
        // : p.loogedIn == true & p.isEmailVerified
        // ? Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text(
        //             ? 'your email is verified'
        //             : 'your email are not verified'),
        //         Text(p.instanse.currentUser.email),
        //         FlatButton(
        //           child: Text('loug out'),
        //           onPressed: () async {
        //             await p.signOut();
        //           },
        //         )
        //       ],
        //     ),
        //   )
        : Container(
            //padding: const EdgeInsets.all(15),
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
            //height: 500,
            width: double.infinity - 50,
            child: Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      onSaved: (value) {
                        _inputEmail = value ?? '';
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'password'),
                      onSaved: (value) {
                        _inputPassWord = value ?? '';
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    auth.inProgress
                        ? const CircularProgressIndicator()
                        : Container(),
                    TextButton(
                        onPressed: () async {
                          // try {
                          // await supl.getCredentialfromPrivateKey(
                          //     '70e5f2cb76a98e58893d2b65d064c5c25d96fe0669b46419be865f4bcb9fc63a');
                          // await supl.farmerAddProduct(
                          //     BigInt.parse(0.toString()),
                          //     BigInt.parse(2333.toString()),
                          //     BigInt.parse(2333.toString()),
                          //     BigInt.parse(2333.toString()));

                          // final li = await supl
                          // .farmersProductsForSale(supl.publicKey);
                          // await acount.createAcount(
                          //     'aziz', 'benafghoul', BigInt.one);
                          //   print(li[0]);
                          // } catch (error) {
                          //   print(error.toString());
                          // }
                          auth.setRestPassword();
                          // Navigator.of(context)
                          //     .pushReplacementNamed(HomeScreen.routeName);
                        },
                        child: const Text(' Forgot Password ')),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _saveForm();
                        try {
                          await auth.signIn(_inputEmail, _inputPassWord);

                          if (auth.isEmailVerified) {
                            // final l = await supl.productDatafromList(await supl
                            //     .farmersProductsForSale(supl.publicKey));

                            //print(l.runtimeType);

                            // await supl.farmerAddProduct(
                            //     BigInt.from(2),
                            //     BigInt.from(3000),
                            //     BigInt.from(300),
                            //     BigInt.from(333));
                            Navigator.of(context)
                                .pushReplacementNamed(HomeScreen.routeName);
                          }
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
                        'Login',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                      // color: Colors.blue,
                    ),
                  ],
                )),
          );
  }
}
