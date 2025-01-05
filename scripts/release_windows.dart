import "dart:convert";
import "dart:io";
import "dart:typed_data";

void main() async {
  Logger logger = Logger();

  logger.cmd("Reading .env file");
  Map<String, String> env = await loadEnvFile('./.env');
  String ghToken = env['GH_TOKEN'] ?? '';
  if (ghToken == '') {
    logger.error("GH Token is invalid");
    return;
  }

  logger.cmd("Getting app version from pubspec.yaml");
  String appVersion = await getVersionFromPubspec('./pubspec.yaml');
  String cleanAppVersion = appVersion.replaceAll(RegExp(r'\+'), '_');
  String tagName = "internal-$cleanAppVersion";

  logger.cmd("Getting latest release info");
  Map<String, String> customHeaders = {
    HttpHeaders.acceptHeader: 'application/vnd.github+json',
    HttpHeaders.authorizationHeader: 'Bearer $ghToken',
    HttpHeaders.userAgentHeader: 'cards-windows-release',
    'X-Github-Api-Version': '2022-11-28',
  };
  String releaseResJson = await sendGetRequest(
      'https://api.github.com/repos/toxdes/cards/releases/tags/$tagName',
      customHeaders,
      logger);
  Map<String, dynamic> releaseRes = jsonDecode(releaseResJson);
  int releaseId = releaseRes['id'];
  logger.info("Release ID: $releaseId");

  logger.cmd("Activating flutter_distributor");
  ProcessResult res = Process.runSync(
      "dart", ['pub', 'global', 'activate', 'flutter_distributor']);
  logger.info("${res.stdout}");
  if (res.stderr?.length > 0) {
    logger.error("${res.stderr}");
  }
  String? homeDir = Platform.environment['USERPROFILE'];
  if (homeDir == null) {
    logger.error("Couldn't get home directorhy");
    return;
  }
  logger.info("Home: $homeDir");

  logger.cmd("Building windows exe");
  res = Process.runSync(
      "$homeDir\\AppData\\Local\\Pub\\Cache\\bin\\flutter_distributor.bat",
      ['release', '--name=dev', '--jobs=release-windows-exe']);

  if (res.stderr?.length > 0) {
    logger.error("${res.stderr}");
  }
  logger.info("exe generated");

  logger.cmd("Uploading exe to GH");
  String exeFilePath =
      './dist/$appVersion/cards-$appVersion-windows-setup.exe';
  String uploadUrl =
      'https://uploads.github.com/repos/toxdes/cards/releases/$releaseId/assets?name=cards-$cleanAppVersion-windows-setup.exe&label=cards-$cleanAppVersion-windows-setup.exe';

  File exeFile = File(exeFilePath);
  Uint8List bytes = exeFile.readAsBytesSync();
  customHeaders = {
    HttpHeaders.acceptHeader: 'application/vnd.github+json',
    HttpHeaders.authorizationHeader: 'Bearer $ghToken',
    'X-Github-Api-Version': '2022-11-28',
    HttpHeaders.contentTypeHeader: "application/octet-stream",
    HttpHeaders.contentLengthHeader: "${bytes.length}"
  };
  await sendPostRequest(uploadUrl, bytes, customHeaders, logger);
  logger.info("Uploaded: cards-$cleanAppVersion-windows-setup.exe");
}

class Logger {
  void info(String message) {
    _pr('[INFO] $message');
  }

  void cmd(String message) {
    _pr('[CMD] $message');
  }

  void error(String message) {
    _pr('[ERROR] $message');
  }

  void _pr(String message) {
    print(message);
  }
}

Future<Map<String, String>> loadEnvFile(String filePath) async {
  final file = File(filePath);

  if (!await file.exists()) {
    throw Exception('Environment file not found: $filePath');
  }

  final lines = await file.readAsLines();
  final envMap = <String, String>{};

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    line = line.replaceFirst(RegExp(r'^export\s+'), '');

    final commentIndex = line.indexOf('#');
    if (commentIndex != -1) {
      final quoteCount =
          RegExp(r'"').allMatches(line.substring(0, commentIndex)).length;
      if (quoteCount % 2 == 0) {
        line = line.substring(0, commentIndex).trim();
      }
    }

    final separatorIndex = line.indexOf('=');
    if (separatorIndex == -1) continue;

    final key = line.substring(0, separatorIndex).trim();
    final value = line.substring(separatorIndex + 1).trim();

    final cleanedValue =
        value.replaceAll(RegExp(r'^"|"$'), '').replaceAll(RegExp(r"^'|'$"), '');
    envMap[key] = cleanedValue;
  }

  return envMap;
}

Future<String> sendPostRequest(
  String url,
  Uint8List requestBody,
  Map<String, String> headers,
  Logger logger,
) async {
  final httpClient = HttpClient();
  final uri = Uri.parse(url);

  try {
    // Create a POST request
    final request = await httpClient.postUrl(uri);

    // Set provided custom headers
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    // Set the content type header for JSON payload (can be overridden by the user)
    if (!headers.containsKey(HttpHeaders.contentTypeHeader)) {
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    }

    // Set the body of the request
    request.add(requestBody);

    // Send the request and get the response
    final response = await request.close();

    // Read the response
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger.info('Request succeeded with status: ${response.statusCode}');
      return responseBody;
    } else {
      throw Exception(
          'Request failed with status code ${response.statusCode}: $responseBody');
    }
  } catch (e) {
    logger.error('Error: $e');
    rethrow;
  } finally {
    httpClient.close();
  }
}

Future<String> sendGetRequest(
    String url, Map<String, String> headers, Logger logger) async {
  final httpClient = HttpClient();
  final uri = Uri.parse(url);

  try {
    // Create a GET request
    final request = await httpClient.getUrl(uri);

    // Set provided custom headers
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    // Send the request and get the response
    final response = await request.close();

    // Read the response
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger.info('Request succeeded with status: ${response.statusCode}');
      return responseBody;
    } else {
      throw Exception(
          'Request failed with status code ${response.statusCode}: $responseBody');
    }
  } catch (e) {
    logger.error('Error: $e');
    rethrow;
  } finally {
    httpClient.close();
  }
}

Future<String> getVersionFromPubspec(String filePath) async {
  final file = File(filePath);

  if (!await file.exists()) {
    throw Exception('pubspec.yaml not found');
  }

  final content = await file.readAsString();
  final versionPattern = RegExp(r'^version:\s*(\S+)', multiLine: true);

  final match = versionPattern.firstMatch(content);

  if (match != null) {
    return match.group(1)!; // Return the version value
  } else {
    throw Exception('Version not found in pubspec.yaml');
  }
}
