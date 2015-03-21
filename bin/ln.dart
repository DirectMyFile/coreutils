import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var opts = handleArguments(args, "ln", usage: "<source> <target>", handle: (parser) {
    parser.addFlag("symbolic", abbr: "s", help: "Make Symbolic Links", negatable: false);
    parser.addFlag("force", abbr: "f", help: "Force Creation", negatable: false);
  }, fail: (result) => result.rest.length != 2 || !result.options.any((it) => ["symbolic"].contains(it)));

  if (opts["symbolic"]) {
    var type = await FileSystemEntity.type(opts.rest[0]);
    if (type == FileSystemEntityType.NOT_FOUND) {
      error("Source '${opts.rest[0]}' does not exist.");
    }
    FileSystemEntity from = type == FileSystemEntityType.DIRECTORY ? new Directory(opts.rest[0]) : new File(opts.rest[0]);
    Link link = new Link(opts.rest[1]);

    if (link.existsSync()) {
      if (!opts["force"]) {
        error("Target '${opts.rest[1]}' already exists.");
      }

      await link.delete();
    }

    await link.create(from.path);
  }
}
