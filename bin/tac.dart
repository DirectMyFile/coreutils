import "dart:async";
import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var opts = handleArguments(args, "tac");

  var paths = opts.rest;

  if (paths.isEmpty) {
    paths = ["-"];
  }

  for (var path in paths) {
    var file = new File(path == "-" ? "/dev/stdin" : path);
    var lines = await file.readAsLines();
    for (var line in lines.reversed) {
      stdout.writeln(line);
    }
  }
}

