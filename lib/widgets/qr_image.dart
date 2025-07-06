// utils/qr_image.dart

import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class QrImage extends SingleChildRenderObjectWidget {
  final String data;
  final Size size;
  final bool gapless;

    QrImage({
    Key? key,
    required this.data,
    required this.size,
    this.gapless = true,
  }) : super(key: key, child: Container());

  @override
  RenderObject createRenderObject(BuildContext context) {
    return QrImageRenderObject(data, size, gapless);
  }

  @override
  void updateRenderObject(BuildContext context, covariant QrImageRenderObject renderObject) {
    renderObject..data = data..size = size..gapless = gapless;
  }
}

class QrImageRenderObject extends RenderBox with RenderObjectWithChildMixin {
  String _data;
  Size _size;
  bool _gapless;

  QrImageRenderObject(this._data, this._size, this._gapless) {
    _initializeCanvas();
  }

  Future<void> _initializeCanvas() async {
    final canvas = html.CanvasElement(width: _size.width.toInt(), height: _size.height.toInt());
    canvas.id = 'qr-code-canvas';
    
    final parent = canvas.parentNode;
    if (parent != null) {
      final box = parent as RenderBox;
      final offset = box.localToGlobal(Offset.zero);
      
      final div = html.DivElement();
      div.style.position = 'absolute';
      div.style.left = '${offset.dx}px';
      div.style.top = '${offset.dy}px';
      div.style.width = '${_size.width}px';
      div.style.height = '${_size.height}px';
      div.append(canvas);
      
      html.document.body?.append(div);
    }
    
    final context = canvas.getContext('2d') as html.CanvasRenderingContext2D;
    context.fillStyle = 'white';
    context.fillRect(0, 0, canvas.width!, canvas.height!);
    
    final qr = js.JsObject(js.context['QRCode'], [
      canvas,
      js.JsObject.jsify({
        'text': _data,
        'width': _size.width,
        'height': _size.height,
        'colorDark': '#ffffff',
        'colorLight': '#000000',
        'correctLevel': js.context['QRCode.CorrectLevel.H'],
        'gapless': _gapless,
      })
    ]);
  }

  @override
  void performLayout() {
    size = constraints.constrain(_size);
  }

  String get data => _data;
  set data(String value) {
    if (_data != value) {
      _data = value;
      markNeedsPaint();
    }
  }

  Size get size => _size;
  set size(Size value) {
    if (_size != value) {
      _size = value;
      markNeedsLayout();
    }
  }

  bool get gapless => _gapless;
  set gapless(bool value) {
    if (_gapless != value) {
      _gapless = value;
      markNeedsPaint();
    }
  }

  void markNeedsPaint() {
    final canvas = html.querySelector('#qr-code-canvas') as html.CanvasElement?;
    if (canvas != null) {
      final context = canvas.getContext('2d') as html.CanvasRenderingContext2D;
      context.clearRect(0, 0, canvas.width!, canvas.height!);
      
      final qr = js.JsObject(js.context['QRCode'], [
        canvas,
        js.JsObject.jsify({
          'text': _data,
          'width': _size.width,
          'height': _size.height,
          'colorDark': '#ffffff',
          'colorLight': '#000000',
          'correctLevel': js.context['QRCode.CorrectLevel.H'],
          'gapless': _gapless,
        })
      ]);
    }
  }
}