// ignore_for_file: prefer_initializing_formals

import 'package:cli/handler.dart';
import 'package:nyxx/nyxx.dart';

class CommandContext<T> {
  late List<String> raw;
  late IMessage message;
  late Handler handler;

  late Snowflake userId;
  late IMessageAuthor user;

  late Snowflake? guildId;
  late IGuild? guild;

  late Snowflake channelId;
  late IChannel channel;

  CommandContext(
      {required List<String> args,
      required IMessage message,
      required Handler handler,
      required Command command}) {
    raw = args;
    this.message = message;
    userId = message.author.id;
    user = message.author;
    channelId = message.channel.id;
    channel = message.channel;

    if (message.guild != null) {
      guild = message.guild?.getFromCache();
      guildId = guild?.id;
    }
  }

  reply({
    String? content,
    EmbedBuilder? embed,
    ReplyBuilder? replyBuilder,
    List<AttachmentBuilder>? files,
    List<AttachmentMetadataBuilder>? attachments,
  }) {
    final builder = MessageBuilder();
    if (content != null) {
      builder.content = content;
    }

    if (embed != null) {
      builder.addEmbed(((_) => embed));
    }

    if (replyBuilder != null) {
      builder.replyBuilder = replyBuilder;
    }

    if (files != null) {
      builder.files = files;
    }

    if (attachments != null) {
      builder.attachments = attachments;
    }

    return message.channel.sendMessage(builder);
  }

  arg(Map<String, Arg> args) {
    Map<String, dynamic> output = {};

    // iterate over all args
    var i = 0;

    for (final entry in args.entries) {
      final key = entry.key;
      final arg = entry.value;

      final given = raw[i];

      // check if arg is required
      if (arg.required) {
        throw Exception('Argument $key is required');
      }

      // check if arg is of correct type
      // todo: implement

      // add arg to output
      output[key] = given;
      i++;
    }

    return output as T;
  }
}

typedef CommandRun = void Function(
  CommandContext context,
);

abstract class Metadata {
  String? description;
}

enum ArgType {
  string,
  int,
  bool,
  user,
  channel,
  guild,
  role,
}

abstract class Arg {
  late ArgType type;
  late bool required;
}

class Command<T> {
  late String name;
  late List<String> aliases = [];
  late Metadata? metadata;
  late CommandRun run;
  late Map<String, Arg> args = {};

  Command(
      {required String name,
      List<String>? aliases,
      Metadata? metadata,
      Map<String, Arg>? predicate,
      required CommandRun run}) {
    this.name = name;
    if (aliases != null) {
      this.aliases = aliases;
    }
    this.metadata = metadata;
    this.run = run;
    if (predicate != null) {
      args = predicate;
    }
  }
}
