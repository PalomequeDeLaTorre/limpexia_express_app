import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'pantallas/login.dart';
import 'pantallas/dashboard_cliente.dart';
import 'pantallas/dashboard_profesional.dart';
import 'utilidades/colores.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AppState());
}

class AppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Limpexia',
      initialRoute: 'login',
      routes: {
        'login': (_) => PantallaLogin(),
        'dashboard_cliente': (_) => const DashboardCliente(),
        'dashboard_profesional': (_) => const DashboardProfesional(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColores.primario),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
    );
  }
}
