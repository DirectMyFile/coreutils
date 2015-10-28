import "dart:io";

import "package:coreutils/coreutils.dart";

main(List<String> args) {
  init();

  var opts = handleArguments(args, "gid", handle: (parser) {
    parser.addFlag("groups", abbr: "G", help: "Display Group Ids");
  }, fail: (x) => x.rest.length > 1);

  var user = opts.rest.isEmpty ? getCurrentUsername() : opts.rest[0];

  try {
    getPasswordFileEntry(user);
  } catch (e) {
    error("Unknown User: ${user}");
  }

  if (opts["groups"]) {
    print(getUserGroups(user).join(" "));
  } else {
    var mg = getPasswordFileEntry(user);
    var n = mg["gid"];
    var l = "uid=${mg["uid"]}(${mg["name"]})";
    var m = "gid=${n}(${getGroupInfo(n).name})";
    var others = getUserGroups(user)
      .map((it) => "${it}(${getGroupInfo(it).name})")
      .join(",");

    print("${l} ${m} groups=${others}");
  }
}
