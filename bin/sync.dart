import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  handleArguments(args, "sync");

  SystemCalls.sync();
}
