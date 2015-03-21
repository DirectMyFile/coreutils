import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var opts = handleArguments(args, "touch", usage: "<files>", fail: (opts) => opts.rest.isEmpty);
  var files = opts.rest;

  for (var f in files) {
    var file = new File(f);

    if (await file.exists()) {
      await file.writeAsBytes(await file.readAsBytes());
    } else {
      await file.create();
    }
  }
}
