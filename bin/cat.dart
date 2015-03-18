import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var results = handleArguments(args, "cat", handle: (ArgParser parser) {});
  var paths = results.rest;

  if (paths.isEmpty) {
    paths = ["-"];
  }

  for (var path in paths) {
    List<int> bytes;

    if (path != "-") {
      bytes = new File(path).readAsBytesSync();
    } else {
      bytes = readStdin();
    }

    stdout.write(new String.fromCharCodes(bytes));
  }
}
