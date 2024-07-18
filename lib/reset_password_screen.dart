import 'package:flutter/material.dart';
import 'codigo_rec_contra.dart';
class ResetPasswordScreen extends StatelessWidget {
  final String email;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  ResetPasswordScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Restablecer Contraseña", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 145, 86, 86),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Correo: $email",
                style: TextStyle(color: Color.fromARGB(255, 145, 86, 86)),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Código de Verificación",
                  labelStyle: TextStyle(color: Color.fromARGB(255, 145, 86, 86)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color:Color.fromARGB(255, 145, 86, 86)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color:Color.fromARGB(255, 145, 86, 86)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Nueva Contraseña",
                  labelStyle: TextStyle(color:Color.fromARGB(255, 145, 86, 86)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color:Color.fromARGB(255, 145, 86, 86)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Color.fromARGB(255, 145, 86, 86)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  String code = _codeController.text;
                  String newPassword = _newPasswordController.text;
                  CodigoRecuperacion(email,code,newPassword);
                  // Aquí llamarías a la función para restablecer la contraseña
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor:Color.fromARGB(255, 145, 86, 86),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text("Restablecer Contraseña", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
