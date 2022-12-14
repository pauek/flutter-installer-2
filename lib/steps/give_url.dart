import 'package:installer2/steps/step.dart';
import 'package:installer2/steps/types.dart';

class GiveURL extends Step {
  String url;
  GiveURL(this.url) : super("Give URL $url");

  @override
  Future run() => Future.value(URL(url));
}
