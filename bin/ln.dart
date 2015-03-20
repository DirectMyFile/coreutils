import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var opts = handleArguments(args, "ln", usage: "<source> <target>", handle: (parser) {
    parser.addFlag("symbolic", abbr: "s", help: "Make Symbolic Links", negatable: false);
    parser.addFlag("force", abbr: "f", help: "Force Creation", negatable: false);
  }, fail: (result) => result.rest.length != 2 || !result.options.any((it) => ["symbolic"].contains(it)));

  if (opts["symbolic"]) {
    var type = FileSystemEntity.typeSync(opts.rest[0]);
    if (type == FileSystemEntityType.NOT_FOUND) {
      print("ERROR: Source '${opts.rest[0]}' does not exist.");
      exit(1);
    }
    FileSystemEntity from = type == FileSystemEntityType.DIRECTORY ? new Directory(opts.rest[0]) : new File(opts.rest[0]);
    Link link = new Link(opts.rest[1]);

    if (link.existsSync()) {
      if (!opts["force"]) {
        print("ERROR: Target '${opts.rest[1]}' already exists.");
        exit(1);
      }

      link.deleteSync();
    }

    link.createSync(from.path);
  }
}
