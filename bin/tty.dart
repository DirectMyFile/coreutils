import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  var opts = handleArguments(args, "tty", fail: (result) => result.rest.isNotEmpty, handle: (ArgParser parser) {
    parser.addFlag("silent", abbr: "s", help: "Silence", negatable: false);
    parser.addFlag("quiet", help: "Silence", negatable: false, hide: true);
  });

  var name = getTtyName();

  if (name == null) {
    if (!opts["silent"] && !opts["quiet"]) {
      print("not a tty");
    }

    exit(1);
  } else {
    if (!opts["silent"] && !opts["quiet"]) {
      print(name);
    }
    exit(0);
  }
}
