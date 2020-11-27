import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:simple2edart/simple2edart.dart' as simple2edart;
import 'package:simple2edart/crypto.dart';
import 'package:simple2edart/util.dart';

// var lineNumber;
ArgResults results;

void main(List<String> arguments) {
  exitCode = 0;
  final parser = ArgParser()
    ..addFlag("generatekeys", negatable: false, abbr: 'g')
    ..addFlag("encryptText", negatable: false, abbr: 'e')
    ..addFlag("decryptText", negatable: false, abbr: 'd')
    ..addFlag("file", negatable: false, abbr: 'f');
  results = parser.parse(arguments);
  processCommands(results);
}

void processCommands(ArgResults results) {
  if (results['generatekeys']) {
    generateKeysAndEncryptAndDecrypt();
  } else if (results['encryptText']) {
    encryptText();
  } else if (results['decryptText']) {
    stdout.writeln('Enter Text to Decrypt');
    final input = stdin.readLineSync();
    stdout.writeln('Text: $input');
    stdout.writeln('DecryptedText::: >>>>>>');
  }
}

void generateKeysAndEncryptAndDecrypt() {
  final keyPair = generateRSAKeyPair(Util().generateSecureRandom());
  final publicKey = keyPair.publicKey;
  final privateKeyPem = keyPair.privateKey.toString();
  final publicKeyPem = Util().encodePublicKeyToFrontlineFormat(publicKey);
  stdout.writeln('Public Key $publicKeyPem');
  stdout.writeln('Private Key $privateKeyPem');
  stdout.writeln('Enter Text to Encrypt');
  final input = stdin.readLineSync();
  stdout.writeln("You entered $input");
  final cipherText = encrypt(keyPair.publicKey, input);
  final decryptedText = decrypt(keyPair.privateKey, cipherText);
  final cleanCipherText = Util().characterCodeToUtf8(cipherText);
  stdout.writeln('cipherText $cleanCipherText');
  stdout.writeln('DecryptedText $decryptedText');
}

void decryptText() {}
void encryptText() {
  stdout.writeln('Enter public key to encrypt');
  final input = """##PUBLIC##
MIIBCgKCAQEAhfgamqWjqAMBHf9rZRhl6mgUMAuYrv+dP02Ic9s/lrdvK2JRr0BP
sVcnKsR2IYtfFlMraPUyzoHHs/c/yFZHZFu4aqj1d97lITZxOF3lXC7pxr29u1Ge
W+0NILU8w5lSSwBw7LNMud8BNLnHzVzJUj/QEDmaJBeoZ+03JRSWz3GzOOcgYYfL
wCKSs3LN2PGVjxO0vnOkStmVYTKCM612yl7pFkrnpSApHpt+/bzsMSJoXK7w0F2e
d2vjI8b6Tut79xNfDf4XNVENWDLFlEIADXrzyzfzBnuBgG6hqdV2TQxpqS8PhlKe
kqd4GQEYJ6+ACO3P2tV5h+tFZeF3nk1WkQIDAQAB
##PUBLIC##""";
  RSAPublicKey publicKey = Util().parseFrontlinePublicKey(input);
  stdout.writeln('Enter text to encrypt');
  final textToencrypt = stdin.readLineSync();
  final cipherText = encrypt(publicKey, textToencrypt);
  final base64encodedcipher = Util().characterCodeToUtf8(cipherText);
  stdout.writeln('Ciphetext:: $cipherText');
  stdout.writeln('base64Ciphetext:: $base64encodedcipher');
}
