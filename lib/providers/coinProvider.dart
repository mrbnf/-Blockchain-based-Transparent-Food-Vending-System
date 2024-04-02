import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:hex/hex.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class CoinProvider extends ChangeNotifier {
  @override
  void dispose() {
    _client.dispose();

    super.dispose();
  }

  final String _rpcUrl = 'http://192.168.43.240:8545';
  final String _wsUrl = 'ws://192.168.43.240:8545/';
  late String _privateKey;
  late Web3Client _client;
  late String _abiCode;
  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late EthereumAddress? _publicAddress;
  late DeployedContract _contract;

  late ContractFunction _transfert;
  late ContractFunction _mint;
  late ContractFunction _transfertWithSignature;
  late ContractFunction _blockAmount;
  late ContractFunction _balance;
  late ContractFunction _balanceToReceiveBlocked;
  late ContractFunction _balanceToSendBlocked;

  late ContractFunction _getHash;

  String aziz = 'aziz';

  bool isLogin = false;
  CoinProvider() {
    initiateSetup();
  }

  EthereumAddress get contractAddress {
    return _contractAddress;
  }

  EthereumAddress get publicKey {
    return _publicAddress!;
  }

  Future<void> lougout() async {
    isLogin = false;
  }

  Future<dynamic> getHash(BigInt id) async {
    final str = id.toString();
    final list = await _client
        .call(contract: _contract, function: _getHash, params: [str]);
    //print(list.toString());
    return list;
  }

  Future<String> singnMessage(BigInt id) async {
    final hash = await getHash(id);
    List<int> intList = hash[0].cast<int>().toList();
    Uint8List data = Uint8List.fromList(intList);

    final signature = await _credentials.signPersonalMessage(data);

    print(signature);

    String result = hex.encode(signature);
    print(result);

    return result;
  }

  Future<void> initiateSetup() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    //await getCredential();
    await getDeployedContract();
  }

  Future<void> getCredentialfromPrivateKey(String _privateKeyy) async {
    await _client.credentialsFromPrivateKey(_privateKeyy);
  }

  Future<void> getCredential(String _privateKeyy) async {
    _credentials = await _client.credentialsFromPrivateKey(_privateKeyy);
    _publicAddress = await _credentials.extractAddress();
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString('assets/src/abis/MyCoin.json');
    var jsonAbiCode = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbiCode['abi']);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbiCode['networks']['5777']['address']);
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, 'MyCoin'), _contractAddress);

    _balanceToSendBlocked = _contract.function('balanceToSendBlocked');
    _balanceToReceiveBlocked = _contract.function('balanceToReceiveBlocked');
    _balance = _contract.function('balance');
    _blockAmount = _contract.function('blockAmount');
    _transfertWithSignature = _contract.function('transfertWithSignature');
    _mint = _contract.function('mint');
    _transfert = _contract.function('transfert');
    _getHash = _contract.function('getHash');
  }

  Future<BigInt> balanceToSendBlocked(EthereumAddress person) async {
    final list = await _client.call(
        contract: _contract, function: _balanceToSendBlocked, params: [person]);
    //print(list.toString());
    return list[0];
  }

  Future<BigInt> balanceToReceiveBlocked(EthereumAddress person) async {
    final list = await _client.call(
        contract: _contract,
        function: _balanceToReceiveBlocked,
        params: [person]);
    //print(list.toString());
    return list[0];
  }

  Future<BigInt> balance(EthereumAddress person) async {
    final list = await _client
        .call(contract: _contract, function: _balance, params: [person]);
    //print(list.toString());
    return list[0];
  }

  Future<void> blockAmount(EthereumAddress receiver, EthereumAddress sender,
      BigInt productId, BigInt amount) async {
    final idData = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _blockAmount,
            parameters: [receiver, sender, productId, amount]));
  }

  Future<void> transfertWithSignature(EthereumAddress receiver,
      EthereumAddress sender, Uint8List signature, BigInt productId) async {
    final idData = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _transfertWithSignature,
            parameters: [receiver, sender, signature, productId]));
  }

  Future<void> mint(EthereumAddress receiver, BigInt amount) async {
    final idData = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _mint,
            parameters: [receiver, amount]));
  }

  Future<void> transfert(EthereumAddress receiver, BigInt amount) async {
    final idData = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _transfert,
            parameters: [receiver, amount]));
  }
}
