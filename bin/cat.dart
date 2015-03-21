import "dart:async";
import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var opts = handleArguments(args, "cat", handle: (ArgParser parser) {
    parser.addFlag("number", abbr: "n", help: "Display Line Numbers", negatable: false);
  });

  var paths = opts.rest;

  if (paths.isEmpty) {
    paths = ["-"];
  }

  for (var path in paths) {
    Stream<List<int>> stream;

    if (path == "-") {
      stream = stdin;
    } else {
      stream = new File(path).openRead();
    }

    var line = 0;

    await stream.listen((data) {
      if (opts["number"] && data.last == newline) {
        line++;
        stdout.write("     ${line} ");
      }

      stdout.add(data);
    }).asFuture();
  }
}

int newline = "\n".codeUnitAt(0);
