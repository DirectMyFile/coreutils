import "dart:io";

import "package:coreutils/coreutils.dart";
import "package:path/path.dart" as pathlib;

main(List<String> args) {
  var results = handleArguments(args, "cp", usage: "<source> <destination>", handle: (ArgParser parser) {
    parser.addFlag("recursive", abbr: "R", help: "Recursive Copy");
  }, fail: (result) => result.rest.length != 2);

  var sp = results.rest[0];
  var tp = results.rest[1];
  var st = FileSystemEntity.typeSync(sp);

  if (st == FileSystemEntityType.NOT_FOUND) {
    print("ERROR: Source '${sp}' does not exist.");
    exit(1);
  }

  if (st == FileSystemEntityType.DIRECTORY && !results["recursive"]) {
    print("ERROR: Source is a directory, but recursive copying is not enabled.");
    exit(1);
  }

  var fp = tp;

  if (!results["recursive"]) {
    if (st == FileSystemEntityType.DIRECTORY) {
      fp = tp + pathlib.basename(sp);
    }

    var sf = new File(sp);
    var tf = new File(fp);

    sf.copySync(tf.path);
  } else {
    var sd = new Directory(sp);
    var td = new Directory(fp);

    if (!td.parent.existsSync()) {
      print("ERROR: Target directory's parent does not exist.");
      exit(1);
    }

    if (!td.existsSync()) {
      td.createSync();
    }

    for (var f in sd.listSync(recursive: true)) {
      var p = td.path + f.path.replaceAll(sd.path, "");
      if (f is File) {
        f.copySync(p);
      } else {
        new Directory(p).createSync(recursive: true);
      }
    }
  }
}
