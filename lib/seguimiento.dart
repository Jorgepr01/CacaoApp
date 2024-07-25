import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class Seguimiento extends StatefulWidget {
  final int idEscaneo;
  Seguimiento({required this.idEscaneo});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<Seguimiento> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  bool _isUploading = false;

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
      // Handle error
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
      // Handle error
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
        v = '${_recognitions[0]["label"]}: ${(_recognitions[0]["confidence"] * 100).toStringAsFixed(2)}%';
      } else {
        v = 'No se encontró ninguna reconocimiento';
      }
    });
    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inferencia tardó ${endTime - startTime}ms");
  }

  void _clearData() {
    setState(() {
      _image = null;
      file = null;
      _recognitions = null;
      v = "";
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Imagen - Seguimiento'),
        backgroundColor: Color.fromARGB(255, 145, 86, 86),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: FileImage(File(_image!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage('assets/default_esca.png'), // Imagen predeterminada
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 20),
            if (_image != null) // Mostrar botón solo si hay una imagen
              ElevatedButton(
                onPressed: _isUploading ? null : () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadPage(
                        image: _image,
                        file: file,
                        recognitions: _recognitions,
                        idEscaneo: widget.idEscaneo, // Añadir idEscaneo
                      ),
                    ),
                  );
                  if (result == 'clear') {
                    _clearData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 145, 86, 86),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text('Ingresar nombre, lote y Subir Imagen'),
              ),
            SizedBox(height: 20),
            Text(v),
            SizedBox(height: 20),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: 'gallery',
                    backgroundColor: Color.fromARGB(255, 145, 86, 86),
                    onPressed: _pickImage,
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'camera',
                    backgroundColor: Color.fromARGB(255, 145, 86, 86),
                    onPressed: _pickImageCamara,
                    child: Icon(Icons.camera_alt, color: Colors.white),
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

class UploadPage extends StatefulWidget {
  final XFile? image;
  final File? file;
  final dynamic recognitions;
  final int idEscaneo; // Añadir idEscaneo

  UploadPage({required this.image, required this.file, required this.recognitions, required this.idEscaneo});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _textController = TextEditingController();
  var v = "";
  bool _isUploading = false;

  Future<void> _updateImage() async {
    setState(() {
      _isUploading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      setState(() {
        v = 'Usuario no autenticado';
        _isUploading = false;
      });
      return;
    }
    if (widget.file == null) {
      setState(() {
        v = 'Imagen no seleccionada';
        _isUploading = false;
      });
      return;
    }

    final uri = Uri.parse("http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/trasabilidad_movil.php");
    final request = http.MultipartRequest('POST', uri)
      ..fields['estado'] = widget.recognitions[0]["label"]
      ..fields['porcentaje'] = (widget.recognitions[0]["confidence"] * 100).toStringAsFixed(2)
      ..fields['observacion'] = _textController.text
      ..fields['seguiminiento'] = '${widget.idEscaneo}'
      // ..fields['latitud'] = '-12.12345'
      // ..fields['longitud'] = '-12.12345'
      ..fields['user_id'] = "${user.tipo_us_id}"
      ..files.add(await http.MultipartFile.fromPath(
        'fileToUpload',
        widget.file!.path,
        filename: path.basename(widget.file!.path),
      ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          v = 'Actualización exitosa';
        });
        Navigator.pop(context, 'clear'); // Redirigir a ScanPage y limpiar datos
      } else {
        setState(() {
          v = 'Actualización fallida con estado: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        v = 'Error en la actualización de la imagen: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingresar Observación y Subir Imagen'),
        backgroundColor: Color.fromARGB(255, 145, 86, 86),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.image != null)
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: FileImage(File(widget.image!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Text('Imagen no seleccionada'),
            SizedBox(height: 20),
            Text('Resultado del escaneo: ${widget.recognitions != null && widget.recognitions.isNotEmpty ? widget.recognitions[0]["label"] : "No se encontró ninguna reconocimiento"}'),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ingrese Observación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color.fromARGB(255, 145, 86, 86)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color.fromARGB(255, 145, 86, 86)),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _updateImage,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 145, 86, 86),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(_isUploading ? 'Subiendo...' : 'Subir Imagen'),
            ),
            SizedBox(height: 20),
            Text(v),
          ],
        ),
      ),
    );
  }
}

