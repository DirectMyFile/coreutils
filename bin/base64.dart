import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var results = handleArguments(args, "base64", handle: (ArgParser parser) {
    parser.addFlag("decode", abbr: "d", help: "Decode Base64");
  });

  List<int> bytes;

  if (results.rest.isNotEmpty) {
    bytes = new File(results.rest.join(" ")).readAsBytesSync();
  } else {
    bytes = readStdin();
  }

  if (results["decode"]) {
    print(new String.fromCharCodes(decodeBase64(new String.fromCharCodes(bytes))));
  } else {
    print(encodeBase64(bytes));
  }

  exit(0);
}
