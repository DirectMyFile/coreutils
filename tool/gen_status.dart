import "dart:io";

main(List<String> args) async {
  if (!Platform.isMacOS) {
    print("ERROR: Mac OSX is the only supported OS for this script.");
    exit(1);
  }

  var gnu = getGnuTools();
  var ours = getOurTools();
  var missing = gnu.where((it) => !ours.contains(it)).toList();
  var extras = ours.where((it) => !gnu.contains(it)).toList();
  var buff = new StringBuffer();

  void w([String l = ""]) {
    buff.writeln(l);
  }

  if (extras.isNotEmpty) {
    w("## Added Coreutils");
    w();
    for (var e in extras) {
      w("- [x] ${e}");
    }
    w("");
  }

  w("## Original Coreutils");
  w("");
  for (var x in gnu) {
    if (missing.contains(x)) {
      w("- [ ] ${x}");
    } else {
      w("- [x] ${x}");
    }
  }

  if (args.contains("-w")) {
    var file = new File("README.md");
    var str = file.readAsStringSync();
    str = str.substring(0, str.indexOf("## Added Coreutils")) + buff.toString();
    file.writeAsStringSync(str);
  } else if (args.contains("-i")) {
    print("GNU: ${gnu}");
    print("Ours: ${ours}");
    print("Added: ${extras}");
    print("Missing: ${missing}");
  } else {
    stdout.writeln(buff.toString());
  }
}

List<String> getGnuTools() {
  List<String> tools = Process.runSync("brew", ["ls", "coreutils"]).stdout.split("\n");
  tools = tools.where((it) => it.contains("libexec/gnubin")).toList();
  tools = tools.map((it) => it.split("libexec/gnubin/").last).toList();
  return tools;
}

List<String> getOurTools() {
  List<String> tools = new Directory("bin").listSync().where((it) => it is File).map((it) => it.path.split("/").last).toList();
  tools = tools.map((it) => it.substring(0, it.indexOf(".dart"))).toList();
  return tools;
}
