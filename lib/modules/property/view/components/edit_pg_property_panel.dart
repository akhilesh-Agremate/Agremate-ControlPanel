import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/amenity_model.dart';
import '../../model/pg_property_detail_model.dart';
import 'add_property_panel.dart' show PickedFile;
import 'map_picker_dialog.dart';

class EditPgPropertyPanel extends StatefulWidget {
  final PgPropertyDetailData initial;
  final VoidCallback onBack;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;
  final List<AmenityModel> amenityOptions;
  final bool amenitiesLoading;

  const EditPgPropertyPanel({
    super.key,
    required this.initial,
    required this.onBack,
    required this.onSubmit,
    this.amenityOptions = const [],
    this.amenitiesLoading = false,
  });

  @override
  State<EditPgPropertyPanel> createState() => _EditPgPropertyPanelState();
}

class _EditPgPropertyPanelState extends State<EditPgPropertyPanel> {
  static const _blue = Color(0xFF2F6BFF);
  static const _line = Color(0xFFE2E8F0);
  static const _muted = Color(0xFF64748B);
  static const _surface = Color(0xFFF8FAFD);

  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  late final TextEditingController _nameC;
  late final TextEditingController _descC;
  late final TextEditingController _contractRefC;
  late final TextEditingController _extraPropsC;
  late final TextEditingController _addressC;
  late final TextEditingController _floorC;
  late final TextEditingController _doorC;
  late double? _lat;
  late double? _lng;
  late final TextEditingController _rentC;
  late final TextEditingController _advanceC;
  late final TextEditingController _landlordNameC;
  late final TextEditingController _landlordPhoneC;
  late final TextEditingController _landlordEmailC;
  late int _paymentDate;
  late int _bedrooms;
  late int _bathrooms;
  late int _kitchen;
  late int _builtYear;
  late int _zone;
  late int _status;
  String _activeFeatureTab = 'Bedrooms';
  late Set<String> _selectedAmenityIds;
  late List<String> _existingImageUrls;
  final List<PickedFile> _newPhotos = [];
  late List<Map<String, dynamic>> _existingDocs;
  final List<PickedFile> _newDocs = [];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    final raw = p.rawJson;
    final place = raw['placeDetails'] is Map
        ? Map<String, dynamic>.from(raw['placeDetails'])
        : <String, dynamic>{};

    _nameC = TextEditingController(text: p.name);
    _descC = TextEditingController(
        text: p.description.isNotEmpty
            ? p.description
            : (raw['description'] ?? '').toString());
    _contractRefC = TextEditingController(
        text: (p.contractReference ?? raw['contractReference'] ?? '')
            .toString());
    _extraPropsC = TextEditingController(
        text: (raw['extraProperties'] ?? '').toString());
    _addressC = TextEditingController(
        text: p.address.isNotEmpty
            ? p.address
            : (place['address'] ?? raw['address'] ?? '').toString());
    _floorC = TextEditingController(
        text: (p.floorNumber ??
                place['floor'] ??
                raw['floor'] ??
                raw['floorNumber'] ??
                '')
            .toString());
    _doorC = TextEditingController(
        text: (p.doorNumber ?? place['doorNumber'] ?? raw['doorNumber'] ?? '')
            .toString());
    _lat = p.latitude ??
        (place['latitude'] as num?)?.toDouble() ??
        (raw['latitude'] as num?)?.toDouble();
    _lng = p.longitude ??
        (place['longitude'] as num?)?.toDouble() ??
        (raw['longitude'] as num?)?.toDouble();

    final rentVal = p.rent > 0
        ? p.rent
        : ((raw['rent'] ?? raw['rentAmount']) as num?)?.toDouble() ?? 0;
    final advVal = p.advance > 0
        ? p.advance
        : ((raw['advance'] ?? raw['advanceAmount']) as num?)?.toDouble() ?? 0;
    _rentC = TextEditingController(
        text: rentVal > 0 ? rentVal.toStringAsFixed(0) : '');
    _advanceC = TextEditingController(
        text: advVal > 0 ? advVal.toStringAsFixed(0) : '');

    _landlordNameC =
        TextEditingController(text: p.landlord?.name ?? '');
    _landlordPhoneC =
        TextEditingController(text: p.landlord?.phone ?? '');
    _landlordEmailC =
        TextEditingController(text: p.landlord?.email ?? '');

    final payRaw = raw['rentPaymentDate'] ?? p.pgDetails?.rentPaymentDate;
    _paymentDate = payRaw is num
        ? payRaw.toInt()
        : int.tryParse('$payRaw') ?? 5;
    if (_paymentDate < 1 || _paymentDate > 31) _paymentDate = 5;

    _bedrooms = p.bedrooms > 0
        ? p.bedrooms
        : ((raw['bedrooms'] as num?)?.toInt() ?? 1);
    _bathrooms = p.bathrooms > 0
        ? p.bathrooms
        : ((raw['bathrooms'] as num?)?.toInt() ?? 1);
    _kitchen = p.kitchen > 0
        ? p.kitchen
        : ((raw['kitchen'] as num?)?.toInt() ?? 1);
    _builtYear = p.builtYear > 0
        ? p.builtYear
        : ((raw['builtYear'] as num?)?.toInt() ?? DateTime.now().year);
    _zone = int.tryParse('${raw['zone'] ?? p.zone ?? 1}') ?? 1;

    final st = raw['status'];
    if (st is num) {
      _status = st.toInt();
    } else {
      final t = '${p.status}'.toLowerCase();
      _status = t.contains('rent') ? 1 : 0;
    }

    _selectedAmenityIds = <String>{};
    _existingImageUrls =
        List<String>.from(p.photoPaths.where((u) => u.isNotEmpty));
    _existingDocs = p.documents
        .map((d) => {
              'fileName': d.documentName,
              'absolutePath': d.fileUrl,
              'relativePath': '',
              'thumbnailUrl': '',
              'originalUrl': d.fileUrl,
              'uploadedTime': '',
              'isDeletable': true,
            })
        .toList();
    _prefillAmenities();
  }

  @override
  void didUpdateWidget(covariant EditPgPropertyPanel old) {
    super.didUpdateWidget(old);
    if (widget.amenityOptions.isNotEmpty &&
        (old.amenityOptions.isEmpty || _selectedAmenityIds.isEmpty)) {
      _prefillAmenities(rebuild: true);
    }
  }

  void _prefillAmenities({bool rebuild = false}) {
    if (widget.amenityOptions.isEmpty) return;
    final raw = widget.initial.rawJson;
    final ids = <String>{};

    if (raw['amenityIds'] is List) {
      for (final id in raw['amenityIds']) {
        final sId = id?.toString().trim() ?? '';
        if (sId.isNotEmpty &&
            widget.amenityOptions.any((a) => a.id == sId)) {
          ids.add(sId);
        }
      }
    }

    final amenityLists = <dynamic>[
      ...(raw['amenities'] is List ? raw['amenities'] as List : const []),
      ...widget.initial.amenities,
    ];
    for (final item in amenityLists) {
      if (item is Map) {
        final id = (item['id'] ?? item['amenityId'] ?? '').toString().trim();
        final name = (item['name'] ?? item['amenityName'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        for (final a in widget.amenityOptions) {
          if ((id.isNotEmpty && a.id == id) ||
              (name.isNotEmpty && a.name.trim().toLowerCase() == name)) {
            ids.add(a.id);
          }
        }
      } else if (item != null) {
        final str = item.toString().trim().toLowerCase();
        for (final a in widget.amenityOptions) {
          if (a.id == item.toString().trim() ||
              a.name.trim().toLowerCase() == str) {
            ids.add(a.id);
          }
        }
      }
    }

    for (final name in widget.initial.amenityLabels) {
      final n = name.trim().toLowerCase();
      for (final a in widget.amenityOptions) {
        if (a.name.trim().toLowerCase() == n) ids.add(a.id);
      }
    }

    if (ids.isEmpty) return;
    _selectedAmenityIds.addAll(ids);
    if (rebuild && mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [
      _nameC, _descC, _contractRefC, _extraPropsC,
      _addressC, _floorC, _doorC, _rentC, _advanceC,
      _landlordNameC, _landlordPhoneC, _landlordEmailC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int _intVal(TextEditingController c) =>
      int.tryParse(c.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

  Future<void> _pickLocation() async {
    final r = await showMapPicker(context, lat: _lat, lng: _lng);
    if (r == null) return;
    setState(() {
      _addressC.text = r.address;
      _lat = r.latitude;
      _lng = r.longitude;
    });
  }

  Future<List<PickedFile>> _readAll(List<PlatformFile> files) async {
    final out = <PickedFile>[];
    for (final f in files) {
      out.add(PickedFile(name: f.name, extension: f.extension, bytes: await f.readAsBytes()));
    }
    return out;
  }

  Future<void> _pickPhotos() async {
    try {
      final res = await FilePicker.pickFiles(type: FileType.image);
      if (res.isEmpty) return;
      final picked = await _readAll(res);
      if (!mounted) return;
      setState(() => _newPhotos.addAll(picked));
    } catch (e) {
      Get.snackbar('Picker error', '$e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amenitiesList = _selectedAmenityIds.map((id) {
      final match = widget.amenityOptions.firstWhereOrNull((a) => a.id == id);
      return {'id': id, 'name': match?.name ?? ''};
    }).toList();

    final data = <String, dynamic>{
      'name': _nameC.text.trim(),
      'description': _descC.text.trim(),
      'status': _status,
      'rent': _intVal(_rentC),
      'advance': _intVal(_advanceC),
      'rentPaymentDate': _paymentDate,
      'bedrooms': _bedrooms,
      'bathrooms': _bathrooms,
      'kitchen': _kitchen,
      'builtYear': _builtYear,
      'zone': _zone,
      'contractReference': _contractRefC.text.trim(),
      'extraProperties':
          _extraPropsC.text.trim().isEmpty ? null : _extraPropsC.text.trim(),
      'isSelfOwned': true,
      'address': _addressC.text.trim(),
      'latitude': _lat ?? 0.0,
      'longitude': _lng ?? 0.0,
      'floor': _floorC.text.trim().isNotEmpty ? _floorC.text.trim() : 'Ground Floor',
      'doorNumber': _doorC.text.trim(),
      'amenities': amenitiesList,
      'existingImages': _existingImageUrls,
      'existingDocuments': _existingDocs,
      'photos': _newPhotos,
      'documents': _newDocs,
    };

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(data);
      widget.onBack();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update PG property: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _surface,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: _line),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(builder: (context, c) {
                  final isDesktop = c.maxWidth >= 900;
                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _leftColumn()),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: _rightColumn()),
                      ],
                    );
                  }
                  return Column(children: [
                    _leftColumn(),
                    const SizedBox(height: 24),
                    _rightColumn(),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            tooltip: 'Back',
            style: IconButton.styleFrom(foregroundColor: _muted),
          ),
          const SizedBox(width: 8),
          const Text(
            'Update Property',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2340)),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: _submitting ? null : widget.onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: _muted,
              side: const BorderSide(color: _line),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Update',
                    style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _leftColumn() {
    return Column(children: [
      _card(
        title: 'Landlord Details',
        icon: Icons.person_outline_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labeledField('Name', _landlordNameC, hint: 'Landlord name'),
            const SizedBox(height: 12),
            _labeledField('Phone Number', _landlordPhoneC,
                hint: 'Phone Number', keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            _labeledField('Email', _landlordEmailC,
                hint: 'Email', keyboard: TextInputType.emailAddress),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _card(
        title: 'Property Photos',
        icon: Icons.photo_library_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Photos',
                style: TextStyle(fontSize: 13, color: _muted)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._existingImageUrls.asMap().entries.map((e) =>
                    _photoThumb(e.value,
                        onRemove: () =>
                            setState(() => _existingImageUrls.removeAt(e.key)))),
                ..._newPhotos.asMap().entries.map((e) => _newPhotoThumb(e.value,
                    onRemove: () =>
                        setState(() => _newPhotos.removeAt(e.key)))),
                _addPhotoButton(),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _card(
        title: 'Property Info',
        icon: Icons.apartment_rounded,
        child: Column(children: [
          _labeledField('Property Name *', _nameC,
              hint: 'Enter PG name',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null),
          const SizedBox(height: 12),
          _labeledField('Description', _descC,
              hint: 'Short description', maxLines: 3),
          const SizedBox(height: 12),
          _labeledField('Contract Reference', _contractRefC,
              hint: 'e.g. SUN-PG-2026'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _labeledField('Rent (Rs.)', _rentC,
                    hint: '0', keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: _labeledField('Advance (Rs.)', _advanceC,
                    hint: '0', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          _dropdownField(
            'Rent Payment Date',
            _paymentDate,
            List.generate(31, (i) => i + 1),
            (v) => setState(() => _paymentDate = v ?? _paymentDate),
          ),
          const SizedBox(height: 12),
          _labeledField('Extra Properties', _extraPropsC,
              hint: 'CCTV, power backup...'),
        ]),
      ),
      const SizedBox(height: 20),
      _locationCard(),
    ]);
  }

  Widget _rightColumn() {
    return Column(children: [
      _featuresCard(),
      const SizedBox(height: 20),
      _amenitiesCard(),
    ]);
  }

  Widget _featuresCard() {
    return _card(
      title: 'Features',
      icon: Icons.tune_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Bathrooms', 'Bedrooms', 'Built-in Year', 'Kitchen']
                .map((tab) {
              final active = _activeFeatureTab == tab;
              return GestureDetector(
                onTap: () => setState(() => _activeFeatureTab = tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? _blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? _blue : _line),
                  ),
                  child: Text(tab,
                      style: TextStyle(
                          color: active ? Colors.white : _muted,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _featureSelector(),
        ],
      ),
    );
  }

  Widget _featureSelector() {
    switch (_activeFeatureTab) {
      case 'Bedrooms':
        return _dropdownField('Bedrooms', _bedrooms,
            List.generate(20, (i) => i + 1),
            (v) => setState(() => _bedrooms = v!));
      case 'Bathrooms':
        return _dropdownField('Bathrooms', _bathrooms,
            List.generate(20, (i) => i + 1),
            (v) => setState(() => _bathrooms = v!));
      case 'Kitchen':
        return _dropdownField('Kitchen', _kitchen,
            List.generate(5, (i) => i + 1),
            (v) => setState(() => _kitchen = v!));
      case 'Built-in Year':
        return _dropdownField(
            'Built-in Year',
            _builtYear,
            List.generate(50, (i) => DateTime.now().year - i),
            (v) => setState(() => _builtYear = v!));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _dropdownField(String label, int value, List<int> options,
      ValueChanged<int?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: options.contains(value) ? value : options.first,
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text('$o')))
              .toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(label),
        ),
      ],
    );
  }

  Widget _amenitiesCard() {
    return _card(
      title: 'Amenities',
      icon: Icons.star_outline_rounded,
      child: widget.amenitiesLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.amenityOptions.map((a) {
                final selected = _selectedAmenityIds.contains(a.id);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedAmenityIds.remove(a.id);
                    } else {
                      _selectedAmenityIds.add(a.id);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFEEF4FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? _blue : const Color(0xFFD6E8FA),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(a.name,
                        style: TextStyle(
                            color: selected ? _blue : _muted,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _locationCard() {
    return _card(
      title: 'Location',
      icon: Icons.location_on_outlined,
      child: Column(children: [
        _labeledField('Address', _addressC, hint: 'Full address'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _labeledField('Floor', _floorC,
                  hint: 'e.g. 2nd Floor')),
          const SizedBox(width: 12),
          Expanded(
              child:
                  _labeledField('Door Number', _doorC, hint: 'e.g. 42')),
        ]),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickLocation,
          icon: const Icon(Icons.map_outlined, size: 16),
          label: const Text('Pick on Map'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _blue,
            side: const BorderSide(color: _blue),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
        if (_lat != null && _lng != null) ...[
          const SizedBox(height: 8),
          Text('$_lat, $_lng',
              style: const TextStyle(fontSize: 12, color: _muted)),
        ],
      ]),
    );
  }

  Widget _card(
      {required String title,
      required IconData icon,
      required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: _blue),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2340))),
          ]),
          const SizedBox(height: 16),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, color: _muted, fontWeight: FontWeight.w500));

  Widget _readOnlyField(String value, {String hint = ''}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: _inputDecoration(hint),
      style: const TextStyle(color: _muted, fontSize: 14),
    );
  }

  Widget _labeledField(
    String label,
    TextEditingController c, {
    String hint = '',
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 4),
          TextFormField(
            controller: c,
            maxLines: maxLines,
            keyboardType: keyboard,
            validator: validator,
            decoration: _inputDecoration(hint),
            style:
                const TextStyle(fontSize: 14, color: Color(0xFF1A2340)),
          ),
        ]);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFFB0BAC9), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _line)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _line)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _blue, width: 1.5)),
    );
  }

  Widget _photoThumb(String url, {required VoidCallback onRemove}) {
    return Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(url,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
                width: 90, height: 90, color: const Color(0xFFEEF4FF))),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.black54, shape: BoxShape.circle),
            padding: const EdgeInsets.all(3),
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ),
      ),
    ]);
  }

  Widget _newPhotoThumb(PickedFile f, {required VoidCallback onRemove}) {
    return Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 90,
          height: 90,
          color: const Color(0xFFEEF4FF),
          child:
              const Icon(Icons.image_outlined, color: _blue, size: 32),
        ),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.black54, shape: BoxShape.circle),
            padding: const EdgeInsets.all(3),
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ),
      ),
    ]);
  }

  Widget _addPhotoButton() {
    return GestureDetector(
      onTap: _pickPhotos,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(color: _line, width: 1.5),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFF8FAFD),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.add_rounded, color: _muted, size: 28)],
        ),
      ),
    );
  }
}
