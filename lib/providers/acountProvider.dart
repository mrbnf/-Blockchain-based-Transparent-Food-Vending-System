import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class AccountProvider extends ChangeNotifier {
  final String _rpcUrl = 'http://192.168.43.240:8545';
  final String _wsUrl = 'ws://192.168.43.240:8545/';
  final String _privateKey =
      '40e22b49dd39c00627732d2c2442174dcd7a25781e97590ef4321d6c73010bcd';
  late Web3Client _client;
  late String _abiCode;
  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late EthereumAddress _ownAddress;
  late DeployedContract _contract;
  late ContractFunction _acountsList;
  late ContractFunction _acountExist;
  late ContractFunction _createAcount;
  late ContractFunction _login;

  String aziz = 'aziz';

  bool isLogin = false;
  AccountProvider() {
    initiateSetup();
  }
  Future<void> initiateSetup() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    await getAbi();
    await getCredential();
    await getDeployedContract();
  }

  Future<void> getCredential() async {
    _credentials = await _client.credentialsFromPrivateKey(_privateKey);
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString('src/abis/AcountManagement.json');
    var jsonAbiCode = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbiCode['abi']);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbiCode['networks']['5777']['address']);
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, 'AcountManagement'), _contractAddress);
    _acountExist = _contract.function('acountExist');
    _acountsList = _contract.function('acountsList');
    _createAcount = _contract.function('createAcount');
    _login = _contract.function('login');
  }

  Future<void> login(String userName, String password) async {
    isLogin = false;
    var temp = await _client.call(
        contract: _contract, function: _login, params: [userName, password]);
    print(temp);
    // if (temp == false) {
    //   isLogin = false;
    // } else {
    //   isLogin = true;
    // }
  }

  Future<void> createAcount(
      String _userName, String _password, BigInt _job) async {
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _createAcount,
            parameters: [_userName, _password, _job]));
  }
}
