import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agremate_admin/core/theme/theme.dart';

import '../../../../core/services/config_service.dart';

class PropertyLocationMap extends StatefulWidget {
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;
  final double height;

  const PropertyLocationMap({
    super.key,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
    this.height = 190,
  });

  @override
  State<PropertyLocationMap> createState() => _PropertyLocationMapState();
}

class _PropertyLocationMapState extends State<PropertyLocationMap> {
  late final String _viewType;
  html.IFrameElement? _iframe;
  double? _lat;
  double? _lng;

  bool get _hasCoords =>
      _lat != null && _lng != null && !(_lat == 0 && _lng == 0);

  String? _mapsKey;

  Future<String?> _loadMapsKey() async {
    try {
      final key = await ConfigService.googleMapsKey();
      return key.toString();
    } catch (e) {
      debugPrint('Maps key load failed: $e');
      return null;
    }
  }

  String get _embedUrl {
    final key = _mapsKey;
    final q = _hasCoords ? '$_lat,$_lng' : Uri.encodeComponent(widget.address);

    if (key == null || key.isEmpty) {
      return 'https://maps.google.com/maps?q=$q&z=16&output=embed';
    }

    return 'https://www.google.com/maps/embed/v1/place?key=$key&q=$q&zoom=17';
  }

  String get _shareUrl => _hasCoords
      ? 'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng'
      : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.address)}';

  @override
  void initState() {
    super.initState();
    _lat = widget.latitude;
    _lng = widget.longitude;

    _viewType = 'property-map-${identityHashCode(this)}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      _iframe = html.IFrameElement()
        ..src = _embedUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      return _iframe!;
    });

    _init();   // instead of the if (!_hasCoords ...) _geocodeAddress() block
  }

  Future<void> _init() async {
    final key = await _loadMapsKey();
    if (!mounted) return;
    setState(() => _mapsKey = key);
    _iframe?.src = _embedUrl;

    if ((key == null || key.isEmpty) &&
        !_hasCoords &&
        widget.address.trim().isNotEmpty) {
      _geocodeAddress();
    }
  }

  /// Converts the address text to lat/lng so the map can show a pin.
  Future<void> _geocodeAddress() async {
    final parts = widget.address
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (int i = 0; i < parts.length && i < 3; i++) {
      final q = parts.sublist(i).join(', ');
      try {
        final res = await html.HttpRequest.getString(
          'https://nominatim.openstreetmap.org/search'
              '?format=json&limit=1&q=${Uri.encodeComponent(q)}',
        );
        final list = jsonDecode(res) as List;
        if (list.isNotEmpty) {
          final lat = double.tryParse(list[0]['lat'].toString());
          final lon = double.tryParse(list[0]['lon'].toString());
          if (lat != null && lon != null) {
            if (!mounted) return;
            setState(() {
              _lat = lat;
              _lng = lon;
            });
            _iframe?.src = _embedUrl;
            return;
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _shareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location link copied')),
    );
  }

  void _onShareSelected(String value) {
    final text =
    Uri.encodeComponent('${widget.title}\n${widget.address}\n$_shareUrl');
    switch (value) {
      case 'copy':
        _copyLink();
        break;
      case 'whatsapp':
        _open('https://wa.me/?text=$text');
        break;
      case 'email':
        _open('mailto:?subject=${Uri.encodeComponent(widget.title)}&body=$text');
        break;
      case 'open':
        _open(_shareUrl);
        break;
    }
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.accentBlue),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCoords && widget.address.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(child: HtmlElementView(viewType: _viewType)),

            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.white,
                elevation: 3,
                shape: const CircleBorder(),
                child: PopupMenuButton<String>(
                  tooltip: 'Share location',
                  icon: const Icon(Icons.share_rounded,
                      size: 18, color: AppTheme.accentBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: _onShareSelected,
                  itemBuilder: (_) => [
                    _item('copy', Icons.link_rounded, 'Copy link'),
                    _item('whatsapp', Icons.chat_rounded, 'Share on WhatsApp'),
                    _item('email', Icons.email_rounded, 'Share via Email'),
                    _item('open', Icons.open_in_new_rounded, 'Open in Google Maps'),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 10,
              bottom: 10,
              child: Material(
                color: Colors.white,
                elevation: 3,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _open(_shareUrl),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded,
                            size: 14, color: AppTheme.accentBlue),
                        SizedBox(width: 6),
                        Text(
                          'Open in Google Maps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}