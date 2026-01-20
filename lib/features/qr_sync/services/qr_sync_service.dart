import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;

class QrSyncService {
  HttpServer? _server;
  String? _ipAddress;
  final int _port = 8080;
  final String _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();

  Future<String?> getLocalIpAddress() async {
    final info = NetworkInfo();
    _ipAddress = await info.getWifiIP();
    return _ipAddress;
  }

  Future<void> startServer(Function(String) onLog) async {
    await stopServer();
    final router = Router();

    router.get('/download', (Request request) async {
      final token = request.url.queryParameters['token'];
      if (token != _sessionToken) return Response.forbidden('Unauthorized');

      onLog("Connection accepted. Uploading database...");
      try {
        final dbFolder = await getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dbFolder.path, 'budgetr_local_v2.sqlite'));

        if (!await dbFile.exists())
          return Response.internalServerError(body: 'DB not found');

        return Response.ok(
          dbFile.openRead(),
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Disposition':
                'attachment; filename="budgetr_backup.sqlite"',
          },
        );
      } catch (e) {
        return Response.internalServerError(body: '$e');
      }
    });

    final handler =
        Pipeline().addMiddleware(logRequests()).addHandler(router.call);
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, _port);
    onLog("Server ready at $_ipAddress:$_port");
  }

  String getQrPayload() {
    if (_ipAddress == null) return "";
    return jsonEncode({
      "ip": _ipAddress,
      "port": _port,
      "token": _sessionToken,
      "type": "budgetr_sync_v1"
    });
  }

  Future<void> stopServer() async {
    await _server?.close();
    _server = null;
  }
}
