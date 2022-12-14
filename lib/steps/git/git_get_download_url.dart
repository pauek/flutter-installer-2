import 'dart:io';

import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';

const version = "2.38.1";
const gitForWindowsURL = "https://github.com"
    "/git-for-windows/git/releases/download/"
    "v$version.windows.1/MinGit-$version-64-bit.zip";

class GitGetDownloadURL extends Step {
  GitGetDownloadURL() : super("Get Git download URL");

  @override
  Future run() async {
    if (Platform.isMacOS || Platform.isLinux) {
      return error("MacOS and Linux download of Git not implemented yet");
    }
    log.print("info: Git for Windows at '$gitForWindowsURL'.");
    return Future.value(URL(gitForWindowsURL));
  }
}
