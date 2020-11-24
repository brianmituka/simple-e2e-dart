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

void processCommands(ArgResults results){
    if (results['generatekeys']) {
      generateKeysAndEncryptAndDecrypt();
    }else if (results['encryptText']) {
    stdout.writeln('Enter Text to encrypt');
    final input = stdin.readLineSync();
    stdout.writeln('Text: $input');
    stdout.writeln('EncryptedText::: >>>>>>');
    }else if (results['decryptText']) {
      stdout.writeln('Enter Text to Decrypt');
    final input = stdin.readLineSync();
    stdout.writeln('Text: $input');
    stdout.writeln('DecryptedText::: >>>>>>');
    }
}

void generateKeysAndEncryptAndDecrypt(){
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
  stdout.writeln('CipherText $cipherText');
  final decryptedText = decrypt(keyPair.privateKey, cipherText);
  stdout.writeln('DecryptedText $decryptedText');
}
void decryptText(){}
void encryptText(){}
