import 'dart:io';
import 'package:clasificacion/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'lote_http.dart';
import 'lote_model.dart';

// ScanPage.dart

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  bool _isUploading = false;
  String _uploadStatus = ""; // Almacena el mensaje de estado

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
      // Manejo de errores
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
      // Manejo de errores
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

  void _clearData({bool clearMessage = false}) {
    setState(() {
      _image = null;
      file = null;
      _recognitions = null;
      v = "";
      if (clearMessage) {
        _uploadStatus = ""; // Limpia el mensaje solo si se especifica
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null || file == null) {
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadPage(
          image: _image,
          file: file,
          recognitions: _recognitions,
        ),
      ),
    );

    if (result == 'clear') {
      setState(() {
        _uploadStatus = "Imagen subida exitosamente";
      });
      _clearData(clearMessage: false); // No limpiar el mensaje
    } else if (result == 'error') {
      setState(() {
        _uploadStatus = "Error al subir la imagen";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Imagen'),
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
                    image: AssetImage('assets/default_esca.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 20),
            if (_image != null) 
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadImage,
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
            if (_uploadStatus.isNotEmpty) // Mostrar el estado de la subida
              Text(
                _uploadStatus,
                style: TextStyle(
                  color: _uploadStatus.contains("exitosamente") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

// UploadPage.dart

class UploadPage extends StatefulWidget {
  final XFile? image;
  final File? file;
  final dynamic recognitions;

  UploadPage({required this.image, required this.file, required this.recognitions});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _textController = TextEditingController();
  var v = "";
  bool _isUploading = false;
  List<Lote>? lotes;
  String? selectedLote;

  @override
  void initState() {
    super.initState();
    fetchLotes().then((data) {
      setState(() {
        lotes = data;
      });
    });
  }

  Future<void> _updateImage() async {
    if (selectedLote == null) {
      setState(() {
        v = 'Por favor seleccione un lote';
      });
      return;
    }

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
    final uri = Uri.parse("http://agrocacao.medianewsonline.com/agrocacao/Clasificacion-cacao/controllers/movil/deteccion_movil.php");
    final request = http.MultipartRequest('POST', uri)
      ..fields['funcion'] = 'subir_imagen_seguimiento' 
      ..fields['estado'] = widget.recognitions[0]["label"]
      ..fields['porcentaje'] = (widget.recognitions[0]["confidence"] * 100).toStringAsFixed(2)
      ..fields['escaneo'] = _textController.text
      ..fields['lote_id'] = selectedLote!
      ..fields['user_id'] = "${user.id_us}"
      ..files.add(await http.MultipartFile.fromPath(
        'fileToUpload',
        widget.file!.path,
        filename: path.basename(widget.file!.path),
      ));

    try {
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        setState(() {
          v = 'Actualización exitosa';
        });
        Navigator.pop(context, 'clear'); // Redirigir a ScanPage con éxito
      } else {
        setState(() {
          v = 'Actualización fallida con estado: ${response.statusCode}';
        });
        Navigator.pop(context, 'error'); // Redirigir a ScanPage con error
      }
    } catch (e) {
      setState(() {
        v = 'Error en la actualización de la imagen: $e';
      });
      Navigator.pop(context, 'error'); // Redirigir a ScanPage con error
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
        title: Text('Ingresar nombre, lote y Subir Imagen'),
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
            DropdownButton<String>(
              hint: Text('Seleccione un lote'),
              value: selectedLote,
              items: lotes?.map((lote) {
                return DropdownMenuItem<String>(
                  value: '${lote.idLote}',
                  child: Text(lote.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLote = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ingrese nombre del escaneo',
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
              onPressed: (_isUploading || selectedLote == null) ? null : _updateImage,
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
