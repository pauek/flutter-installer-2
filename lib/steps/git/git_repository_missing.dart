import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class GitRepositoryMissing extends Step<bool> {
  final String dir, repoUrl;
  GitRepositoryMissing(this.dir, this.repoUrl);

  @override
  Future<bool> run() async {
    return await withMessage(
      "Checking if git repository is present",
      () async {
        final flutterDir = join(ctx.targetDir, dir);
        final remote = await getGitRemote(flutterDir);
        final missing = remote == null || remote != repoUrl;
        if (missing) {
          log.print("Git repository '$repoUrl' missing at '$dir'");
          return false;
        } else {
          log.print("Git repository '$repoUrl' found at '$dir'");
          return true;
        }
      },
    );
  }
}
