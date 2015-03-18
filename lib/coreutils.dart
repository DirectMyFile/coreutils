import "dart:io";

import "package:args/args.dart";
import "package:crypto/crypto.dart";

export "package:args/args.dart";

const String VERSION = "1.0.0";

ArgResults handleArguments(List<String> args, String tool, {void handle(ArgParser parser), String usage}) {
  var argp = new ArgParser();

  argp.addFlag("help", abbr: "h", help: "Displays this Help Message");
  argp.addFlag("version", abbr: "v", help: "Display Version");

  if (handle != null) {
    handle(argp);
  }

  ArgResults result;

  void printHelp() {
    print("Usage: ${tool} [options]${usage != null ? " ${usage}" : ""}");
    if (argp.usage.isNotEmpty) {
      print(argp.usage);
    }
    exit(1);
  }

  try {
    result = argp.parse(args);
  } on FormatException catch (e) {
    print("ERROR: ${e}");
    printHelp();
  }

  if (result["help"]) {
    printHelp();
  }

  if (result["version"]) {
    print("${tool} v${VERSION}");
    exit(0);
  }

  return result;
}

String encodeBase64(List<int> bytes) {
  return CryptoUtils.bytesToBase64(bytes);
}

List<int> decodeBase64(String input) {
  return CryptoUtils.base64StringToBytes(input);
}

String asHex(List<int> bytes) {
  return CryptoUtils.bytesToHex(bytes);
}

List<int> readStdin() {
  var bytes = [];

  int b;

  while ((b = stdin.readByteSync()) != -1) {
    bytes.add(b);
  }

  return bytes;
}
