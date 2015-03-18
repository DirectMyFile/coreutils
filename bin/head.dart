import "dart:io";
import "dart:convert";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var opts = handleArguments(args, "head", usage: "<path>", handle: (ArgParser parser) {
    parser.addOption("lines", abbr: "n", defaultsTo: "10", help: "Read the specified number of lines of the file.");
  }, fail: (result) => result.rest.length > 1);

  var path = args.isEmpty ? "-" : args[0];
  var file = new File(path == "-" ? "/dev/stdin" : path);
  var f = file.openSync(mode: FileMode.READ);

  if (!opts.options.contains("bytes")) {
    var nl = int.parse(opts["lines"], onError: (src) => null);

    if (nl == null) {
      print("Invalid Number Argument.");
      exit(1);
    }

    var count = 1;
    var buff = [];
    var newline = UTF8.encode("\n").first;

    while (count <= nl) {
      var b = f.readByteSync();

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

    f.closeSync();
  } else {
    var bl = int.parse(opts["bytes"], onError: (src) => null);

    if (bl == null) {
      print("Invalid Number Argument.");
      exit(1);
    }

    stdout.add(f.readSync(bl));
    f.closeSync();
  }
}
