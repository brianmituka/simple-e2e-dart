import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class Util {
  static const BEGIN_PRIVATE_KEY = '##PRIVATE##';
  static const END_PRIVATE_KEY = '##PRIVATE##';

  static const BEGIN_PUBLIC_KEY = '##PUBLIC##';
  static const END_PUBLIC_KEY = '##PUBLIC##';

  SecureRandom generateSecureRandom() {
    final secureRandom = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  String encodePublicKeyToFrontlineFormat(RSAPublicKey publicKey) {
    var algorithmSeq = ASN1Sequence();
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(ASN1ObjectIdentifier.fromName('rsaEncryption'));
    algorithmSeq.add(paramsAsn1Obj);

    var publicKeySeq = ASN1Sequence();
    publicKeySeq.add(ASN1Integer(publicKey.modulus));
    publicKeySeq.add(ASN1Integer(publicKey.exponent));
    var publicKeySeqBitString =
        ASN1BitString(stringValues: Uint8List.fromList(publicKeySeq.encode()));

    var topLevelSeq = ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqBitString);
    var dataBase64 = base64.encode(topLevelSeq.encode());
    var chunks = chunk(dataBase64, 64);

    return '$BEGIN_PUBLIC_KEY\n${chunks.join('\n')}\n$END_PUBLIC_KEY';
  }

  static Uint8List getBytesFromFrontlinePEMString(String pem) {
    var lines = LineSplitter.split(pem)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.length < 2 ||
        !lines.first.startsWith(BEGIN_PUBLIC_KEY) ||
        !lines.last.startsWith(END_PUBLIC_KEY)) {
      throw ArgumentError("Not a valid Frontline Public Key");
    }
    var base64 = lines.sublist(1, lines.length - 1).join('');
    return Uint8List.fromList(base64Decode(base64));
  }

  static RSAPublicKey parseFrontlinePublicKey(String pem) {
    if (pem == null) {
      throw ArgumentError('Argument must not be null');
    }
    var bytes = getBytesFromFrontlinePEMString(pem);
    return rsaPublicKeyFromDERBytes(bytes);
  }

//SEE https://tls.mbed.org/kb/cryptography/asn1-key-structures-in-der-and-pem
  static RSAPublicKey rsaPublicKeyFromDERBytes(Uint8List bytes) {
    var asn1Parser = ASN1Parser(bytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    var publicKeyBitString = topLevelSeq.elements[1] as ASN1BitString;

    var publicKeyAsn = ASN1Parser(publicKeyBitString.stringValues);
    ASN1Sequence publicKeySeq = publicKeyAsn.nextObject();
    var modulus = publicKeySeq.elements[0] as ASN1Integer;
    var exponent = publicKeySeq.elements[1] as ASN1Integer;

    var rsaPublicKey = RSAPublicKey(modulus.integer, exponent.integer);

    return rsaPublicKey;
  }

  List<String> chunk(String s, int chunkSize) {
    var chunked = <String>[];
    for (var i = 0; i < s.length; i += chunkSize) {
      var end = (i + chunkSize < s.length) ? i + chunkSize : s.length;
      chunked.add(s.substring(i, end));
    }
    return chunked;
  }
}
