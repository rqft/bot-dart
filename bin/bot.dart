import 'dart:io';

import 'package:cli/command.dart';
import 'package:cli/handler.dart';
import 'package:dotenv/dotenv.dart';
import 'package:nyxx/nyxx.dart';

final env = DotEnv()..load();
void main() async {
  final token = env['TOKEN']!;

  final allowedMentions = AllowedMentions()..allow(everyone: false);
  final clientOptions = ClientOptions(
      guildSubscriptions: false,
      shardCount: 1,
      allowedMentions: allowedMentions,
      messageCacheSize: 100);

  final ws = NyxxFactory.createNyxxWebsocket(
      token, GatewayIntents.allUnprivileged,
      options: clientOptions);

  final client = Handler(ws, prefix: '!');

  client.ws.eventsWs.onMessageReceived.listen((event) {
    if (event.message.content == ']]ext' &&
        event.message.author.id.id == 504698587221852172) {
      exit(0);
    }
    print(event.message.content);
  });

  final ping = Command(
      name: 'ping',
      run: (context) {
        context.reply(content: 'pong');
      });

  client.add(ping);

  client.ws.onReady.listen((_) {
    print("ok!");
  });

  await client.start();
}
