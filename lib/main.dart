import 'package:material_ui/material_ui.dart';

import 'package:devfest_agenda/data/repositories/agenda_repository.dart';
import 'package:devfest_agenda/data/services/agenda_asset_service.dart';
import 'package:devfest_agenda/ui/core/theme/app_theme.dart';
import 'package:devfest_agenda/ui/core/theme/track_colors.dart';
import 'package:devfest_agenda/ui/features/agenda/view_models/agenda_view_model.dart';
import 'package:devfest_agenda/ui/features/agenda/views/home_page.dart';

void main() {
  // El view model empieza a cargar assets antes de runApp: necesita el binding.
  WidgetsFlutterBinding.ensureInitialized();

  // Raíz de composición: datos -> repositorio -> view model -> UI.
  final repository = AgendaRepository(service: AgendaAssetService());
  final viewModel = AgendaViewModel(repository: repository)..load();
  runApp(DevFestAgendaApp(viewModel: viewModel));
}

class DevFestAgendaApp extends StatelessWidget {
  const DevFestAgendaApp({super.key, required this.viewModel});

  final AgendaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevFest Agenda',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Los colores por track dependen de los tracks cargados; se proveen
      // por encima del Navigator para que también los vea el detalle.
      builder: (context, child) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => TrackColorsScope(
          colors: TrackColors(viewModel.availableTracks),
          child: child!,
        ),
      ),
      home: HomePage(viewModel: viewModel),
    );
  }
}
