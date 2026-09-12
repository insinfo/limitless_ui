// Static file server for the example's release build, written for the E2E
// suite: everything the browser asks for is served from memory, already
// gzipped, on keep-alive connections.
//
// `webdev serve` compiles with DDC and serves hundreds of small modules; a
// page load takes seconds, and the Puppeteer suite opens a fresh browser per
// test. A release build is one `main.dart.js`, and this server hands it out
// precompressed from RAM, so a page load is a handful of requests answered in
// milliseconds.
//
// Usage, from the repository root:
//
//   cd example && dart run build_runner build --release --output web:build --delete-conflicting-outputs && cd ..
//   dart run tool/serve_example.dart --dir example/build --port 8081
//
// Then, in another shell:
//
//   RUN_EXAMPLE_E2E=true UI_EXAMPLE_BASE_URL=http://127.0.0.1:8081 \
//     dart test ui_test/e2e/ -j 1
//
// The app uses hash routing, so no SPA fallback is needed: every route is
// `index.html` plus a fragment.
import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

const Map<String, String> _contentTypes = <String, String>{
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.map': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.webp': 'image/webp',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.eot': 'application/vnd.ms-fontobject',
  '.txt': 'text/plain; charset=utf-8',
  '.wasm': 'application/wasm',
  '.pdf': 'application/pdf',
  '.xml': 'application/xml; charset=utf-8',
};

/// Types worth compressing. Images and fonts are already compressed.
const Set<String> _compressible = <String>{
  '.html',
  '.js',
  '.mjs',
  '.css',
  '.json',
  '.map',
  '.svg',
  '.txt',
  '.xml',
};

/// One file, ready to be written to a socket.
class _Asset {
  _Asset({
    required this.plain,
    required this.gzipped,
    required this.contentType,
    required this.etag,
  });

  final List<int> plain;
  final List<int>? gzipped;
  final String contentType;
  final String etag;
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('dir',
        abbr: 'd',
        defaultsTo: 'example/build',
        help: 'Directory with the built site (index.html at its root).')
    ..addOption('port', abbr: 'p', defaultsTo: '8081')
    ..addOption('host',
        defaultsTo: '127.0.0.1',
        help: 'Interface to bind. Use 0.0.0.0 to reach it from other machines.')
    ..addFlag('quiet',
        abbr: 'q', help: 'Do not log each request.', negatable: false)
    ..addFlag('help', abbr: 'h', negatable: false);

  final ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }

  if (args['help'] as bool) {
    stdout.writeln('Serves a built web app from memory.\n');
    stdout.writeln(parser.usage);
    return;
  }

  final root = Directory(args['dir'] as String);
  if (!root.existsSync()) {
    stderr.writeln('Directory not found: ${root.path}');
    stderr.writeln(
        'Build it first: cd example && dart run build_runner build --release --output web:build --delete-conflicting-outputs');
    exitCode = 66;
    return;
  }
  if (!File('${root.path}${Platform.pathSeparator}index.html').existsSync()) {
    stderr.writeln('No index.html in ${root.path}.');
    exitCode = 66;
    return;
  }

  final quiet = args['quiet'] as bool;
  final port = int.tryParse(args['port'] as String);
  if (port == null) {
    stderr.writeln('Invalid port: ${args['port']}');
    exitCode = 64;
    return;
  }

  final stopwatch = Stopwatch()..start();
  final assets = await _loadAssets(root);
  final totalBytes = assets.values.fold<int>(0, (sum, a) => sum + a.plain.length);
  final gzipBytes = assets.values
      .fold<int>(0, (sum, a) => sum + (a.gzipped?.length ?? a.plain.length));
  stdout.writeln('Loaded ${assets.length} files from ${root.path} in '
      '${stopwatch.elapsedMilliseconds}ms '
      '(${_mb(totalBytes)} raw, ${_mb(gzipBytes)} to send).');

  final server = await HttpServer.bind(args['host'] as String, port);
  server.idleTimeout = const Duration(seconds: 60);
  stdout.writeln('Serving on http://${server.address.host}:${server.port}/');

  // Stop cleanly on Ctrl+C so the port is freed at once.
  final signals = <StreamSubscription<ProcessSignal>>[
    ProcessSignal.sigint.watch().listen((_) => _shutdown(server)),
  ];
  if (!Platform.isWindows) {
    signals.add(ProcessSignal.sigterm.watch().listen((_) => _shutdown(server)));
  }

  await for (final request in server) {
    _handle(request, assets, quiet: quiet);
  }
  for (final s in signals) {
    await s.cancel();
  }
}

void _shutdown(HttpServer server) {
  stdout.writeln('Stopping.');
  server.close(force: true);
}

/// Reads every file under [root] into memory, gzipping the ones worth it.
Future<Map<String, _Asset>> _loadAssets(Directory root) async {
  final assets = <String, _Asset>{};
  final rootPath = root.absolute.path;
  final codec = GZipCodec(level: 6);

  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) {
      continue;
    }
    final relative = entity.absolute.path
        .substring(rootPath.length)
        .replaceAll('\\', '/');
    final urlPath = relative.startsWith('/') ? relative : '/$relative';
    final extension = _extensionOf(urlPath);
    final bytes = await entity.readAsBytes();
    final compress = _compressible.contains(extension) && bytes.length > 1024;
    assets[urlPath] = _Asset(
      plain: bytes,
      gzipped: compress ? codec.encode(bytes) : null,
      contentType: _contentTypes[extension] ?? 'application/octet-stream',
      etag: '"${bytes.length.toRadixString(16)}-'
          '${entity.statSync().modified.millisecondsSinceEpoch.toRadixString(16)}"',
    );
  }
  return assets;
}

void _handle(HttpRequest request, Map<String, _Asset> assets,
    {required bool quiet}) {
  final response = request.response;
  var path = Uri.decodeComponent(request.uri.path);
  if (path.endsWith('/')) {
    path = '${path}index.html';
  }

  var asset = assets[path];
  // A directory asked for without the trailing slash.
  asset ??= assets['$path/index.html'];

  if (asset == null) {
    response.statusCode = HttpStatus.notFound;
    response.headers.contentType = ContentType.text;
    response.write('Not found: $path');
    response.close();
    _log(request, HttpStatus.notFound, 0, quiet: quiet);
    return;
  }

  if (request.method != 'GET' && request.method != 'HEAD') {
    response.statusCode = HttpStatus.methodNotAllowed;
    response.headers.set(HttpHeaders.allowHeader, 'GET, HEAD');
    response.close();
    _log(request, HttpStatus.methodNotAllowed, 0, quiet: quiet);
    return;
  }

  final headers = response.headers;
  headers.set(HttpHeaders.contentTypeHeader, asset.contentType);
  headers.set(HttpHeaders.etagHeader, asset.etag);
  // The build is immutable while this process lives, but a rebuild followed
  // by a restart has to reach the browser: revalidate, never cache blindly.
  headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
  headers.set(HttpHeaders.varyHeader, 'Accept-Encoding');
  // The app fetches nothing cross-origin, but a test page might.
  headers.set('Access-Control-Allow-Origin', '*');

  if (request.headers.value(HttpHeaders.ifNoneMatchHeader) == asset.etag) {
    response.statusCode = HttpStatus.notModified;
    response.close();
    _log(request, HttpStatus.notModified, 0, quiet: quiet);
    return;
  }

  final acceptsGzip =
      (request.headers.value(HttpHeaders.acceptEncodingHeader) ?? '')
          .contains('gzip');
  final body = acceptsGzip && asset.gzipped != null ? asset.gzipped! : asset.plain;
  if (identical(body, asset.gzipped)) {
    headers.set(HttpHeaders.contentEncodingHeader, 'gzip');
  }
  headers.contentLength = body.length;
  response.statusCode = HttpStatus.ok;
  if (request.method == 'GET') {
    response.add(body);
  }
  response.close();
  _log(request, HttpStatus.ok, body.length, quiet: quiet);
}

void _log(HttpRequest request, int status, int bytes, {required bool quiet}) {
  if (quiet) {
    return;
  }
  stdout.writeln('$status ${request.method} ${request.uri.path} ${_kb(bytes)}');
}

String _extensionOf(String path) {
  final slash = path.lastIndexOf('/');
  final dot = path.lastIndexOf('.');
  if (dot <= slash) {
    return '';
  }
  return path.substring(dot).toLowerCase();
}

String _mb(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

String _kb(int bytes) => bytes == 0 ? '' : '${(bytes / 1024).toStringAsFixed(0)} KB';
