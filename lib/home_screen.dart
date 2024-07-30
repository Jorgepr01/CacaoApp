import 'package:clasificacion/tabla_escaneo.dart';
import 'package:clasificacion/tabla_escaneo_tras.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'deteccion.dart';
import 'user.dart';
import 'tabla_tratamiento.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 145, 86, 86),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (user != null) ...[
              Row(
                children: [
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.nombre_us} ${user.apellido_us}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(user.email_us, style: TextStyle(color: Colors.grey)),
                          // Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      )
                    ],
                  )
                ],
              ),
              SizedBox(height: 20),
            ],
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ServiceTile(
                    icon: Icons.camera,
                    color: Colors.blue,
                    title: "Deteccion",
                    bookings: "Escaneo",
                    destination: ScanPage(),
                  ),
                  ServiceTile(
                    icon: Icons.backup_table,
                    color: Colors.orange,
                    title: "Seguimiento",
                    bookings: "Trasabilidad",
                    destination: user != null ? EscaneosTableScreen(userId: user.id_us, tipoUs: user.tipo_us_id): Container(),
                  ),
                  ServiceTile(
                    icon: Icons.cameraswitch_outlined,
                    color: Colors.green,
                    title: "Tratamiento",
                    bookings: "Tabla de tratamientos",
                    // destination: user != null ? EscaneosTableScreen(userId: user.id_us): Container(),
                    destination: user != null ? TablaTratamiento(userId: user.id_us): Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String bookings;
  final Widget destination;

  const ServiceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.bookings,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 4,
              blurRadius: 10,
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 40),
            Spacer(),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(bookings, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class PlumbingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plumbing')),
      body: Center(child: Text('Página de Plomería')),
    );
  }
}

class ElectricalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Electrical')),
      body: Center(child: Text('Página Eléctrica')),
    );
  }
}
