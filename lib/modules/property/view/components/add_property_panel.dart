import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/amenity_model.dart';
import '../../model/property_model.dart';
import 'map_picker_dialog.dart';
import 'package:agremate_admin/core/widgets/web_network_image.dart';

class PickedFile {
  final String name;
  final String? extension;
  final Uint8List bytes;
  const PickedFile({
    required this.name,
    required this.extension,
    required this.bytes,
  });
}

class AddPropertyPanel extends StatefulWidget {
  final VoidCallback onBack;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;
  final List<AmenityModel> amenityOptions;
  final bool amenitiesLoading;
  final List<AmenityModel> featureOptions;
  final bool featuresLoading;
  final PropertyModel? initial;
  const AddPropertyPanel({
    super.key,
    required this.onBack,
    required this.onSubmit,
    this.amenityOptions = const [],
    this.amenitiesLoading = false,
    this.featureOptions = const [],
    this.featuresLoading = false,
    this.initial,
  });

  @override
  State<AddPropertyPanel> createState() => _AddPropertyPanelState();
}

class _AddPropertyPanelState extends State<AddPropertyPanel> {
  static const _blue = Color(0xFF2F6BFF);
  static const _lightBlue = Color(0xFFEAF1FF);
  static const _line = Color(0xFFE2E8F0);
  static const _muted = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final descC = TextEditingController();
  final doorC = TextEditingController();
  final floorC = TextEditingController();
  final addressC = TextEditingController();
  double? latitude, longitude;

  String? propertyType;
  static const propertyTypes = ['Individual', 'PG'];

  final advanceC = TextEditingController();
  final rentC = TextEditingController();
  int? paymentDate;

  bool hasTenant = true;
  final tenantNameC = TextEditingController();
  final tenantPhoneC = TextEditingController();
  final tenantEmailC = TextEditingController();
  final startDateC = TextEditingController();
  DateTime? _startDate;
  final landlordNameC = TextEditingController();
  final landlordPhoneC = TextEditingController();
  final landlordEmailC = TextEditingController();
  final Set<String> selectedFeatures = {};
  int? bedrooms, bathrooms, kitchens, builtYear;
  final Set<String> selectedAmenityIds = {};
  final poolFromC = TextEditingController();
  final poolToC = TextEditingController();
  final poolCommentC = TextEditingController();
  final gymFromC = TextEditingController();
  final gymToC = TextEditingController();
  final gymCommentC = TextEditingController();
  final List<PickedFile> photos = [];
  final List<PickedFile> documents = [];
  static const int _maxDocs = 5;

  bool _submitting = false;

  bool get _isEdit => widget.initial != null;
  final List<String> existingPhotoUrls = [];
  final List<Map<String, dynamic>> existingDocs = [];

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _prefill(widget.initial!);
      _prefillAmenities();
    }
  }

  @override
  void didUpdateWidget(covariant AddPropertyPanel old) {
    super.didUpdateWidget(old);
    if (_isEdit && old.amenityOptions.isEmpty && widget.amenityOptions.isNotEmpty) {
      _prefillAmenities();
    }
  }

  String _tenDigits(String? v) {
    final d = (v ?? '').replaceAll(RegExp(r'[^\d]'), '');
    return d.length > 10 ? d.substring(d.length - 10) : d;
  }

  String _fmtAmount(num v) =>
      v <= 0 ? '' : NumberFormat.decimalPattern('en_IN').format(v.round());

  void _prefill(PropertyModel p) {
    final raw = p.rawJson;
    final place = raw['placeDetails'] is Map
        ? Map<String, dynamic>.from(raw['placeDetails'])
        : <String, dynamic>{};

    nameC.text = p.name;
    descC.text = p.description ?? '';
    addressC.text = p.address.address;
    if (p.address.latitude != 0) latitude = p.address.latitude;
    if (p.address.longitude != 0) longitude = p.address.longitude;
    doorC.text = (place['doorNumber'] ?? raw['doorNumber'] ?? '').toString();
    floorC.text = (place['floor'] ?? raw['floor'] ?? raw['floorNumber'] ?? '').toString();

    final t = raw['propertyType']?.toString().trim().toLowerCase() ?? '';
    final idx = int.tryParse(t) ??
        propertyTypes.indexWhere((e) => e.toLowerCase() == t);
    if (idx >= 0 && idx < propertyTypes.length) propertyType = propertyTypes[idx];

    landlordNameC.text = p.landlordName == 'N/A' ? '' : p.landlordName;
    landlordPhoneC.text = _tenDigits(p.landlordPhone);
    landlordEmailC.text = p.landlordEmail ?? '';

    if (p.bedrooms > 0) { selectedFeatures.add('Bedrooms'); bedrooms = p.bedrooms; }
    if (p.bathrooms > 0) { selectedFeatures.add('Bathrooms'); bathrooms = p.bathrooms; }
    if (p.kitchen > 0) { selectedFeatures.add('Kitchen'); kitchens = p.kitchen; }
    if (p.builtYear > 0) { selectedFeatures.add('Built Year'); builtYear = p.builtYear; }

    advanceC.text = _fmtAmount(p.advanceAmount);
    rentC.text = _fmtAmount(p.rentAmount);
    final d = (raw['rentPaymentDate'] as num?)?.toInt();
    if (d != null && d >= 1 && d <= 30) paymentDate = d;

    hasTenant = (p.primaryTenantName ?? '').isNotEmpty;
    tenantNameC.text = p.primaryTenantName ?? '';
    tenantPhoneC.text = _tenDigits(p.primaryTenantPhone);
    tenantEmailC.text = p.primaryTenantEmail ?? '';
    if (p.tenancyStartDate != null) {
      _startDate = p.tenancyStartDate;
      startDateC.text = DateFormat('dd/MMM/yyyy').format(_startDate!).toUpperCase();
    }

    existingPhotoUrls.addAll(p.images);
    for (final doc in p.documents) {
      if (doc is Map) existingDocs.add(Map<String, dynamic>.from(doc));
    }
  }

  void _prefillAmenities() {
    final p = widget.initial;
    if (p == null || widget.amenityOptions.isEmpty) return;
    for (final item in p.amenitiesList) {
      final name = (item['name'] ?? '').toLowerCase();
      final matches = widget.amenityOptions.where((a) => a.name.toLowerCase() == name);
      if (matches.isEmpty) continue;
      final a = matches.first;
      selectedAmenityIds.add(a.id);
      final m = RegExp(r'^(.*?) - (.*?)(?:\. (.*))?$').firstMatch(item['details'] ?? '');
      if (m == null) continue;
      if (a.isPool) {
        poolFromC.text = m.group(1)!.trim();
        poolToC.text = m.group(2)!.trim();
        poolCommentC.text = m.group(3) ?? '';
      } else if (a.isGym) {
        gymFromC.text = m.group(1)!.trim();
        gymToC.text = m.group(2)!.trim();
        gymCommentC.text = m.group(3) ?? '';
      }
    }
  }

  List<AmenityModel> get _selectedAmenities => widget.amenityOptions
      .where((a) => selectedAmenityIds.contains(a.id))
      .toList();
  bool get _poolOn => _selectedAmenities.any((a) => a.isPool);
  bool get _gymOn => _selectedAmenities.any((a) => a.isGym);

  @override
  void dispose() {
    for (final c in [
      nameC,
      descC,
      doorC,
      floorC,
      addressC,
      advanceC,
      rentC,
      tenantNameC,
      tenantPhoneC,
      tenantEmailC,
      startDateC,
      poolFromC,
      poolToC,
      poolCommentC,
      gymFromC,
      gymToC,
      gymCommentC,
      landlordNameC,
      landlordPhoneC,
      landlordEmailC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    debugPrint('address field tapped');
    final r = await showMapPicker(context, lat: latitude, lng: longitude);
    if (r == null) return;
    setState(() {
      addressC.text = r.address;
      latitude = r.latitude;
      longitude = r.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8FAFD),
      child: Column(
        children: [
          _header(),
          const Divider(height: 1, color: _line),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final left = _leftColumn();
                    final right = _rightColumn();
                    if (c.maxWidth < 900) {
                      return Column(children: [...left, ...right]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Column(children: left)),
                        const SizedBox(width: 24),
                        Expanded(child: Column(children: right)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            _isEdit ? 'Update Property' : 'Create Property',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: _submitting ? null : widget.onBack,
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child:
                _submitting
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Text(_isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Missing details', 'Please fix the highlighted fields.');
      return;
    }
    final data = <String, dynamic>{
      'name': nameC.text.trim(),
      'description': descC.text.trim(),
      'landlord': {
        'name': landlordNameC.text.trim(),
        'phone': landlordPhoneC.text.trim(),
        'email': landlordEmailC.text.trim(),
      },
      'propertyType':
          propertyType == null ? 0 : propertyTypes.indexOf(propertyType!),
      'doorNumber': doorC.text.trim(),
      'floorNumber': floorC.text.trim(),
      'address': addressC.text.trim(),
      'latitude': latitude ?? 0,
      'longitude': longitude ?? 0,
      'features': {
        if (selectedFeatures.contains('Bedrooms')) 'bedrooms': bedrooms,
        if (selectedFeatures.contains('Bathrooms')) 'bathrooms': bathrooms,
        if (selectedFeatures.contains('Kitchen')) 'kitchens': kitchens,
        if (selectedFeatures.contains('Built Year')) 'builtYear': builtYear,
      },
      'amenities': _selectedAmenities
          .map((a) => {'id': a.id, 'name': a.name})
          .toList(),
      if (_poolOn)
        'pool': {
          'from': poolFromC.text,
          'to': poolToC.text,
          'comment': poolCommentC.text.trim(),
        },
      if (_gymOn)
        'gym': {
          'from': gymFromC.text,
          'to': gymToC.text,
          'comment': gymCommentC.text.trim(),
        },
      'advance': _amount(advanceC.text),
      'rent': _amount(rentC.text),
      'rentPaymentDate': paymentDate,
      if (hasTenant)
        'tenant': {
          'name': tenantNameC.text.trim(),
          'phone': tenantPhoneC.text.trim(),
          'email': tenantEmailC.text.trim(),
          'startDate':
              _startDate == null
                  ? null
                  : DateFormat('yyyy-MM-dd').format(_startDate!),
        },
      'photos': photos,
      'documents': documents,
      'existingImages': List<String>.from(existingPhotoUrls),
      'existingDocuments': existingDocs,
    };

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(data);
      widget.onBack();
    } catch (e) {
      Get.snackbar('Error', 'Failed to ${_isEdit ? 'update' : 'create'} property: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  List<Widget> _leftColumn() => [
    _card(
      icon: Icons.person_pin_outlined,
      title: 'Landlord Details',
      child: Column(
        children: [
          _field(
            'Name',
            'Name',
            landlordNameC,
            validator: (v) => _required(v, 'Landlord Name'),
          ),
          const SizedBox(height: 12),
          _field(
            'Phone Number',
            'Phone Number',
            landlordPhoneC,
            prefix: '+91 ',
            keyboard: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              final r = _required(v, 'Phone Number');
              if (r != null) return r;
              return v!.length == 10 ? null : 'Enter a 10-digit number';
            },
          ),
          const SizedBox(height: 12),
          _field(
            'Email',
            'Email',
            landlordEmailC,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              return GetUtils.isEmail(v.trim()) ? null : 'Enter a valid email';
            },
          ),
        ],
      ),
    ),
    _card(
      icon: Icons.photo_library_outlined,
      title: 'Property Photos',
      child: _fileGrid(
        label: 'Add Photos',
        files: photos,
        onAdd: _pickPhotos,
        onRemove: (i) => setState(() => photos.removeAt(i)),
        isImage: true,
        existingUrls: existingPhotoUrls,
        onRemoveExisting: (i) => setState(() => existingPhotoUrls.removeAt(i)),
      ),
    ),
    _card(
      icon: Icons.info_outline_rounded,
      title: 'Property Details',
      child: Column(
        children: [
          _field(
            'Property Name',
            'Property Name',
            nameC,
            validator: (v) => _required(v, 'Property Name'),
          ),
          const SizedBox(height: 12),
          _field(
            'Property Description',
            'Property Description',
            descC,
            validator: (v) => _required(v, 'Property Description'),
          ),
          const SizedBox(height: 12),
          _dropdownBox<String>(
            'Property Type',
            propertyType,
            propertyTypes,
            (v) => setState(() => propertyType = v),
            hint: 'Select',
          ),
        ],
      ),
    ),
    _card(
      icon: Icons.location_on_outlined,
      title: 'Property Address',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _field('Door number', 'e.g. 309', doorC)),
              const SizedBox(width: 20),
              Expanded(child: _field('Floor number', 'e.g. 3', floorC)),
            ],
          ),
          const SizedBox(height: 12),
          _field(
            'Property Address',
            'Full address including flat no., building, street',
            addressC,
            maxLines: 1,
            readOnly: true,
            onTap: _pickLocation,
            suffix:
                addressC.text.isNotEmpty
                    ? IconButton(
                      onPressed: _pickLocation,
                      icon: const Icon(
                        Icons.location_on_outlined,
                        size: 26,
                        color: _blue,
                      ),
                    )
                    : null,
            validator: (v) => _required(v, 'Property Address'),
          ),
          const SizedBox(height: 12),

          _hintBox(
            'Add the full address and include the door number at the beginning (e.g., #309 3rd Floor)',
          ),
        ],
      ),
    ),
  ];

  List<Widget> _rightColumn() => [
    _card(
      icon: Icons.tune_outlined,
      title: 'Features',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.featuresLoading && widget.featureOptions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (widget.featureOptions.isEmpty)
            const Text('No features available',
                style: TextStyle(color: _muted))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.featureOptions
                  .where((f) => f.featureKey != null)
                  .map((f) {
                final key = f.featureKey!;
                return _chip(f.name, selectedFeatures.contains(key), (v) {
                  setState(() => v
                      ? selectedFeatures.add(key)
                      : selectedFeatures.remove(key));
                });
              }).toList(),
            ),
          if (selectedFeatures.contains('Bedrooms') ||
              selectedFeatures.contains('Bathrooms')) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedFeatures.contains('Bedrooms'))
                  Expanded(
                    child: _dropdownBox<int>(
                      'Bedrooms',
                      bedrooms,
                      List.generate(10, (i) => i + 1),
                      (v) => setState(() => bedrooms = v),
                    ),
                  ),
                if (selectedFeatures.contains('Bedrooms') &&
                    selectedFeatures.contains('Bathrooms'))
                  const SizedBox(width: 12),
                if (selectedFeatures.contains('Bathrooms'))
                  Expanded(
                    child: _dropdownBox<int>(
                      'Bathrooms',
                      bathrooms,
                      List.generate(10, (i) => i + 1),
                      (v) => setState(() => bathrooms = v),
                    ),
                  ),
              ],
            ),
          ],
          if (selectedFeatures.contains('Kitchen') ||
              selectedFeatures.contains('Built Year')) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedFeatures.contains('Kitchen'))
                  Expanded(
                    child: _dropdownBox<int>(
                      'Kitchen',
                      kitchens,
                      List.generate(5, (i) => i + 1),
                      (v) => setState(() => kitchens = v),
                    ),
                  ),
                if (selectedFeatures.contains('Kitchen') &&
                    selectedFeatures.contains('Built Year'))
                  const SizedBox(width: 12),
                if (selectedFeatures.contains('Built Year'))
                  Expanded(
                    child: _dropdownBox<int>(
                      'Built in Year',
                      builtYear,
                      List.generate(50, (i) => DateTime.now().year - i),
                      (v) => setState(() => builtYear = v),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
    _card(
      icon: Icons.star_outline,
      title: 'Amenities',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.amenitiesLoading && widget.amenityOptions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (widget.amenityOptions.isEmpty)
            const Text('No amenities available',
                style: TextStyle(color: _muted))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.amenityOptions.map((a) {
                final chip = _chip(a.name, selectedAmenityIds.contains(a.id),
                        (v) {
                      setState(() => v
                          ? selectedAmenityIds.add(a.id)
                          : selectedAmenityIds.remove(a.id));
                    });
                return a.description.isEmpty
                    ? chip
                    : Tooltip(message: a.description, child: chip);
              }).toList(),
            ),
          if (_poolOn)
            _timingBlock(
              'Pool Timing',
              poolFromC,
              poolToC,
              poolCommentC,
              'Pool',
            ),
          if (_gymOn)
            _timingBlock('Gym Timing', gymFromC, gymToC, gymCommentC, 'Gym'),
        ],
      ),
    ),
    _card(
      icon: Icons.currency_rupee,
      title: 'Pricing',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _field(
                  'Advance',
                  'advance',
                  advanceC,
                  prefix: '₹ ',
                  keyboard: TextInputType.number,
                  formatters: [_IndianAmountFormatter()],
                  validator: (v) => _required(v, 'Advance'),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _field(
                  'Rent',
                  'Rent',
                  rentC,
                  prefix: '₹ ',
                  keyboard: TextInputType.number,
                  formatters: [_IndianAmountFormatter()],
                  validator: (v) => _required(v, 'Rent'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _dropdownBox<int>(
                  'Rent Payment Date',
                  paymentDate,
                  List.generate(30, (i) => i + 1),
                  (v) => setState(() => paymentDate = v),
                  hint: 'Select',
                  height: 40,
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    ),
    _card(
      icon: Icons.person_outline,
      title: 'Tenant Details',
      trailing: Switch(
        value: hasTenant,
        activeColor: Colors.white,
        activeTrackColor: _blue,
        onChanged: (v) => setState(() => hasTenant = v),
      ),
      hideBody: !hasTenant,
      child: Column(
        children: [
          _field(
            'Name',
            'Name',
            tenantNameC,
            validator: (v) => hasTenant ? _required(v, 'Name') : null,
          ),
          const SizedBox(height: 12),
          _field(
            'Phone Number',
            'Phone Number',
            tenantPhoneC,
            prefix: '+91 ',
            keyboard: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (!hasTenant) return null;
              final r = _required(v, 'Phone Number');
              if (r != null) return r;
              return v!.length == 10 ? null : 'Enter a 10-digit number';
            },
          ),
          const SizedBox(height: 12),
          _field(
            'Email',
            'Email',
            tenantEmailC,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (!hasTenant || v == null || v.trim().isEmpty) return null;
              return GetUtils.isEmail(v.trim()) ? null : 'Enter a valid email';
            },
          ),
          const SizedBox(height: 12),
          _field(
            'Tenancy Start Date',
            'Tenancy Start Date',
            startDateC,
            readOnly: true,
            suffix: const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: _muted,
            ),
            onTap: _pickDate,
          ),
        ],
      ),
    ),
    _card(
      icon: Icons.description_outlined,
      title: 'Documents',
      child: _fileGrid(
        label: 'Add Documents',
        files: documents,
        onAdd: _pickDocuments,
        onRemove: (i) => setState(() => documents.removeAt(i)),
        isImage: false,
        existingUrls: existingDocs.map((d) => (d['url'] ?? d['documentUrl'] ?? '').toString()).toList(),
        onRemoveExisting: (i) => setState(() => existingDocs.removeAt(i)),
      ),
    ),
  ];

  Future<List<PickedFile>> _readAll(List<PlatformFile> files) async {
    final out = <PickedFile>[];
    for (final f in files) {
      out.add(
        PickedFile(
          name: f.name,
          extension: f.extension,
          bytes: await f.readAsBytes(),
        ),
      );
    }
    return out;
  }

  Future<void> _pickPhotos() async {
    try {
      final res = await FilePicker.pickFiles(type: FileType.image);
      if (res.isEmpty) return;
      final picked = await _readAll(res);
      if (!mounted) return;
      setState(() => photos.addAll(picked));
    } catch (e, st) {
      debugPrint('Pick photos failed: $e\n$st');
      Get.snackbar('Could not open file picker', '$e');
    }
  }

  Future<void> _pickDocuments() async {
    final remaining = _maxDocs - documents.length;
    if (remaining <= 0) {
      Get.snackbar('Limit reached', 'You can add up to $_maxDocs documents.');
      return;
    }
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (res.isEmpty) return;
      final picked = await _readAll(res.take(remaining).toList());
      if (!mounted) return;
      setState(() => documents.addAll(picked));
    } catch (e, st) {
      debugPrint('Pick documents failed: $e\n$st');
      Get.snackbar('Could not open file picker', '$e');
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Tenancy Start Date',
    );
    if (d != null) {
      _startDate = d;
      startDateC.text =
          DateFormat('dd/MMM/yyyy').format(d).toUpperCase();
    }
  }

  Future<void> _pickTime(TextEditingController c, String help) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: help,
    );
    if (t != null && mounted) c.text = t.format(context);
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  Widget _timingBlock(
    String title,
    TextEditingController from,
    TextEditingController to,
    TextEditingController comment,
    String name,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _field(
                  '$name Timing From',
                  'Select time',
                  from,
                  readOnly: true,
                  suffix: const Icon(
                    Icons.access_time,
                    size: 20,
                    color: _muted,
                  ),
                  onTap: () => _pickTime(from, '$name Timing From'),
                  validator: (v) => _required(v, '$name Timing From'),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _field(
                  '$name Timing To',
                  'Select time',
                  to,
                  readOnly: true,
                  suffix: const Icon(
                    Icons.access_time,
                    size: 20,
                    color: _muted,
                  ),
                  onTap: () => _pickTime(to, '$name Timing To'),
                  validator: (v) => _required(v, '$name Timing To'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field(
            '$name Additional Comment',
            '$name Additional Comment',
            comment,
            validator: (v) => _required(v, '$name Additional Comment'),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
    bool hideBody = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF1F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, trailing != null ? 8 : 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          if (!hideBody) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(padding: const EdgeInsets.all(16), child: child),
          ],
        ],
      ),
    );
  }

  Widget _labeled(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
      ),
      const SizedBox(height: 6),
      child,
    ],
  );

  Widget _field(
    String label,
    String hint,
    TextEditingController c, {
    int maxLines = 1,
    String? prefix,
    Widget? suffix,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return _labeled(
      label,
      TextFormField(
        controller: c,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboard,
        inputFormatters: formatters,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8),fontSize: 14),
          prefixText: prefix,
          prefixStyle: const TextStyle(color: Colors.black, fontSize: 14),
          suffixIcon: suffix,
          isDense: true,
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: _line),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _line),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _blue),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _dropdownBox<T>(
      String label,
      T? value,
      List<T> items,
      ValueChanged<T?> onChanged, {
        String hint = 'Select',
        double? height,
      }) {
    final list = (value != null && !items.contains(value)) ? [...items, value] : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300] ?? Colors.grey),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(hint),
              isExpanded: true,
              isDense: height != null,
              menuMaxHeight: 220,
              items:list
                      .map(
                        (e) => DropdownMenuItem<T>(value: e, child: Text('$e', style: const TextStyle(fontSize: 14))),
                      )
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: _lightBlue,
      labelStyle: TextStyle(
        fontSize: 13,
        color: selected ? _blue : const Color(0xFF334155),
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: selected ? _blue : const Color(0xFF94A3B8)),
      ),
      onSelected: onSelected,
    );
  }

  Widget _hintBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC7D7FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: _blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileGrid({
    required String label,
    required List<PickedFile> files,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required bool isImage,
    List<String> existingUrls = const [],
    void Function(int)? onRemoveExisting,
    String? helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              helper,
              style: const TextStyle(fontSize: 13, color: _muted),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (existingUrls.isNotEmpty)
              for (var i = 0; i < existingUrls.length; i++)
                _existingFileTile(existingUrls[i], isImage, () => onRemoveExisting?.call(i)),
            for (var i = 0; i < files.length; i++)
              _fileTile(files[i], isImage, () => onRemove(i)),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onAdd,
              child: Container(
                width: 110,
                height: 140,
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _blue.withValues(alpha: 0.7)),
                ),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fileTile(PickedFile f, bool isImage, VoidCallback onRemove) {
    final canPreview =
        isImage ||
        ['jpg', 'jpeg', 'png'].contains((f.extension ?? '').toLowerCase());
    return Stack(
      children: [
        Container(
          width: 110,
          height: 140,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _line),
          ),
          child:
              canPreview
                  ? Image.memory(f.bytes, fit: BoxFit.cover)
                  : Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.insert_drive_file_outlined,
                          size: 32,
                          color: _blue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          f.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _existingFileTile(String url, bool isImage, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 110,
          height: 140,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _line),
          ),
          child:
              isImage
                  ? WebNetworkImage(url: url, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insert_drive_file_outlined,
                          size: 32,
                          color: _blue,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Document',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _IndianAmountFormatter extends TextInputFormatter {
  final _fmt = NumberFormat.decimalPattern('en_IN');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final text = _fmt.format(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

int _amount(String s) => int.tryParse(s.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
