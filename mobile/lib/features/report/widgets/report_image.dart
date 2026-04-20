import 'dart:convert';

import 'package:flutter/material.dart';

/// Tampilkan gambar laporan: URL https atau data URI base64 (hasil galeri/kamera).
Widget reportImage(
  String src, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  if (src.startsWith('data:image')) {
    final comma = src.indexOf(',');
    if (comma < 0) return _imagePlaceholder(width: width, height: height);
    try {
      final bytes = base64Decode(src.substring(comma + 1));
      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        gaplessPlayback: true,
      );
    } catch (_) {
      return _imagePlaceholder(width: width, height: height);
    }
  }

  return Image.network(
    src,
    fit: fit,
    width: width,
    height: height,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return _loadingBox(width: width, height: height);
    },
    errorBuilder: (context, error, stackTrace) {
      return _imagePlaceholder(width: width, height: height);
    },
  );
}

Widget _loadingBox({double? width, double? height}) {
  return Container(
    width: width,
    height: height,
    color: const Color(0xFFE5E7EB),
    alignment: Alignment.center,
    child: const SizedBox(
      width: 26,
      height: 26,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

Widget _imagePlaceholder({double? width, double? height}) {
  return Container(
    width: width,
    height: height,
    color: const Color(0xFFE5E7EB),
    alignment: Alignment.center,
    child: Icon(Icons.hide_image_outlined, color: Colors.grey.shade500),
  );
}
