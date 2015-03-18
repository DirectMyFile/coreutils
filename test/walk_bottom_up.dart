import "dart:io";
import "package:coreutils/coreutils.dart";

void main() {
  var items = walkTreeBottomUp(Directory.current);
  print(items.map((it) => it.path).join("\n"));
}
