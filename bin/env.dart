import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  var opts = handleArguments(args, "env");
  var parts = opts.rest.takeWhile((it) => it.contains("=")).toList();

  var hasCommand = opts.rest.length != parts.length && opts.rest.isNotEmpty;

  var env = new Map.from(Platform.environment);
  for (var x in parts) {
    var name = x.substring(0, x.indexOf("="));
    var value = x.substring(x.indexOf("=") + 1);

    env[name] = value;
  }

  if (!hasCommand) {
    var out = env.keys.map((it) => "${it}=${env[it]}").join("\n");
    print(out);
  } else {
    var cmd = opts.rest.sublist(parts.length);
    var exe = cmd.first;
    cmd = cmd.sublist(1);

    Process process = await Process.start(exe, cmd, workingDirectory: Directory.current.path, environment: env, runInShell: true);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    process.stdin.addStream(stdin);
    var code = await process.exitCode;
    exit(code);
  }
}
