import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var opts = handleArguments(args, "seq", usage: "[first] [increment] <last>", fail: (result) {
    return result.rest.isEmpty || result.rest.length > 3;
  });

  String starts = opts.rest.length >= 2 ? opts.rest[0] : "1";
  String increments = opts.rest.length == 3 ? opts.rest[1] : "1";
  String ends;

  if (opts.rest.length == 1) {
    ends = opts.rest[0];
  } else if (opts.rest.length == 2) {
    ends = opts.rest[1];
  } else {
    ends = opts.rest[2];
  }

  var start = getSeqNumber(starts);
  var increment = getSeqNumber(increments);
  var end = getSeqNumber(ends);

  for (var i = start; i <= end; i += increment) {
    print(i);
  }
}

int getSeqNumber(String str) {
  var d = double.parse(str, (source) => null);

  if (d == null) {
    print("ERROR: Invalid Number: ${str}");
    exit(1);
  }

  return d.toInt();
}
