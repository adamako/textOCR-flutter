import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart'
    show kTransparentImage;

import 'dart:async';

class TextOCR extends StatefulWidget {
  const TextOCR({Key key}) : super(key: key);

  @override
  _TextOCRState createState() => _TextOCRState();
}

class _TextOCRState extends State<TextOCR> {
  File _imageFile;
  String _mlResult = '<no result>';

  Future<bool> _pickImage() async {
    setState(() => this._imageFile = null);

    final File imageFile = await showDialog<File>(
        context: context,
        builder: (ctx) => SimpleDialog(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Prendre une photo'),
                  onTap: () async {
                    final File imageFile =
                        await ImagePicker.pickImage(source: ImageSource.camera);
                    Navigator.pop(ctx, imageFile);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Prendre dans la gallery'),
                  onTap: () async {
                    try {
                      final File imageFile = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      Navigator.pop(ctx, imageFile);
                    } catch (e) {
                      print(e);
                      Navigator.pop(ctx, null);
                    }
                  },
                )
              ],
            ));

    if (imageFile == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Svp selectionner une image d\'abord')),
      );
      return false;
    }

    setState(() => this._imageFile = imageFile);
    print('picked image: ${this._imageFile}');
    return true;
  }

  Future<Null> _textOCR() async {
    setState(() => this._mlResult = '<No result>');
    if (await _pickImage() == false) {
      return;
    }
    String result = '';
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(this._imageFile);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    final String text = visionText.text;
    debugPrint('Recognized text: $text ');

    result += text;
//    result += 'Detected ${visionText  .blocks.length} text blocks.\n';
//    for (TextBlock block in visionText.blocks) {
//      final Rect boundingBox = block.boundingBox;
//      final String text = block.text;
//      result += '\n Text block: \n'
//          'bbox= $boundingBox\n'
//          'text= $text\n';
//    }

    if (result.length > 0) {
      setState(() {
        return this._mlResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TextOCR'),
      ),
      body: ListView(
        children: <Widget>[
          this._imageFile == null
              ? Placeholder(
                  fallbackHeight: 200.0,
                )
              : FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: FileImage(this._imageFile),
                ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: RaisedButton(
              child: Text('Text OCR'),
              onPressed: this._textOCR,
            ),
          ),
          Divider(),
          Text(
            'Result: ',
            style: Theme.of(context).textTheme.subtitle,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              this._mlResult,
              style: TextStyle(fontFamily: 'monospace'),
            ),
          )
        ],
      ),
    );
  }
}
