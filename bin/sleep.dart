import "dart:async";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var result = handleArguments(args, "sleep", usage: "<time>", fail: (result) => result.rest.length != 1);
  var tstr = result.rest[0];

  var unit = {
    "s": 1,
    "m": 60,
    "h": 120,
    "d": 86400
  }[tstr[tstr.length - 1]];

  if (unit == null) {
    unit = 1;
  } else {
    tstr = tstr.substring(0, tstr.length - 1);
  }

  try {
    var f = int.parse(tstr);

    var seconds = f * unit;
    await new Future.delayed(new Duration(seconds: seconds));
  } on FormatException {
    error("Invalid Time");
  }
}
