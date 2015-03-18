import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var results = handleArguments(args, "cat", handle: (ArgParser parser) {
  });

  List<int> bytes;

  if (results.rest.isNotEmpty && (results.rest.length == 1 ? results.rest.first != "-" : false)) {
    bytes = new File(results.rest.join(" ")).readAsBytesSync();
  } else {
    bytes = readStdin();
  }

  stdout.write(new String.fromCharCodes(bytes));
}
