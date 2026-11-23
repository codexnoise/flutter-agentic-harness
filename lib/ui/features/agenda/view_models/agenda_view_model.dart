import 'package:flutter/foundation.dart';

import '../../../../data/repositories/agenda_repository.dart';
import '../../../../domain/models/session.dart';
import '../../../../domain/models/session_filter.dart';

/// Estado de la agenda: sesiones, filtros y favoritas ("Mi agenda").
class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel({required this._repository});

  final AgendaRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Object? _error;
  Object? get error => _error;

  List<Session> _sessions = const [];
  List<Session> get sessions => _sessions;

  List<String> _availableTracks = const [];
  List<String> get availableTracks => _availableTracks;

  List<String> _availableLevels = const [];
  List<String> get availableLevels => _availableLevels;

  SessionFilter _filter = SessionFilter.none;
  SessionFilter get filter => _filter;

  Set<String> _favoriteIds = const {};

  /// Sesiones que pasan el filtro actual.
  List<Session> get filteredSessions => _filter.apply(_sessions);

  /// Sesiones marcadas como favoritas, en el orden de la agenda.
  List<Session> get favoriteSessions =>
      _sessions.where((s) => _favoriteIds.contains(s.id)).toList();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sessions = await _repository.getSessions();
      _availableTracks = tracksOf(_sessions);
      _availableLevels = levelsOf(_sessions);
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTrack(String? track) {
    _filter = _filter.withTrack(track);
    notifyListeners();
  }

  void selectLevel(String? level) {
    _filter = _filter.withLevel(level);
    notifyListeners();
  }

  bool isFavorite(String sessionId) => _favoriteIds.contains(sessionId);

  void toggleFavorite(String sessionId) {
    final next = Set<String>.of(_favoriteIds);
    if (!next.remove(sessionId)) next.add(sessionId);
    _favoriteIds = Set.unmodifiable(next);
    notifyListeners();
  }
}
