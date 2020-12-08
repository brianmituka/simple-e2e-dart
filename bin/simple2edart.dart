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
  final newKey ='''ODM3NjM1MDQ0ODI3NzE4Mzc0ODk1Njk2MTEwOTE4NDI3NDMwMzcyMzMzNjAzMzU1OTM0MTAxMTM5MzczODA1NDkxMDg0MzYxMTI3NDIyOTk3ODc0Mjk1NzY3Nzk5MTcxMTU4MTUzOTgxMjQ3MTY5MDQxNzg1OTkyODQyMTQ1MTk0MjA5ODcxMzIyNTAyNDYxMDc2NjYwNzA5MDAyNzc3OTUyODUzMzY4NjczODAxMTU4NzMwMjI2NjkwNjA5MDU0MDQzMjk2MDY2NTExODY2MDQ1ODY4MjEzNzI0NzQwMjg0ODk0NjYxNjUxOTYzNjEwODE3MzQ5NDMwNjIwNDczMDc2MjU0ODM0MDI2OTI3Mzg0MzE4MTE1Njk2ODg5MTkxMjA4NjkyMjEyMTA4NzgwMTU0MDkzMjIwMjE0NzczMTE3ODA3Nzk0ODc2NDAyNjk4NTYzNjg5MDg2MzEyMTk0ODQ5MTYwODk4NTAxMjU2NzcwMzc5NDc0ODEyNzMyNDk1MDM4Mzg3NDUwNzYzNDcxOTY1OTY1NTY1NzYwNzIzNTQyODcyMjczNjg3OTU4NDQzNjEyNTI1MTA0NzM2NDU5MTc4NDcxNDkwMTQ1ODg4MTQ0NzY2NTA0Mjk2ODUwNjAzMzgzMDkwMTAwNTIwNzkwNzg0OTUwMDE0MjU4MTQ3MTcwMDE2MjY3MzYxNjczNjU4OTU1MDMzNTU4NDc5OTc1NjUwMDcyNDM4MTkzOTg2NzIzNTY4MjM5MTc2NTg2MDI4ODgyODM2NDY2NzEyOTM4MDI1OTIyOTY0NzQ5Nzg1MjI0NTYwNzY2Mzg1NjA4NzEzNTAwNzU4OTgxMjI1Nzg5OTMwODk0Mjc0NDM0MzQ3MTk2NTgxNTU4NTYwNjIyNDI4ODgxOTUyMzk0MTQ0ODMyNjQ0OTY4MzQ2MTE0MzE5NjIyMTY3ODg3MjU3MDY2MjAyNjc4MDQzMzkzMTAxNTE4NTczMTU0MDA3NTgxNzc0OTYzMjg0MTA5MTc1OTMxMjQyMTU4MzcwNTA1NDMwMTY3Mjg5MjExMzc4MTM0MzYxOTEzOTcxNTAxMTc0NzEwMjQ5NjA2OTQ2MDQ5ODMwMTI0OTg1MDkyMjE4MjgyNzc3MjY3MjEwNzIzNDk5MzEzNDQwOTE2NzI1ODU5NTk5NjIzMjk5ODM0MjQ2MTMyMzE0OTg1MzAxNTA1NzM5MTYyOTcxMzk0MDQyNTM0NjQ0OTE5MDM0NjU4NzIzMTY3NDgzMzUyNTc3MTc1NzA4MTg4NjMyMjY0OTY1NzM3NjQ4NTQ0NDA3Mjk3NzkzMDg0ODI4MDkzOTM5MDE4NjM3MzIwODE5NTA4NDg0NzY3MDUzOTgyNDAzMTc3NjQ0MDAzMjA2OTI0MDI2NTMyMDIyNTEwODQwNTc2MzEzNzI5MDU3NTU1MTA1OTk4MTYxNzE2NzA2NTgwOTY4Njk2MTAxODgxNTM2NDgwMTc5MDU5MTI5OTI4MTk3MjgxNzg1ODQxMjYwNDEzMDA5MTA4MzIxODcxMTI4MDgzNTI1MTA3NjkwNjgyNTA3OTAwMzYzMDExNDQyNTQwNjU4MDM3MjU4NzAyODI0NzE4NTA4NTAyNzMzNzMzNTcxODQ5MzAxNzExODczNzAz##Public##NDE1MDMx
''';
  final publicKey = Util().parsePublicKeyContentToRSAPublicKey(newKey);;
  stdout.writeln('Enter text to encrypt');
  final textToencrypt = stdin.readLineSync();
  final cipherText = encrypt(publicKey, textToencrypt);
  stdout.writeln('Ciphetext:: $cipherText');
}
