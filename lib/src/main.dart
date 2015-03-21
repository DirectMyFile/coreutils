part of coreutils;

ArgResults handleArguments(List<String> args, String tool, {bool fail(ArgResults result), void handle(ArgParser parser), String usage}) {
  toolName = tool;
  var argp = new ArgParser();

  argp.addFlag("help", abbr: "h", negatable: false, help: "Displays this Help Message");
  argp.addFlag("version", abbr: "v", negatable: false, help: "Display Version");

  if (handle != null) {
    handle(argp);
  }

  ArgResults result;

  void printHelp() {
    print("Usage: ${tool} [options]${usage != null ? " ${usage}" : ""}");
    if (argp.usage.isNotEmpty) {
      print(argp.usage);
    }
    exit(1);
  }

  try {
    result = argp.parse(args);
  } on FormatException catch (e) {
    print("ERROR: ${e}");
    printHelp();
  }

  if (result["help"]) {
    printHelp();
  }

  if (result["version"]) {
    print("${tool} v${VERSION}");
    exit(0);
  }

  if (fail != null && fail(result)) {
    printHelp();
  }

  return result;
}

void init() {
  SystemCalls.init();
}

void error(String msg, {bool exit: true, int exitCode: 1}) {
  print("ERROR: ${msg}");
  if (exit) {
    IOUtils.exit(exitCode);
  }
}
