import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:async';

import 'package:web3dart/web3dart.dart';

class AuthProvider extends ChangeNotifier {
  Timer? timer;
  late var currentState;
  late var instanse;
  late String userId;
  late String _email;
  late String _password;
  late String _firstName;
  late String _famillyName;
  late String _publicKey;
  late String _privateKey;
  late String _jobType;
  late String _gender;
  late String _phoneNumber;
  late String _location;
  late String _birthDate;
  bool inProgress = false;
  bool loogedIn = false;
  bool resetPasswordSent = false;
  bool onRestPassword = false;
  bool isEmailVerified = false;
  String get getEmail {
    return _email;
  }

  String get getFamillyName {
    return _famillyName;
  }

  String get getFirstName {
    return _firstName;
  }

  String get getPublicKey {
    return _publicKey;
  }

  String get getPrivateKey {
    return _privateKey;
  }

  String get getJobType {
    return _jobType;
  }

  Future<void> louGout() async {
    await FirebaseAuth.instance.signOut();
    // setState(() {
    loogedIn = false;
    isEmailVerified = false;
  }

  void setRestPassword() {
    onRestPassword = !onRestPassword;
    notifyListeners();
  }

  Future signIn(String email, String password) async {
    _email = email;
    _password = password;
    try {
      inProgress = true;
      notifyListeners();

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      instanse = FirebaseAuth.instance;

      inProgress = false;
      loogedIn = true;
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      print(isEmailVerified.toString());
      if (isEmailVerified == false) {
        loogedIn = false;
        inProgress = false;
        notifyListeners();
        await FirebaseAuth.instance.currentUser!.delete();
        throw (Exception('compte not exist'));
      }
      userId = FirebaseAuth.instance.currentUser!.uid.toString();

      final _dpublicKey = await FirebaseFirestore.instance
          .collection('publicKeys')
          .doc(userId)
          .get();

      _publicKey = _dpublicKey['Public Key'];
      final data = await FirebaseFirestore.instance
          .collection('users')
          .doc(_publicKey)
          .get();

      _email = data.data()!['Email'] as String;
      _password = data.data()!['Password'] as String;
      _famillyName = data.data()!['Familly Name'] as String;
      _firstName = data.data()!['First Name'] as String;
      _publicKey = data.data()!['Public Key'] as String;
      _privateKey = data.data()!['Private Key'] as String;
      _jobType = data.data()!['Job Type'] as String;
      _location = data.data()!['Location'] as String;
    } catch (erreur) {
      loogedIn = false;
      inProgress = false;
      notifyListeners();
      //print(erreur.toString());
      rethrow;
    }
  }

  Future sendVerificationEmail() async {
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
  }

  Future signUp(
      String email,
      String password,
      String firstName,
      String famillyName,
      String publicKey,
      String privateKey,
      String jobType,
      String gender,
      String birthDate,
      String phoneNumber,
      String location) async {
    _location = location;
    _phoneNumber = phoneNumber;
    _birthDate = birthDate;
    _gender = gender;
    _email = email;
    _password = password;
    _firstName = firstName;
    _famillyName = famillyName;
    _publicKey = publicKey.toLowerCase();
    _privateKey = privateKey;
    _jobType = jobType;
    try {
      inProgress = true;
      notifyListeners();
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      inProgress = false;
      loogedIn = true;
      isEmailVerified = false;
      instanse = FirebaseAuth.instance;

      notifyListeners();
      sendVerificationEmail();
      timer = Timer.periodic(
          const Duration(seconds: 8), (_) async => checkEmailVerified());
    } catch (erreur) {
      loogedIn = false;
      inProgress = false;
      notifyListeners();
      //print(erreur.toString());
      rethrow;
    }
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    print(FirebaseAuth.instance.currentUser!.emailVerified);
    if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
      isEmailVerified = true;
      notifyListeners();
      timer?.cancel;
      userId = FirebaseAuth.instance.currentUser!.uid.toString();
      await FirebaseFirestore.instance.collection('users').doc(_publicKey).set({
        'Email': _email,
        'Password': _password,
        'Familly Name': _famillyName,
        'First Name': _firstName,
        'Public Key': _publicKey,
        'Private Key': _privateKey,
        'Job Type': _jobType,
        'Gender': _gender,
        'Birth Date': _birthDate,
        'Phone Number': _phoneNumber,
        'Location': _location,
      });

      await FirebaseFirestore.instance
          .collection('publicKeys')
          .doc(userId)
          .set({
        'Public Key': _publicKey,
      });
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      inProgress = true;
      notifyListeners();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setRestPassword();
      inProgress = false;
      onRestPassword = false;
      notifyListeners();
    } catch (error) {
      inProgress = false;
      notifyListeners();
      onRestPassword = false;
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // setState(() {
    loogedIn = false;
    isEmailVerified = false;
    notifyListeners();
    // });
  }

  Future<dynamic> laodImage(BigInt id) async {
    try {
      return await FirebaseStorage.instance
          .ref()
          .child('files/$id')
          .getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getInformationFromPublicAddress(
      String publicAddress) async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(publicAddress)
        .get();
    List<String> l = [];
    l.add(data.data()!['First Name'] as String);
    l.add(data.data()!['Familly Name'] as String);
    l.add(data.data()!['Job Type'] as String);
    l.add(data.data()!['Location'] as String);

    return l;
  }
}
