import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'auth_provider.dart'; // Importa el AuthProvider
import 'tabla_escaneo.dart';

class Deteccion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerDemo(),
    );
  }
}

class ImagePickerDemo extends StatefulWidget {
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
      print('User not authenticated');
      setState(() {
        v = 'User not authenticated';
      });
      return;
    }
    if (file == null) {
      print('No image selected');
      setState(() {
        v = 'No image selected';
      });
      return;
    }
    final uri = Uri.parse("http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/deteccion_movil.php");
    final request = http.MultipartRequest('POST', uri)
      ..fields['funcion'] = 'subir_imagen_seguimiento'
      ..fields['estado'] = _recognitions[0]["label"]
      ..fields['porcentaje'] = _recognitions[0]["confidence"].toStringAsFixed(2)
      ..fields['nombre'] = _textController.text
      ..fields['latitud'] = '-12.12345'
      ..fields['longitud'] = '-12.12345'
      ..fields['user_id'] = "${user.id_us}"
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
        print('Upload successful: $responseString');
        setState(() {
          v = 'Upload successful: $responseString';
          _image = null;  // Borra la imagen
          file = null;  // Borra la imagen
          _textController.clear();  // Limpia el campo de texto
        });
      } else {
        print('Upload failed with status: ${response.statusCode}');
        setState(() {
          v = 'Upload failed with status: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        v = 'Error uploading image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter TFlite'),
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
              Text('No image selected'),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter some text',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EscaneosTableScreen(),
                  ),
                );
              },
              child: Text('tabla'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: _pickImageCamara,
              child: Text('Pick Image from Camera'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateImage,
              child: Text('Update Image'),
            ),
            SizedBox(height: 20),
            Text(v),
          ],
        ),
      ),
    );
  }
}
