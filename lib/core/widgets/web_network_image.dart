import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class WebNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final WidgetBuilder? loadingWidget;
  final WidgetBuilder? errorWidget;

  const WebNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loadingWidget?.call(context) ??
              const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget?.call(context) ??
              const Center(child: Icon(Icons.broken_image));
        },
      );
    }

    final String viewId = 'web-image-${url.hashCode}';
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final html.ImageElement img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = fit == BoxFit.contain ? 'contain' : 'cover';
      return img;
    });

    return HtmlElementView(viewType: viewId);
  }
}

Future<void> downloadFileWeb(String url, String filename) async {
  if (kIsWeb) {
    try {
      final request = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'blob',
      );
      final blob = request.response as html.Blob;
      final objectUrl = html.Url.createObjectUrlFromBlob(blob);
      
      final anchorElement = html.AnchorElement(href: objectUrl)
        ..setAttribute("download", filename)
        ..style.display = 'none';
      
      html.document.body?.children.add(anchorElement);
      anchorElement.click();
      html.document.body?.children.remove(anchorElement);
      html.Url.revokeObjectUrl(objectUrl);
    } catch (e) {
      html.window.open(url, '_blank');
    }
  }
}
