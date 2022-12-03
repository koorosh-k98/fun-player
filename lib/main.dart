import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/home.dart';
import 'package:player/permission.dart';

import 'favorite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child:MyApp(
      initialRoute: await Permission.storage.isGranted
          ? HomePage.id
          : PermissionHandle.id)));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.initialRoute, super.key});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        HomePage.id: (context) => const HomePage(),
        PermissionHandle.id: (context) => const PermissionHandle(),
      },
    );
  }
}
