import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  var opts = handleArguments(args, "touch", usage: "<file>", fail: (opts) => opts.rest.isEmpty);
  var files = opts.rest;

  for (var f in files) {
    var file = new File(f);

    if (file.existsSync()) {
      file.writeAsBytesSync(file.readAsBytesSync());
    } else {
      file.createSync();
    }
  }
}
