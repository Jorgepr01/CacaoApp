import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'auth_provider.dart'; // Importa el AuthProvider
import 'tabla_escaneo.dart';

class Seguimiento extends StatelessWidget {
  final int idEscaneo;
  Seguimiento({required this.idEscaneo});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerDemo(idEscaneo: idEscaneo),
    );
  }
}

class ImagePickerDemo extends StatefulWidget {
  final int idEscaneo; // Añade este campo

  ImagePickerDemo({required this.idEscaneo}); 

  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  final TextEditingController _textController = TextEditingController();  // Controlador para el campo de entrada

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  Future<void> loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImageCamara() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      await detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      await detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> detectimage(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
      if (recognitions != null && recognitions.isNotEmpty) {
        v = '${_recognitions[0]["label"]}: ${_recognitions[0]["confidence"].toStringAsFixed(2)}';
      } else {
        v = 'No recognitions found';
      }
    });
    print("//////////////////////////////////////////////////");
    print(_recognitions[0]["label"]);
    print(_recognitions[0]["confidence"]);
    print("//////////////////////////////////////////////////");
    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future<void> _updateImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      setState(() {
        v = 'Usuario no autenticado';
      });
      return;
    }
    if (file == null) {
      setState(() {
        v = 'Imagen no seleccionada';
      });
      return;
    }

    final uri = Uri.parse("http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/trasabilidad_movil.php");
    final request = http.MultipartRequest('POST', uri)
      ..fields['estado'] = _recognitions[0]["label"]
      ..fields['porcentaje'] = _recognitions[0]["confidence"].toStringAsFixed(2)
      ..fields['observacion'] = _textController.text
      ..fields['seguiminiento'] = '${widget.idEscaneo}'
      // ..fields['longitud'] = '-12.12345'
      // ..fields['user_id'] = "${user.id_us}"
      ..files.add(await http.MultipartFile.fromPath(
        'fileToUpload', 
        file!.path, 
        filename: path.basename(file!.path)
      ));
    print(uri);

    try {
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          v = 'Actualizacion exitosa: $responseString';
          _image = null;  // Borra la imagen
          file = null;  // Borra la imagen
          _textController.clear();  // Limpia el campo de texto
        });
      } else {
        setState(() {
          v = 'Actualización fallida con estado: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        v = 'Error en la actualización de la imagen: $e';
      });
    }
  }
// diseño de la pantalla para el seguimiento
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trasabilidad'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              Text('Imagen no seleccionada'),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ingrese observacion',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EscaneosTableScreen(userId: 9),
                  ),
                );
              },
              child: Text('tabla'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Galeria'),
            ),
            ElevatedButton(
              onPressed: _pickImageCamara,
              child: Text('Cámara'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateImage,
              child: Text('actualizar Imagen'),
            ),
            SizedBox(height: 20),
            Text(v),
          ],
        ),
      ),
    );
  }
}
