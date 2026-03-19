import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool _loading = true;
  File? _image;
  List<double>? _output;
  List<String>? _labels;

  final picker = ImagePicker();
  late Interpreter interpreter;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    interpreter = await Interpreter.fromAsset(
      'assets/detection_files/model_unquant.tflite',
    );

    _labels = await loadLabels('assets/detection_files/labels.txt');

    setState(() {
      _loading = false;
    });
  }

  Future<List<String>> loadLabels(String path) async {
    final data = await rootBundle.loadString(path);
    return data.split('\n');
  }

  Future pickImage(ImageSource source) async {

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _loading = true;
      _image = File(pickedFile.path);
    });

    await detectImage(pickedFile.path);
  }

  Future detectImage(String path) async {

    final imageBytes = await File(path).readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    img.Image resizedImage =
    img.copyResize(originalImage!, width: 224, height: 224);

    var input = List.generate(
      1,
          (_) => List.generate(
        224,
            (y) => List.generate(
          224,
              (x) {

            final pixel = resizedImage.getPixel(x, y);

            return [
              (pixel.r - 127.5) / 127.5,
              (pixel.g - 127.5) / 127.5,
              (pixel.b - 127.5) / 127.5,
            ];
          },
        ),
      ),
    );

    var output = List.generate(1, (_) => List.filled(2, 0.0));

    interpreter.run(input, output);

    setState(() {
      _output = output[0];
      _loading = false;
    });


  }

  String getPrediction() {

    if (_output == null || _labels == null) return "";

    double catScore = _output![0];
    double dogScore = _output![1];

    int index = catScore > dogScore ? 0 : 1;
    double confidence = _output![index];

    double margin = (catScore - dogScore).abs();

    /// Strict filtering rules
    if (confidence < 0.90 || margin < 0.40) {
      return "Not Cat or Dog";
    }

    return "This is ${_labels![index]}";//"${_labels![index]} ${(confidence * 100).toStringAsFixed(2)}%";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text("Cat & Dog Detector"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 30),

            _image == null
                ? Image.asset(
              "assets/images/cat_dog_icon.png",
              height: 250,
            )
                : Image.file(_image!, height: 250),

            const SizedBox(height: 20),

            if (_loading)
              const CircularProgressIndicator.adaptive(),

            const SizedBox(height: 20),

            if (_output != null)
              Text(
                getPrediction(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),

                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}