import "dart:io";
import "package:coreutils/coreutils.dart";

main() async {
  var items = await walkTreeBottomUp(Directory.current);
  print(items.map((it) => it.path).join("\n"));
}
