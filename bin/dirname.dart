import "package:coreutils/coreutils.dart";
import "package:path/path.dart" as pathlib;

main(List<String> args) {
  handleArguments(args, "dirname", usage: "<path>", fail: (result) => result.rest.length != 1);

  var path = args[0];
  print(pathlib.dirname(path));
}
