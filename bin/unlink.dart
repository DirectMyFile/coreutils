import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var opts = handleArguments(args, "unlink", usage: "<path>", fail: (opts) => opts.rest.length != 1);
  var path = opts.rest[0];
  var link = new Link(path);

  if (!link.existsSync()) {
    print("ERROR: Link does not exist.");
    exit(1);
  }

  link.deleteSync();
}
