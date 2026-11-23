import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/session_api_model.dart';

/// Lee la agenda desde el JSON empaquetado en los assets de la app.
class AgendaAssetService {
  AgendaAssetService({AssetBundle? bundle, this.assetPath = defaultAssetPath})
    : _bundle = bundle ?? rootBundle;

  static const defaultAssetPath = 'assets/devfest_agenda.json';

  final AssetBundle _bundle;
  final String assetPath;

  Future<List<SessionApiModel>> fetchSessions() async {
    final raw = await _bundle.loadString(assetPath);
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => SessionApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
