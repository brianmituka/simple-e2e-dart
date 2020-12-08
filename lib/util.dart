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

  RSAPublicKey parsePublicKeyContentToRSAPublicKey(String publicKeyString) {
    var publicKeyContent = publicKeyString.split("##Public##");
    var modulus = base64.decode(publicKeyContent[0].trim());
    var exponent = base64.decode(publicKeyContent[1].trim());
    var finalModulus = utf8.decode(modulus) as BigInt;
    var finalExponent = utf8.decode(exponent) as BigInt;
    var rsaPublicKey = RSAPublicKey(finalModulus, finalExponent);
    print("exponent $finalExponent");
    print("modulus $finalModulus");
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

  static String _formatBytesAsHexString(Uint8List bytes) {
    var result = StringBuffer();
    for (var i = 0; i < bytes.lengthInBytes; i++) {
      var part = bytes[i];
      result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return result.toString();
  }

  String characterCodeToUtf8(String characterCode) {
    return base64.encode(characterCode.codeUnits);
  }
}
