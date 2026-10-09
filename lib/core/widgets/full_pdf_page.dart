import 'package:flutter/material.dart';
import 'pdf_iframe_view.dart';

class FullPdfPage extends StatelessWidget {
  const FullPdfPage({super.key, required this.url, this.title = 'Document'});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Open in new tab',
            icon: const Icon(Icons.open_in_new),
            onPressed: () => openUrlInNewTab(url),
          ),
        ],
      ),
      body: PdfIframeView(key: ValueKey(url), url: url),
    );
  }
}