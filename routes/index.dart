import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {'service': 'Prayer Time API', 'version': '0.9.5'},
  );
}
