import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/providers/authProvider.dart';
import 'package:supplychain/widgets/loginForm.dart';
import '../widgets/signupForm.dart';

class FirstScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  State<FirstScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<FirstScreen> {
  bool inLogin = true;
  bool isLogged = false;

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            inLogin ? LoginForm() : SignupForm(),
            // const SizedBox(
            //   height: 10,
            // ),
            Consumer<AuthProvider>(
                builder: (ctx, auth, _) => auth.loogedIn == false
                    ? TextButton(
                        onPressed: () {
                          if (auth.onRestPassword == true) {
                            auth.setRestPassword();
                          }
                          setState(() {
                            inLogin = !inLogin;
                          });
                        },
                        child: inLogin
                            ? Column(
                                children: [
                                  Text(
                                    "Can't have an account ,",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Text(
                                    ' Create a new one',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 25),
                              ))
                    : Container())
          ],
        ),
      )),
    );
  }
}
