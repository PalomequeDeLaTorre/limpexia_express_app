import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/reserva_provider.dart';
import 'providers/pwa_provider.dart';
import 'pantallas/login.dart';
import 'utilidades/colores.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDWn9HbK4VSbqL2SGZ7o-fg9raO1e_-iH4",
      projectId: "clinicacalbd",
      messagingSenderId: "462479503525",
      appId: "1:462479503525:web:9cbe16038abc88242f1d4c",
    ),
  );
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReservaProvider()),
        ChangeNotifierProvider(create: (_) => PwaProvider()),
      ],
      child: MaterialApp(
        title: 'Limpexia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColores.primario),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
        ),
        home: const PantallaLogin(),
      ),
    );
  }
}