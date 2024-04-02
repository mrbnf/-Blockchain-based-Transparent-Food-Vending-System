import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supplychain/providers/authProvider.dart';

class ResetPasswordForm extends StatefulWidget {
  @override
  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _form = GlobalKey<FormState>();
  String _inputEmail = '';

  late var currentState;

  Future<void>? _saveForm() async {
    currentState = _form.currentState;
    currentState.save();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);
    print('reser passwor form rebuild');
    return Container(
      height: 500,
      padding: const EdgeInsets.all(15),
      child: Form(
          key: _form,
          child: Column(
            children: [
              const Text('Enter the email then check it '),
              TextFormField(
                onSaved: (value) {
                  _inputEmail = value ?? '';
                },
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(
                height: 15,
              ),
              auth.inProgress ? const CircularProgressIndicator() : Container(),
              ElevatedButton(
                onPressed: () async {
                  await _saveForm();
                  try {
                    await auth.resetPassword(_inputEmail);
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
                  'Send Reset',
                  style: TextStyle(fontSize: 18),
                ),
                //color: Colors.blue,
              ),
            ],
          )),
    );
  }
}
