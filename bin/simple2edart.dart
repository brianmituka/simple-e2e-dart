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
  final newKey ='''NzIyNzM3MTIxOTY4NDQ3OTM1NjQ0ODM3MzIwMTMxNjA3NDQ0NTgzMzA1NTYzOTE0MzE3MjI1NzA4NjkyMTE3MTkzNTg4NjAwOTkxNjY1Mzk4NDgxNTY1NjUwOTQyNjkxNjUwNzc4NTAwOTA0Mzk0NjUyMjU3NTI5Njg5NzIxNjkwMTM2OTM2MTM3MjM3MDgxNzEyODAzNjIwMjE1Mjg1NzE3NTM2MTA1MDg5NzcyMDc4MjQ3NDEwMjk1MDkzNzQ0ODIwMTM4OTE3MzU2NzUwMjQ4MjMzNDYyMzE2MTE0NzEwMzg0MjAwNjAzODA4Njk3MDgxMDk1OTY4OTQ2MTIwOTIzOTI1Mjc2NjM3MDA5MTI4NDQ5OTE0NDc3OTk1NzU0OTQ1NDI2MDM0MTc2MjE1Mzc0ODkyOTkxODU5NDQxNjY4NTk3NTcyNTUxNzUxMjI2ODc5OTc3MjM0MDM1ODQ3ODAzNjAxOTM3OTg0MzE2Mzc3NDAxOTAxNDYwNzUzNDY1Nzg1NDI1MTkwNTkwODMyMTc0OTM2MjYyOTU0OTc2MTYxNzUxNzQ0MzIxNTgzNjk3MDQ4MjIxMTk2Nzg5NjY0NDI4MTg5ODYwNDg0MTAwNTc2MTM1Mzg2OTAxNTg0OTIzMTc4MzY0OTE3MDU5Mjg0MjY5ODczMjEyMDM5OTA1NTU0NDQ5MTM3NjEyMjA5MTQwNDYyNjUwNjI3NDUwMzY5OTM2MDk3MDA0NDM3NjE1ODUzODIwNjkxNjUxODI3MzQyNjE1NDc1MTM1MDk0MTkyMjc5NzkxMTI1OTg1NjE4NjA1NTcxMjk2NzcxMjUxODY0OTc1MDQ1MTc5MTYxODMyNTAzMjQyNzAyMDczNDAwNTg5MDg5MTMxMjM2NjY0OTM5NzQ5MTk2OTkzNjE0NTgyNzU1MzExNzgxODQ5MTgzNjM4ODUzMzkwMjE2NDQ0NDMwMDk1NzM3NTIxODExNDUzNDE2NjE2MzY0MzcxNzYxOTc1MjU3NTE5Njc3MDk3MzA1OTEwMzA4MTQwMTk0MDU5OTA1Mzk2NTkzNzU4MDg3ODcwNTAwMjA4NTM4OTQ1MDg4Njc1NzQ5MTQ5OTE4MjMzMDY1NDQzNzgzODE1MTcyNjUzODM5MjM1MjkzNzM1OTk3NzQ2MDA0MzE3NDI0NDgwNjAwNzQyMjg2NDYzMjA5NDY4MDA3NDczOTE3MzE3MDY3MDQ4MDI1NzcyNjg1OTk2ODQzMDY3MjUxMzgyNjY5MjYxMzQyMzAxNDM4ODM5MDU2MDg1MDk4MzE2MDM1MDgxMzI2OTQwMDQxNTU4OTQ0NjIwMzY0NzgxNzQwMjk0OTk4MTQ2ODQ5MTUxMTQ0OTQxMTk4NDIxNDkyMDEwMDA5MzI4ODc2MjQwMzUxMDU2NzgxMDM1NDA4ODAxOTE2NzkwNzE0MjUyMTA4MjQ1NDY0NDE1MDgyOTg2MzE5OTU4MzA4MTgzNzk5Nzc2MDYzMTA2MDcwNDk4MTM4OTYwODU5NzAwOTE0NDI2OTc4MjE2Mjk2NDgyMTU2OTU3NTY4MTY0NTIwNjIzMzUzMjk2NzI0NDM2MDY5NDMwNjIzODc2NjA2OTQyMDI1MzYxODA4MjUxNTkwNzY0NTg2NzM1MTYzOTM5##Public##NDE1MDMx
''';
  final publicKey = Util().parsePublicKeyContentToRSAPublicKey(newKey);;
  stdout.writeln('Enter text to encrypt');
  final textToencrypt = stdin.readLineSync();
  final cipherText = encrypt(publicKey, textToencrypt);
  stdout.writeln('Ciphetext:: $cipherText');
}
