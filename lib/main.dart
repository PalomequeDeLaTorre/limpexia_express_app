import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:limpexia_express_app/pantallas/dashboard_cliente.dart';
import 'package:limpexia_express_app/pantallas/dashboard_profesional.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'pantallas/login.dart';
import 'utilidades/colores.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MiApp(),
    ),
  );
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Limpexia Express',
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