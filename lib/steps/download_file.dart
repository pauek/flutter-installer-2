import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class DownloadFile extends SinglePriorStep<Filename, URL> {
  String? forcedFilename;
  DownloadFile([this.forcedFilename]);

  @override
  Future<Filename> run() async {
    final url = await input;
    final urlPath = Uri.parse(url.value).path;
    final filename = forcedFilename ?? basename(urlPath);
    show("Downloading $filename...");
    log.print("Downloading '$filename' from '${url.value}'");
    final absFilename = join(ctx.downloadDir, filename);
    if (await downloadFile(url.value, absFilename)) {
      log.print("Downloaded successfully at '$absFilename'");
    } else {
      log.print("Error downloading file '${url.value}'");
      throw "Error downloading '${url.value}'";
    }
    return Filename(absFilename);
  }
}
