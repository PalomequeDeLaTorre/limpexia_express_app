import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as local_auth; // Alias para evitar conflictos si los hubiera
import '../pantallas/login.dart';
import '../pantallas/dashboard_cliente.dart';
import '../pantallas/dashboard_profesional.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // 1. Escucha cambios en la autenticación en tiempo real
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // Estado de carga inicial (mientras conecta con Firebase Auth)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Si hay un usuario logueado
        if (snapshot.hasData) {
          final User user = snapshot.data!;
          
          // 3. Consultamos la base de datos para saber su ROL
          return FutureBuilder<DataSnapshot>(
            future: FirebaseDatabase.instance.ref('usuarios/${user.uid}').get(),
            builder: (context, dbSnapshot) {
              
              if (dbSnapshot.connectionState == ConnectionState.waiting) {
                 return const Scaffold(
                   body: Center(
                     child: CircularProgressIndicator(color: Color.fromARGB(255, 6, 78, 125))
                   )
                 );
              }

              if (dbSnapshot.hasData && dbSnapshot.data!.exists) {
                // Obtenemos los datos
                final data = Map<dynamic, dynamic>.from(dbSnapshot.data!.value as Map);
                final String rol = data['rol'] ?? 'cliente';

                // IMPORTANTE: Aquí podríamos actualizar tu AuthProvider para que tenga los datos listos
                // Pero por ahora solo haremos la navegación para que funcione rápido.
                
                if (rol == 'profesional') {
                  return const DashboardProfesional(); 
                } else {
                  return const DashboardCliente();
                }
              }

              // Si falla la lectura de datos (usuario borrado de BD pero no de Auth), al login
              return const PantallaLogin();
            },
          );
        }

        // 4. Si no hay usuario, mandamos al Login
        return const PantallaLogin();
      },
    );
  }
}