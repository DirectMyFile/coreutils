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
  var tt = FileSystemEntity.typeSync(tp);

  if (st == FileSystemEntityType.NOT_FOUND) {
    print("ERROR: '${sp}' does not exist.");
    exit(1);
  }

  if (st == FileSystemEntityType.DIRECTORY) {
    print("ERROR: Directories are not supported yet.");
  }

  var fp = tp;

  if (st == FileSystemEntityType.DIRECTORY) {
    fp = tp + pathlib.basename(sp);
  }

  var sf = new File(sp);
  var tf = new File(fp);

  sf.copySync(tf.path);
}
