import 'package:installer2/steps/add_binary.dart';
import 'package:installer2/steps/android-sdk/cmdline_tools_url.dart';
import 'package:installer2/steps/clone_github_repo.dart';
import 'package:installer2/steps/decompress.dart';
import 'package:installer2/steps/download_file.dart';
import 'package:installer2/steps/git/git_get_download_url.dart';
import 'package:installer2/steps/git/git_repository_missing.dart';
import 'package:installer2/steps/give_url.dart';
import 'package:installer2/steps/if.dart';
import 'package:installer2/steps/java/java_get_download_url.dart';
import 'package:installer2/steps/node/node_get_download_url.dart';
import 'package:installer2/steps/not_null.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';
import 'package:installer2/steps/nushell/nushell_download_url.dart';
import 'package:installer2/steps/rename.dart';
import 'package:installer2/steps/run_command.dart';
import 'package:installer2/steps/run_sdk_manager.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/version_installed.dart';

import '../lib/run_installer.dart';

const vscodeDownloadURL = "https://code.visualstudio.com"
    "/sha/download?build=stable&os=win32-x64-archive";

final installGit = Chain(
  name: "Git",
  steps: [
    GitGetDownloadURL(),
    DownloadFile(),
    Decompress(into: "git"),
  ],
);

final rGitVersion = RegExp(r"^git version (.*)$");
final installFlutter = Chain(
  name: "Flutter",
  steps: [
    If(
      NotNull(VersionInstalled("git", rGitVersion)),
      then: installGit,
    ),
    If(
      GitRepositoryMissing("flutter", flutterRepo),
      then: CloneGithubRepo("flutter", flutterRepo, branch: "stable"),
    ),
    AddBinaries("flutter", [
      Binary("flutter", win: "bin/flutter.bat", all: "bin/flutter"),
      Binary("dart", win: "bin/dart.bat", all: "bin/dart"),
    ]),
    RunCommand("dart", ["pub", "global", "activate", "flutterfire_cli"]),
  ],
);

final installNode = Chain(
  name: "Node",
  steps: [
    NodeGetDownloadURL(),
    DownloadFile(),
    Decompress(into: "node"),
    AddBinaries("node", [
      Binary("node", win: "node.exe", all: "bin/node"),
      Binary("npm", win: "npm.cmd", all: "bin/npm"),
    ]),
  ],
);

final installFirebaseCLI = Chain(
  name: "FirebaseCLI",
  steps: [
    installNode,
    RunCommand("npm", ["install", "-g", "firebase-tools"]),
  ],
);

final installVSCode = Chain(
  name: "VSCode",
  steps: [
    GiveURL(vscodeDownloadURL),
    DownloadFile("vscode.zip"),
    Decompress(into: "vscode"),
    AddBinaries("vscode", [
      Binary("code", win: "bin/code.cmd", all: "code"),
    ])
  ],
);

final rJavaVersion = RegExp(r"^java (.*)$");

final installJava = If(
  NotNull(
    VersionInstalled("java", rJavaVersion),
  ),
  then: Chain(
    name: "Java",
    steps: [
      JavaGetDownloadURL(),
      DownloadFile(),
      Decompress(into: "java"),
      AddBinaries("java", [
        Binary("java", all: "bin/java"),
      ])
    ],
  ),
);

final installAndroidSDK = Chain(
  name: "Android SDK",
  steps: [
    installJava,
    GetAndroidCmdlineToolsURL(),
    DownloadFile(),
    Decompress(into: "android-sdk/cmdline-tools"),
    Rename(from: "cmdline-tools", to: "latest"),
    AddBinaries("android-sdk", [
      Binary(
        "sdkmanager",
        win: "cmdline-tools/latest/bin/sdkmanager.bat",
        all: "cmdline-tools/latest/bin/sdkmanager",
      ),
      Binary(
        "avdmanager",
        win: "cmdline-tools/latest/bin/avdmanager.bat",
        all: "cmdline-tools/latest/bin/avdmanager",
      ),
    ]),
    RunSdkManager([
      "platforms;android-33",
      "build-tools;33.0.1",
      "platform-tools",
    ]),
  ],
);

final installNushell = Chain(
  name: "Nushell",
  steps: [
    GetNushellDownloadURL(),
    DownloadFile(),
    Decompress(into: "nu"),
  ],
);

void main(List<String> arguments) {
  runInstaller(
    Chain(steps: [
      Parallel([
        installFlutter,
        installVSCode,
        installFirebaseCLI,
        installAndroidSDK,
        installNushell,
      ]),
      ConfigureNushell(),
    ]),
  );
}
