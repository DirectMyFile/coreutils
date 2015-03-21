import "package:coreutils/coreutils.dart";

main(List<String> args) async {
  init();

  handleArguments(args, "logname", fail: (result) => result.rest.isNotEmpty);

  print(SystemCalls.getUserName());
}
