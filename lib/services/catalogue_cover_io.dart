import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> telechargerCouverture(String url, String id) async {
  try {
    var uri = Uri.parse(url);

    if (uri.scheme == 'http') {
      uri = uri.replace(scheme: 'https');
    }

    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      return null;
    }

    final identifiant = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');

    if (identifiant.isEmpty) return null;

    final dossier = await getApplicationDocumentsDirectory();

    final fichier = File(p.join(dossier.path, 'libraryflow_$identifiant.img'));

    await fichier.writeAsBytes(response.bodyBytes, flush: true);

    return fichier.path;
  } catch (_) {
    return null;
  }
}
