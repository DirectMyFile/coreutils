import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var results = handleArguments(args, "base64", handle: (ArgParser parser) {
    parser.addFlag("decode", abbr: "d", help: "Decode Base64");
  });

  List<int> bytes;

  if (results.rest.isNotEmpty && (results.rest.length == 1 ? results.rest.first != "-" : false)) {
    bytes = new File(results.rest.join(" ")).readAsBytesSync();
  } else {
    bytes = await readStdin();
  }

  if (results["decode"]) {
    stdout.write(new String.fromCharCodes(decodeBase64(new String.fromCharCodes(bytes))));
  } else {
    stdout.write(encodeBase64(bytes));
  }

  exit(0);
}
