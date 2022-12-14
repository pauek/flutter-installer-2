import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:path/path.dart';

class IsCmdlineToolsInstalled extends Step {
  IsCmdlineToolsInstalled() : super("See if cmdline-tools are missing");

  static final _rVersion = RegExp(r"^(?<version>[\d\.]+)");

  Future<String?> _getVersion(String exe) async {
    final result = await Process.run(exe, ["--version"], runInShell: true);
    final match = _rVersion.firstMatch(result.stdout.trim());
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: '${basename(exe)}' found, version '$version'.");
    }
    return version;
  }

  @override
  Future run() async {
    final androidTargetDir = join(ctx.targetDir, "android-sdk");
    final cmdlineToolsBinDir = join(
      androidTargetDir,
      "cmdline-tools",
      "latest",
      "bin",
    );
    if (await Directory(cmdlineToolsBinDir).exists()) {
      final sdkmanagerExe = join(cmdlineToolsBinDir, "sdkmanager.bat");
      final version = await _getVersion(sdkmanagerExe);
      if (version != null) {
        ctx.addBinary("sdkmanager", cmdlineToolsBinDir, "sdkmanager.bat");
        log.print("info: found cmdline-tools at '$cmdlineToolsBinDir");
        return true;
      }
    }
    log.print("info: cmdline-tools not found");
    return false;
  }
}
