part of coreutils;

String encodeBase64(List<int> bytes) {
  return CryptoUtils.bytesToBase64(bytes);
}

List<int> decodeBase64(String input) {
  return CryptoUtils.base64StringToBytes(input);
}

String asHex(List<int> bytes) {
  return CryptoUtils.bytesToHex(bytes);
}

Future<List<int>> readStdin() async {
  var file = new File("/dev/stdin");

  return await file.readAsBytes();
}

class IOUtils {
  static void exit(int code) {
    io.exit(code);
  }
}
