import "package:coreutils/coreutils.dart";

main(List<String> args) {
  handleArguments(args, "arch");

  var u = getKernelInfo();

  print(u.machine);
}
