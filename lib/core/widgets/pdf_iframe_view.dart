import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

class PdfIframeView extends StatefulWidget {
  const PdfIframeView({super.key, required this.url});

  final String url;

  @override
  State<PdfIframeView> createState() => _PdfIframeViewState();
}

class _PdfIframeViewState extends State<PdfIframeView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'pdf-iframe-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

void openUrlInNewTab(String url) {
  html.window.open(url, '_blank');
}