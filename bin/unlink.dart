import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var opts = handleArguments(args, "unlink", usage: "<path>", fail: (opts) => opts.rest.length != 1);
  var path = opts.rest[0];
  var link = new Link(path);

  if (!(await link.exists())) {
    error("Link does not exist.");
  }

  await link.delete();
}
