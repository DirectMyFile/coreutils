import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  var opts = handleArguments(args, "gid", handle: (parser) {
    parser.addFlag("groups", abbr: "G", help: "Display Group Ids");
  }, fail: (x) => x.rest.length > 1);

  var user = opts.rest.isEmpty ? SystemCalls.getUserName() : opts.rest[0];

  try {
    SystemCalls.getPasswordFileEntry(user);
  } catch (e) {
    error("Unknown User: ${user}");
  }

  if (opts["groups"]) {
    print(SystemCalls.getUserGroups(user).join(" "));
  } else {
    var mg = SystemCalls.getPasswordFileEntry(user);
    var n = mg["gid"];
    var l = "uid=${mg["uid"]}(${mg["name"]})";
    var m = "gid=${n}(${SystemCalls.getGroupNameForId(n)})";
    var others = SystemCalls.getUserGroups(user)
      .map((it) => "${it}(${SystemCalls.getGroupNameForId(it)})")
      .join(",");

    print("${l} ${m} groups=${others}");
  }
}
