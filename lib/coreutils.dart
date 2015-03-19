library coreutils;

import "dart:io";

import "package:args/args.dart";
import "package:crypto/crypto.dart";

import "package:binary_interop/binary_interop.dart";

export "package:args/args.dart";

part "src/syscall.dart";
part "src/format.dart";

const String VERSION = "1.0.0";

ArgResults handleArguments(List<String> args, String tool, {bool fail(ArgResults result), void handle(ArgParser parser), String usage}) {
  var argp = new ArgParser();

  argp.addFlag("help", abbr: "h", negatable: false, help: "Displays this Help Message");
  argp.addFlag("version", abbr: "v", negatable: false, help: "Display Version");

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

  if (fail != null && fail(result)) {
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

void init() {
  SystemCalls.init();
}

List<FileSystemEntity> walkTreeBottomUp(Directory dir) {
  var list = [];

  var items = dir.listSync();
  for (var item in items) {
    if (item is Directory) {
      list.addAll(walkTreeBottomUp(item));
      list.add(item);
    } else {
      list.add(item);
    }
  }

  return list;
}

String formatDate(DateTime d, String format) {
  String tn(int n) {
    if (n < 9) {
      return "0${n}";
    } else {
      return n.toString();
    }
  }

  return formatString(format, {
    "H": () => tn(d.hour),
    "I": () => ((d.hour + 11) % 12 + 1).toString(),
    "k": () => d.hour.toString().length == 1 ? " ${d.hour}" : d.hour.toString(),
    "l": () {
      var x = ((d.hour + 11) % 12 + 1).toString();

      if (x.length == 1) {
        x = " ${x}";
      }

      return x;
    },
    "M": () => tn(d.minute),
    "P": () => d.hour >= 12 ? "PM" : "AM",
    "r": () {
      var x = tn(((d.hour + 11) % 12 + 1));
      var y = tn(d.minute);
      var z = tn(d.second);
      var a = d.hour >= 12 ? "PM" : "AM";

      return "${x}:${y}:${z} ${a}";
    },
    "R": () {
      return "${tn(d.hour)}:${tn(d.minute)}";
    },
    "s": () => d.millisecondsSinceEpoch.toString(),
    "S": () => d.second.toString(),
    "T": () => "${tn(d.hour)}:${tn(d.minute)}:${tn(d.second)}"
  });
}
