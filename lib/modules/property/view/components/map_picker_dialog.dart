import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:agremate_admin/core/services/config_service.dart';

class PickedLocation {
  final String address;
  final double latitude;
  final double longitude;
  const PickedLocation(this.address, this.latitude, this.longitude);
}

String cleanAddress(String raw) {
  var s = raw.trim();
  s = s.replaceFirst(RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,}\s*,?\s*'), '');
  final numericPart = RegExp(r'^#?\d+[A-Za-z]?([\-\/\.\s]\d+[A-Za-z]?)*$');
  final parts = s.split(',');
  if (parts.length > 1 && numericPart.hasMatch(parts.first.trim())) {
    s = parts.sublist(1).join(',').trim();
  }
  return s.isEmpty ? raw.trim() : s;
}

Future<PickedLocation?> showMapPicker(BuildContext context,
    {double? lat, double? lng}) {
  return showDialog<PickedLocation>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 600),
        child: _MapPicker(
            initial: lat != null && lng != null ? LatLng(lat, lng) : null),
      ),
    ),
  );
}

class _MapPicker extends StatefulWidget {
  final LatLng? initial;
  const _MapPicker({this.initial});

  @override
  State<_MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<_MapPicker> {
  static const _blue = Color(0xFF2F6BFF);
  static const _navy = Color(0xFF0B1F5C);
  static const _blueMuted = Color(0xFF6B7FB5);
  static const _green = Color(0xFF43A047);
  static const _defaultCenter = LatLng(12.9716, 77.5946);

  final _dio = Dio();
  final _searchC = TextEditingController();
  GoogleMapController? _map;
  late LatLng _pos = widget.initial ?? _defaultCenter;
  String _address = '';
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) _reverse(_pos);
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _reverse(LatLng p) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final key = await ConfigService.googleMapsKey();
      final r = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '${p.latitude},${p.longitude}',
          'key': key,
        },
      );
      if (!mounted) return;
      final status = r.data['status'];
      final results = r.data['results'] as List?;
      if (status == 'OK' && results != null && results.isNotEmpty) {
        setState(() => _address =
            cleanAddress(results.first['formatted_address'] ?? ''));
      } else {
        setState(() {
          _address = '';
          _error = status == 'ZERO_RESULTS'
              ? 'No address found here. Try another spot.'
              : 'Could not get address ($status)';
        });
      }
    } catch (e) {
      debugPrint('MapPicker error: $e');
      if (mounted) setState(() => _error = _friendly(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search() async {
    final q = _searchC.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final key = await ConfigService.googleMapsKey();
      final r = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {'address': q, 'key': key},
      );
      if (!mounted) return;
      final results = r.data['results'] as List?;
      if (r.data['status'] == 'OK' && results != null && results.isNotEmpty) {
        final loc = results.first['geometry']['location'];
        final p = LatLng(
            (loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
        setState(() {
          _pos = p;
          _address = cleanAddress(results.first['formatted_address'] ?? q);
        });
        _map?.animateCamera(CameraUpdate.newLatLngZoom(p, 16));
      } else {
        setState(() => _error = 'No results for "$q"');
      }
    } catch (e) {
      debugPrint('MapPicker error: $e');
      if (mounted) setState(() => _error = _friendly(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useCurrentLocation({bool silent = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Location is turned off on this device.';
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw 'Location permission denied. Allow it in the browser settings.';
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      final p = LatLng(pos.latitude, pos.longitude);
      setState(() => _pos = p);
      _map?.animateCamera(CameraUpdate.newLatLngZoom(p, 17));
      await _reverse(p);
    } catch (e) {
      debugPrint('Current location error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!silent) _error = e is String ? e : 'Could not get current location.';
      });
    }
  }

  String _friendly(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        return 'Not authorised to load map config ($code). Check the login token.';
      }
      if (code != null) return 'Server error ($code) while loading the address.';
      return 'Request blocked or offline (${e.requestOptions.uri.host}). Check CORS / network.';
    }
    return 'Could not load address: $e';
  }

  void _onTap(LatLng p) {
    setState(() => _pos = p);
    _reverse(p);
  }

  void _confirm() =>
      Navigator.pop(context, PickedLocation(_address, _pos.latitude, _pos.longitude));

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _header(),
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(children: [
            SizedBox(height: 280, child: _mapArea()),
            const SizedBox(height: 14),
            _addressBox(),
            const SizedBox(height: 16),
            _buttons(),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    ]);
  }

  Widget _header() {
    return Container(
      color: _blue,
      padding: const EdgeInsets.fromLTRB(22, 10, 10, 10),
      child: Row(children: [
        const Icon(Icons.location_on, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        const Text('Pick Property Location',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 16),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: _searchBar(),
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
          splashRadius: 20,
        ),
      ]),
    );
  }

  Widget _mapArea() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _pos, zoom: 15),
            onMapCreated: (c) {
              _map = c;
              if (widget.initial == null) _useCurrentLocation(silent: true);
            },
            onTap: _onTap,
            markers: {
              Marker(
                markerId: const MarkerId('p'),
                position: _pos,
                draggable: true,
                onDragEnd: _onTap,
              ),
            },
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: true,
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              elevation: 4,
              shape: const CircleBorder(),
              color: Colors.white,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _useCurrentLocation,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.my_location, size: 22, color: _blue),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _searchBar() {
    return Material(
      elevation: 4,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      child: TextField(
        controller: _searchC,
        onSubmitted: (_) => _search(),
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search address or place',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          isDense: true,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical:8),
          prefixIcon: const Icon(Icons.search, size: 20, color: _blueMuted),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(4),
            child: InkWell(
              onTap: _search,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration:
                const BoxDecoration(color: _blue, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward,
                    size: 16, color: Colors.white),
              ),
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _addressBox() {
    final hasAddress = _address.isNotEmpty && _error == null;
    final isError = _error != null;

    final Color bg = isError
        ? const Color(0xFFFEF2F2)
        : hasAddress
        ? const Color(0xFFF1F8F1)
        : const Color(0xFFF1F5FF);
    final Color border = isError
        ? const Color(0xFFFCA5A5)
        : hasAddress
        ? const Color(0xFFBFE3C0)
        : const Color(0xFFD3DFFB);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        if (_loading)
          const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5))
        else
          Icon(
            isError
                ? Icons.error
                : hasAddress
                ? Icons.check_circle
                : Icons.touch_app_outlined,
            color: isError
                ? Colors.red.shade600
                : hasAddress
                ? _green
                : _blue,
            size: 18,
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isError
                    ? _error!
                    : hasAddress
                    ? _address
                    : 'Tap on the map to pick a location',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isError ? Colors.red.shade700 : _navy,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buttons() {
    final canConfirm = _address.isNotEmpty && _error == null && !_loading;
    return Row(children: [
      Expanded(
        flex: 2,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: _blueMuted,
            side: const BorderSide(color: Color(0xFFC9D6F5)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Text('Cancel',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        flex: 5,
        child: ElevatedButton.icon(
          onPressed: canConfirm ? _confirm : null,
          icon: const Icon(Icons.location_on, size: 20),
          label: const Text('Confirm Location',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFCBD5E1),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    ]);
  }
}