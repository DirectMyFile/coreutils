import "dart:io";

import "package:coreutils/coreutils.dart";

void main(List<String> args) {
  var opts = handleArguments(args, "printenv", usage: "[variables]");
  var env = Platform.environment;

  if (opts.rest.isEmpty) {
    var out = env.keys.map((it) => "${it}=${env[it]}").join("\n");
    print(out);
  } else {
    var x = 0;
    opts.rest.forEach((x) {
      if (!env.containsKey(x)) {
        x = 1;
      } else {
        print("${env[x]}");
      }
    });
  }
}
