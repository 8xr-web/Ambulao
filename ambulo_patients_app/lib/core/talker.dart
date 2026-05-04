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

  /// A global HTTP client that automatically logs all requests to Talker.
  static final httpClient = http.Client();

  // Note: Since 'http' package doesn't have an interceptor system like Dio,
  // we will manually log requests in our service methods or use a wrapper if needed.
  // For now, we provide the talker instance for manual logging.
}
