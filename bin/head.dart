import "dart:io";
import "dart:convert";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var opts = handleArguments(args, "head", usage: "<path>", handle: (ArgParser parser) {
    parser.addOption("lines", abbr: "n", defaultsTo: "10", help: "Read the specified number of lines of the file.");
  }, fail: (result) => result.rest.length > 1);

  var path = args.isEmpty ? "-" : args[0];
  var file = new File(path == "-" ? "/dev/stdin" : path);
  RandomAccessFile f = await file.open(mode: FileMode.READ);

  if (!opts.options.contains("bytes")) {
    var nl = int.parse(opts["lines"], onError: (src) => null);

    if (nl == null) {
      error("Invalid Number Argument.");
    }

    var count = 1;
    var buff = [];
    var newline = UTF8.encode("\n").first;

    while (count <= nl) {
      var b = await f.readByte();

      if (b == -1) {
        if (buff.isNotEmpty) {
          var str = UTF8.decode(buff);
          stdout.write(str);
        }
        buff.clear();
        break;
      } else if (b == newline) {
        var str = UTF8.decode(buff);
        stdout.writeln(str);
        buff.clear();
        count++;
      } else {
        buff.add(b);
      }
    }

    await f.close();
  } else {
    var bl = int.parse(opts["bytes"], onError: (src) => null);

    if (bl == null) {
      error("Invalid Number Argument.");
    }

    stdout.add(await f.read(bl));
    await f.close();
  }
}
