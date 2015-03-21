import "dart:io";

import "package:coreutils/coreutils.dart";
import "package:path/path.dart" as pathlib;

main(List<String> args) async {
  var opts = handleArguments(args, "cp", usage: "<sources> <destination>", handle: (ArgParser parser) {
    parser.addFlag("recursive", abbr: "R", help: "Recursive Copy");
  }, fail: (result) => result.rest.length < 2);

  var tp = opts.rest.last;
  var tt = await FileSystemEntity.type(tp);

  var sources = opts.rest.sublist(0, opts.rest.length - 1);
  for (var sp in sources) {
    var st = await FileSystemEntity.type(sp);

    if (st == FileSystemEntityType.NOT_FOUND) {
      error("Source '${sp}' does not exist.");
    }

    if (st == FileSystemEntityType.DIRECTORY && !opts["recursive"]) {
      error("Source is a directory, but recursive copying is not enabled.");
    }

    var fp = tp;

    if (!opts["recursive"]) {
      if (tt == FileSystemEntityType.DIRECTORY) {
        fp = tp + pathlib.basename(sp);
      }

      var sf = new File(sp);
      var tf = new File(fp);

      sf.copySync(tf.path);
    } else {
      var sd = new Directory(sp);
      var td = new Directory(fp);

      if (!td.parent.existsSync()) {
        error("Target directory's parent does not exist.");
      }

      if (!(await td.exists())) {
        await td.create();
      }

      for (var f in sd.listSync(recursive: true)) {
        var p = td.path + f.path.replaceAll(sd.path, "");
        if (f is File) {
          await f.copy(p);
        } else {
          await new Directory(p).create(recursive: true);
        }
      }
    }
  }
}
