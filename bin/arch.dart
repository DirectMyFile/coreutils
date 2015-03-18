import "package:coreutils/coreutils.dart";
import "package:system_info/system_info.dart";

main(List<String> args) {
  handleArguments(args, "arch");

  print(getSystemArch());
}

String getSystemArch() {
  return SysInfo.kernelArchitecture;
}

