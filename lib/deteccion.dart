import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'auth_provider.dart'; // Importa el AuthProvider

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

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  loadmodel() async {
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
      uploadImage(file!, _recognitions);  // Llamar a uploadImage con recognitions
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
      uploadImage(file!, _recognitions);  // Llamar a uploadImage con recognitions
    } catch (e) {
      print('Error picking image: $e');
    }
  }


  Future detectimage(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
      v = recognitions.toString();
      v = '${_recognitions[0]["label"]}: ${_recognitions[0]["confidence"].toStringAsFixed(2)}';
    });
    print("//////////////////////////////////////////////////");
    print(_recognitions[0]["label"]);
    print(_recognitions[0]["confidence"]);
    print("//////////////////////////////////////////////////");
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future<void> uploadImage(File image,var recognitions) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      print('User not authenticated');
      return;
    }
    final uri = Uri.parse("http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/deteccion_movil.php");
    final request = http.MultipartRequest('POST', uri)
      ..fields['funcion'] = 'subir_imagen_seguimiento'
      ..fields['estado'] = recognitions[0]["label"]
      ..fields['porcentaje'] = recognitions[0]["confidence"].toStringAsFixed(2)
      ..fields['nombre'] = "este es el nombre"
      ..fields['latitud'] = '-12.12345'
      ..fields['longitud'] = '-12.12345'
      ..fields['user_id'] = "${user.id_us}"
      ..files.add(await http.MultipartFile.fromPath(
        'fileToUpload', 
        image.path, 
        filename: path.basename(image.path)
      ));
    print(uri);

    try {
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Upload successful: $responseString');
        // setState(() {
        //   v = 'Upload successful: $responseString';  // Muestra la respuesta en la interfaz
        // });
      } else {
        print('Upload failed with status: ${response.statusCode}');
        setState(() {
          v = 'Upload failed with status: ${response.statusCode}';  // Muestra el error en la interfaz
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        v = 'Error uploading image: $e';  // Muestra el error en la interfaz
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
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: _pickImageCamara,
              child: Text('Pick Image from Camera'),
            ),
            SizedBox(height: 20),
            Text(v),
          ],
        ),
      ),
    );
  }
}