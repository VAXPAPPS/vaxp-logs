import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/injection.dart';
import 'core/theme/vaxp_theme.dart';
import 'features/logs/presentation/bloc/logs_bloc.dart';
import 'features/logs/presentation/pages/logs_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initDependencies();
  
  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1100, 750),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const VaxpLogsApp());
}

class VaxpLogsApp extends StatelessWidget {
  const VaxpLogsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaxpLogs',
      debugShowCheckedModeBanner: false,
      theme: VaxpTheme.dark,
      home: BlocProvider(
        create: (_) => sl<LogsBloc>(),
        child: const LogsPage(),
      ),
    );
  }
}
