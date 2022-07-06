import 'package:cli/command.dart';
import 'package:nyxx/nyxx.dart';

class Handler {
  late INyxxWebsocket ws;
  List<String> prefixes = [];

  Handler(this.ws, {String? prefix, List<String>? prefixes}) {
    if (prefix != null) {
      this.prefixes.add(prefix);
    }
    if (prefixes != null) {
      this.prefixes.addAll(prefixes);
    }
  }

  List<Command> commands = [];

  Future<void> start() async {
    ws.eventsWs.onMessageReceived.listen((event) => {handle(event.message)});
    await ws.connect();
  }

  RegExp get prefixMatcher =>
      RegExp('^(?<prefix>${prefixes.map((p) => RegExp.escape(p)).join('|')})');

  void handle<T>(IMessage message) {
    print("handling");
    var content = message.content;

    final usedPrefix = prefixMatcher.firstMatch(content)?.namedGroup('prefix');
    print("usedPrefix: $usedPrefix");
    if (usedPrefix == null) {
      return;
    }

    content = content.substring(usedPrefix.length);
    print("content: $content");

    final command = commands.firstWhereSafe((c) => c.name == content);
    print("command: $command");

    if (command == null) {
      return;
    }

    final context = CommandContext(
        args: content.split(r'\s+'),
        message: message,
        handler: this,
        command: command);

    command.run(context);
  }

  Command find(String attribute) {
    return commands.firstWhere((command) =>
        command.name.toLowerCase() == attribute.toLowerCase() ||
        command.aliases
            .map((e) => e.toLowerCase())
            .contains(attribute.toLowerCase()));
  }

  Handler add(Command command) {
    commands.add(command);
    return this;
  }
}
