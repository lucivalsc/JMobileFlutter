import 'package:encrypt/encrypt.dart';

class Cryptography {
  static final _key = Key.fromBase16("770a8a65da156d24ee2a093277530142");
  static final _iv = IV.fromBase16("101112131415161718191a1b1c1d1e1f");
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc, padding: "PKCS7"));

  static String encrypt(String input) {
    return _encrypter.encrypt(input, iv: _iv).base64;
  }

  static String decrypt(String input) {
    return _encrypter.decrypt64(input, iv: _iv);
  }
}
