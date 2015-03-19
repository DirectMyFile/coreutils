import "package:coreutils/coreutils.dart";

main(List<String> args) {
  var opts = handleArguments(args, "yes");

  var m = "y";

  if (opts.rest.isNotEmpty) {
    m = opts.rest.join(" ");
  }

  while (true) {
    print(m);
  }
}
