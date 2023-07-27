import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentScanPage extends StatefulWidget {
  final String studysetId;

  const DocumentScanPage({Key? key, required this.studysetId})
      : super(key: key);

  @override
  State<DocumentScanPage> createState() => _DocumentScanPageState();
}

class _DocumentScanPageState extends State<DocumentScanPage> {
  File? _imageFile;
  File? _file;
  String? _extractedText = '';

  generateFlashcards() async {
    DatabaseService()
        .generateFlashcardsFromText(_extractedText!, widget.studysetId);
  }

  showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Camera Permission Denied'),
          content:
              const Text('Please grant camera permission in app settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  showStoragePermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('File Permission Denied'),
          content:
              const Text('Please grant storage permission in app settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  Future<void> getImageFromCamera() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        final imageFile = await ImagePicker().pickImage(
          source: ImageSource.camera,
        );
        if (imageFile != null) {
          final inputImage = InputImage.fromFile(File(imageFile.path));
          final textRecognizer =
              TextRecognizer(script: TextRecognitionScript.latin);
          final RecognizedText recognizedText =
              await textRecognizer.processImage(inputImage);
          final extractedText = recognizedText.text;
          setState(() {
            _imageFile = File(imageFile.path);
            _extractedText = extractedText;
          });
        }
      } else {
        showCameraPermissionDialog();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getFileFromStorage() async {
    try {
      // Get file from device storage
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'png',
          'jpeg',
          'txt',
          'gdoc',
          'doc',
          'docx'
        ],
        allowMultiple: false,
        withData: true,
      );

      final file = File(result!.files.single.path!);

      setState(() {
        _imageFile = null;
        _file = File(file.path);
        _extractedText = '';
      });
      // Process file with ML Kit text recognizer
      final extension = file.path.split('.').last.toLowerCase();
      if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
        final inputImage = InputImage.fromFile(File(file.path));
        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);
        final extractedText = recognizedText.text;
        setState(() {
          _imageFile = File(file.path);
          _extractedText = extractedText;
        });
      } else if (extension == 'pdf') {
        final bytes = await file.readAsBytes();
        final Uint8List fileData =
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
        PdfDocument document = PdfDocument(inputBytes: fileData);
        PdfTextExtractor extractor = PdfTextExtractor(document);
        String extractedText = extractor.extractText();
        setState(() {
          _extractedText = extractedText;
        });
      } else if (extension == 'docx') {
        final bytes = await file.readAsBytes();
        String extractedText = docxToText(bytes);
        setState(() {
          _extractedText = extractedText;
        });
      } else {
        final extractedText = await file.readAsString();
        setState(() {
          _extractedText = extractedText;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Flashcards'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: getFileFromStorage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_upload),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Choose File'),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: getImageFromCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Scan Document'),
                    ),
                  ],
                ),
              ),
            ),
            if (_imageFile != null || _file != null) ...[
              Container(
                width: 200,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  color: Colors.white,
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!)
                    : Text(_file!.path),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                autofocus: true,
                maxLines: null,
                decoration: InputDecoration(
                    labelText:
                        'Text (flashcards generated from the text below)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .primaryColor, // set border color here
                        width: 2.0,
                      ),
                    ),
                    labelStyle:
                        const TextStyle(color: Colors.black, fontSize: 18)),
                controller: TextEditingController(text: _extractedText),
                onChanged: (value) {
                  _extractedText = value;
                },
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 60,
          ),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await generateFlashcards();
            },
            label: const Text('Generate'),
            icon: const Icon(Icons.create),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
