import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_http_logger/talker_http_logger.dart';
import 'package:http/http.dart' as http;

class DebugLogger {
  static final talker = TalkerFlutter.init(
    settings: TalkerSettings(
      maxHistoryItems: 100,
      useConsoleLogs: true,
    ),
  );

  static final httpLogger = TalkerHttpLogger(talker: talker);

  static final httpClient = http.Client();
}
