import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'models/session.dart';
import 'screens/agenda_screen.dart';
import 'screens/my_agenda_screen.dart';

void main() {
  runApp(const DevFestAgendaApp());
}

class DevFestAgendaApp extends StatelessWidget {
  const DevFestAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevFest Agenda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<Set<String>> _favorites = ValueNotifier(<String>{});
  late final Future<List<Session>> _sessions = _loadSessions();
  int _tabIndex = 0;

  Future<List<Session>> _loadSessions() async {
    final raw = await rootBundle.loadString('assets/devfest_agenda.json');
    final data = jsonDecode(raw) as List<dynamic>;
    final sessions = data
        .map((e) => Session.fromJson(e as Map<String, dynamic>))
        .toList();
    sessions.sort((a, b) {
      final byTime = a.time.compareTo(b.time);
      return byTime != 0 ? byTime : a.title.compareTo(b.title);
    });
    return sessions;
  }

  void _toggleFavorite(Session session) {
    final next = Set<String>.of(_favorites.value);
    if (!next.remove(session.id)) next.add(session.id);
    _favorites.value = next;
  }

  @override
  void dispose() {
    _favorites.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabIndex == 0 ? 'Agenda DevFest' : 'Mi agenda'),
      ),
      body: FutureBuilder<List<Session>>(
        future: _sessions,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data!;
          return IndexedStack(
            index: _tabIndex,
            children: [
              AgendaScreen(
                sessions: sessions,
                favorites: _favorites,
                onToggleFavorite: _toggleFavorite,
              ),
              MyAgendaScreen(
                sessions: sessions,
                favorites: _favorites,
                onToggleFavorite: _toggleFavorite,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Mi agenda',
          ),
        ],
      ),
    );
  }
}
