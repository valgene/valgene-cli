import 'package:valgene_cli/valgene_cli.dart';

void main(List<String> arguments) {
  final cli = Cli(arguments);
  if (cli.isValid()) {
    cli.execute();
    return;
  }
  cli.showUsage();
}
