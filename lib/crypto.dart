import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asymmetric/pkcs1.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:hex/hex.dart';
// import "package:pointycastle/export.dart";

//TODO Add key signature verification

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair(
    SecureRandom secureRandom,
    {int bitLength = 4096}) {
  final rsaParams = RSAKeyGeneratorParameters(
      BigInt.parse('65537', radix: 16), bitLength, 64);
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(rsaParams, secureRandom));
  final keyPair = keyGen.generateKeyPair();
  final publicKey = keyPair.publicKey;
  final privateKey = keyPair.privateKey;
  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(publicKey, privateKey);
}

String encrypt(RSAPublicKey publicKey, String dataToEncrypt) {
  final publicKeyParams = PublicKeyParameter<RSAPublicKey>(publicKey);
  final encryptor = PKCS1Encoding(RSAEngine())..init(true, publicKeyParams);
  var ciphertext =
      encryptor.process(Uint8List.fromList(dataToEncrypt.codeUnits));
  var hexcipher = HEX.encode(ciphertext);
  print('CIpher textoriji $ciphertext');
  print('Hex:: $hexcipher');

  return String.fromCharCodes(ciphertext);
}

String decrypt(RSAPrivateKey privateKey, String cipherText) {
  final privateKeyParams = PrivateKeyParameter<RSAPrivateKey>(privateKey);
  final decryptor = PKCS1Encoding(RSAEngine())..init(false, privateKeyParams);
  var decryptedText =
      decryptor.process(Uint8List.fromList(cipherText.codeUnits));
  return String.fromCharCodes(decryptedText);
}
