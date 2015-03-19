import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  handleArguments(args, "whoami", fail: (result) => result.rest.isNotEmpty);

  print(SystemCalls.getUserName());
}
