import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../model/amenity_model.dart';
import '../../model/pg_property_detail_model.dart';
import 'add_property_panel.dart' show PickedFile;
import 'map_picker_dialog.dart';

class CreatePgPropertyPanel extends StatefulWidget {
  final VoidCallback onBack;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;
  final List<AmenityModel> amenityOptions;
  final bool amenitiesLoading;
  final PgPropertyDetailData? initial;

  const CreatePgPropertyPanel({
    super.key,
    required this.onBack,
    required this.onSubmit,
    this.amenityOptions = const [],
    this.amenitiesLoading = false,
    this.initial,
  });

  @override
  State<CreatePgPropertyPanel> createState() => _CreatePgPropertyPanelState();
}

class _PgBedDraft {
  String bedNumber;
  bool isOccupied = false;
  String tenantName = '';
  String tenantPhone = '';
  String tenantEmail = '';
  DateTime? tenantStart;
  int? rent;
  int? advance;

  _PgBedDraft({required this.bedNumber});
}

class _PgRoomDraft {
  String id;
  String name;
  int sharingType;
  int? rentOverride;
  int? advanceOverride;
  List<String> roomAmenities;
  List<_PgBedDraft> beds;
  List<PickedFile> photos;
  List<String> existingPhotoUrls = [];

  _PgRoomDraft({
    required this.id,
    required this.name,
    int bedCount = 1,
    List<String>? roomAmenities,
  })  : sharingType = bedCount.clamp(1, 4).toInt(),
        roomAmenities = roomAmenities ?? [],
        photos = [],
        beds = List.generate(
          bedCount,
              (i) => _PgBedDraft(bedNumber: 'A${i + 1}'),
        );

  void setBedCount(int count) {
    final n = count.clamp(1, 12).toInt();
    if (n > beds.length) {
      for (int i = beds.length; i < n; i++) {
        beds.add(_PgBedDraft(bedNumber: 'A${i + 1}'));
      }
    } else if (n < beds.length) {
      beds = beds.sublist(0, n);
    }
    sharingType = n.clamp(1, 4).toInt();
  }
}

class _PgFloorDraft {
  String name;
  List<_PgRoomDraft> rooms;

  _PgFloorDraft({required this.name, List<_PgRoomDraft>? rooms})
      : rooms = rooms ?? [];
}

class _CreatePgPropertyPanelState extends State<CreatePgPropertyPanel> {
  static const _blue = Color(0xFF2F6BFF);
  static const _lightBlue = Color(0xFFEAF1FF);
  static const _tileBlue = Color(0xFFEEF4FF);
  static const _line = Color(0xFFE2E8F0);
  static const _muted = Color(0xFF64748B);
  static const _ink = Color(0xFF0F172A);
  static const _gap = SizedBox(height: 18);

  static String _generateUuidV4() {
    final rnd = Random();
    String hex(int len) =>
        List.generate(len, (_) => rnd.nextInt(16).toRadixString(16)).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
  }

  final _formKey = GlobalKey<FormState>();

  final landlordNameC = TextEditingController();
  final landlordPhoneC = TextEditingController();
  final landlordEmailC = TextEditingController();
  final nameC = TextEditingController();
  final descC = TextEditingController();
  int pgType = 1;
  int genderAllowed = 1;
  final extraPropertiesC = TextEditingController();

  final Set<String> selectedRules = {};
  final List<String> availableRules = [];
  bool _showAddRule = false;
  final customRuleC = TextEditingController();

  final doorC = TextEditingController();
  final floorC = TextEditingController();
  final cityC = TextEditingController();
  final pincodeC = TextEditingController();
  final addressC = TextEditingController();
  double? latitude;
  double? longitude;

  int? bedrooms;
  int? bathrooms;
  int? kitchen;
  int? builtYear;
  int? zone;

  final Set<String> selectedAmenityIds = {};
  final Map<String, String> amenityDetailMap = {};
  final rentC = TextEditingController(text: '6,000');
  final advanceC = TextEditingController();
  int? paymentDate;
  final contractRefC = TextEditingController();

  DateTime? _agreementStartDate;
  final agreementStartDateC = TextEditingController();
  int? periodMonths;
  int? lockInPeriodMonths;
  final maintenanceFeesC = TextEditingController();
  final rentIncrementC = TextEditingController();
  final List<PickedFile> photos = [];
  final List<PickedFile> documents = [];
  final List<String> existingImageUrls = [];
  final List<Map<String, dynamic>> existingDocs = [];
  int _status = 0;
  static const int _maxDocs = 5;

  bool get _isEdit => widget.initial != null;

  int floorsCount = 1;
  int roomsPerFloor = 1;
  int bedsPerRoom = 1;
  final List<_PgFloorDraft> floors = [];
  int expandedFloor = 0;
  int selectedRoomIndex = 0;

  static const _roomFeatureOptions = [
    'Attached bathroom',
    'Air Conditioner',
    'Balcony',
    'Study Table',
    'Wardrobe',
  ];

  bool _submitting = false;
  bool get _showLandlordSection {
    final auth =
    Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    return auth != null && auth.isSuperAdmin;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _prefill(widget.initial!);
    } else {
      _buildLayoutFromPattern();
    }
  }

  @override
  void didUpdateWidget(covariant CreatePgPropertyPanel old) {
    super.didUpdateWidget(old);
    if (_isEdit &&
        widget.amenityOptions.isNotEmpty &&
        (old.amenityOptions.isEmpty || selectedAmenityIds.isEmpty)) {
      _prefillAmenities(rebuild: true);
    }
  }

  @override
  void dispose() {
    for (final c in [
      landlordNameC,
      landlordPhoneC,
      landlordEmailC,
      nameC,
      descC,
      extraPropertiesC,
      doorC,
      floorC,
      cityC,
      pincodeC,
      addressC,
      rentC,
      advanceC,
      contractRefC,
      agreementStartDateC,
      maintenanceFeesC,
      rentIncrementC,
      customRuleC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int _amount(String s) =>
      int.tryParse(s.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;
  String _pick(List<dynamic> sources, List<String> keys) {
    for (final s in sources) {
      if (s is! Map) continue;
      for (final k in keys) {
        final v = s[k]?.toString().trim() ?? '';
        if (v.isNotEmpty && v.toLowerCase() != 'null') return v;
      }
    }
    return '';
  }

  String _pincodeFromAddress(String address) =>
      RegExp(r'\b\d{6}\b').firstMatch(address)?.group(0) ?? '';

  String _cityFromAddress(String address) {
    final parts = address
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final i = parts.indexWhere((s) => RegExp(r'\b\d{6}\b').hasMatch(s));
    return i > 0 ? parts[i - 1] : '';
  }

  String _plural(int n, String word) => '$n ${n == 1 ? word : '${word}s'}';

  String _money(int v) => NumberFormat.decimalPattern('en_IN').format(v);

  int _roomRent(_PgRoomDraft r) => r.rentOverride ?? _amount(rentC.text);
  int _bedRent(_PgRoomDraft r, _PgBedDraft b) => b.rent ?? _roomRent(r);

  int _bedAdvance(_PgRoomDraft r, _PgBedDraft b) =>
      b.advance ?? r.advanceOverride ?? _amount(advanceC.text);

  int _codeFromLabel(dynamic v, List<String> keys, int fallback) {
    if (v is num) {
      final n = v.toInt();
      return n >= 1 && n <= 3 ? n : fallback;
    }
    final s = '$v'.toLowerCase();
    for (int i = 0; i < keys.length; i++) {
      if (s.contains(keys[i])) return i + 1;
    }
    return int.tryParse('$v') ?? fallback;
  }

  void _prefill(PgPropertyDetailData p) {
    final raw = p.rawJson;
    final place = raw['placeDetails'] is Map
        ? Map<String, dynamic>.from(raw['placeDetails'])
        : <String, dynamic>{};

    nameC.text = p.name;
    descC.text = p.description.isNotEmpty
        ? p.description
        : (raw['description'] ?? '').toString();
    extraPropertiesC.text = (raw['extraProperties'] ?? '').toString();
    contractRefC.text =
        (p.contractReference ?? raw['contractReference'] ?? '').toString();

    addressC.text = p.address.isNotEmpty
        ? p.address
        : (place['address'] ?? raw['address'] ?? '').toString();
    doorC.text =
        (p.doorNumber ?? place['doorNumber'] ?? raw['doorNumber'] ?? '')
            .toString();
    floorC.text = (p.floorNumber ??
            place['floor'] ??
            raw['floor'] ??
            raw['floorNumber'] ??
            '')
        .toString();
    final sources = <dynamic>[
      raw,
      place,
      raw['pgDetails'],
      raw['address'],
      raw['propertyDetails'],
      raw['location'],
    ];
    cityC.text = _pick(sources, ['city', 'City', 'cityName', 'town', 'district']);
    if (cityC.text.isEmpty) {
      cityC.text = _cityFromAddress(addressC.text);
    }
    pincodeC.text = _pick(
        sources, ['pincode', 'pinCode', 'PinCode', 'postalCode', 'zipCode', 'zip']);
    if (pincodeC.text.isEmpty) {
      pincodeC.text = _pincodeFromAddress(addressC.text);
    }
    debugPrint('PG prefill city="${cityC.text}" pincode="${pincodeC.text}" '
        'rawKeys=${raw.keys.toList()} placeKeys=${place.keys.toList()}');
    latitude = p.latitude ??
        (place['latitude'] as num?)?.toDouble() ??
        (raw['latitude'] as num?)?.toDouble();
    longitude = p.longitude ??
        (place['longitude'] as num?)?.toDouble() ??
        (raw['longitude'] as num?)?.toDouble();

    landlordNameC.text = p.landlord?.name ?? '';
    final phone = (p.landlord?.phone ?? '').replaceAll(RegExp(r'[^\d]'), '');
    landlordPhoneC.text =
        phone.length > 10 ? phone.substring(phone.length - 10) : phone;
    landlordEmailC.text = p.landlord?.email ?? '';

    pgType = _codeFromLabel(
        raw['pgType'] ?? p.pgDetails?.pgType, ['co-ed', 'boy', 'girl'], 1);
    final g = '${raw['genderAllowed'] ?? p.pgDetails?.genderAllowed}'.toLowerCase();
    if (g.contains('female') || g.contains('girl')) {
      genderAllowed = 3;
    } else if (g.contains('male') || g.contains('boy')) {
      genderAllowed = 2;
    } else if (g.contains('any') || g.contains('co')) {
      genderAllowed = 1;
    } else {
      genderAllowed = _codeFromLabel(raw['genderAllowed'], [], 1);
    }

    final rentVal = p.rent > 0
        ? p.rent
        : ((raw['rent'] ?? raw['rentAmount']) as num?)?.toDouble() ?? 0;
    final advVal = p.advance > 0
        ? p.advance
        : ((raw['advance'] ?? raw['advanceAmount']) as num?)?.toDouble() ?? 0;
    if (rentVal > 0) rentC.text = _money(rentVal.round());
    if (advVal > 0) {
      advanceC.text = _money(advVal.round());
    } else if (rentVal > 0) {
      advanceC.text = _money(rentVal.round());
    }

    final payRaw = raw['rentPaymentDate'] ?? p.pgDetails?.rentPaymentDate;
    paymentDate = payRaw is num
        ? payRaw.toInt()
        : int.tryParse('$payRaw');
    if (paymentDate != null && (paymentDate! < 1 || paymentDate! > 31)) {
      paymentDate = 5;
    }

    bedrooms = p.bedrooms > 0 ? p.bedrooms : (raw['bedrooms'] as num?)?.toInt();
    bathrooms =
        p.bathrooms > 0 ? p.bathrooms : (raw['bathrooms'] as num?)?.toInt();
    kitchen = p.kitchen > 0 ? p.kitchen : (raw['kitchen'] as num?)?.toInt();
    builtYear =
        p.builtYear > 0 ? p.builtYear : (raw['builtYear'] as num?)?.toInt();
    zone = int.tryParse('${raw['zone'] ?? p.zone ?? 1}') ?? 1;

    final st = raw['status'];
    if (st is num) {
      _status = st.toInt();
    } else {
      final t = '${p.status}'.toLowerCase();
      _status = t.contains('rent') ? 1 : 0;
    }

    selectedRules.clear();
    for (final rule in p.houseRules) {
      if (rule.trim().isEmpty) continue;
      if (!availableRules.contains(rule)) availableRules.add(rule);
      selectedRules.add(rule);
    }

    existingImageUrls
      ..clear()
      ..addAll(p.photoPaths.where((u) => u.isNotEmpty));
    existingDocs
      ..clear()
      ..addAll(p.documents.map((d) => {
        'id': d.id,
            'fileName': d.documentName,
            'absolutePath': d.fileUrl,
            'relativePath': '',
            'thumbnailUrl': '',
            'originalUrl': d.fileUrl,
            'uploadedTime': '',
            'isDeletable': true,
          }));

    _loadFloorsFrom(p);
    if (_amount(advanceC.text) <= 0) {
      for (final f in floors) {
        for (final r in f.rooms) {
          if (r.advanceOverride != null && r.advanceOverride! > 0) {
            advanceC.text = _money(r.advanceOverride!);
            break;
          }
        }
      }
    }
    if (_amount(advanceC.text) < _amount(rentC.text)) {
      advanceC.text = rentC.text;
    }
    _prefillAmenities(rebuild: false);
  }

  void _loadFloorsFrom(PgPropertyDetailData p) {
    floors.clear();
    if (p.floors.isEmpty) {
      _buildLayoutFromPattern();
      return;
    }
    for (int fi = 0; fi < p.floors.length; fi++) {
      final src = p.floors[fi];
      final floor = _PgFloorDraft(name: src.floorName);
      for (int ri = 0; ri < src.rooms.length; ri++) {
        final r = src.rooms[ri];
        final bedCount = r.beds.isNotEmpty
            ? r.beds.length
            : (r.totalBeds > 0 ? r.totalBeds : 1);
        final room = _PgRoomDraft(
          id: r.id.isNotEmpty ? r.id : _generateUuidV4(),
          name: r.roomName,
          bedCount: bedCount,
          roomAmenities: List<String>.from(r.amenitiesList),
        );
        room.existingPhotoUrls =
            r.images.map((i) => i.url).where((u) => u.isNotEmpty).toList();

        final roomRent = r.rentPerBed > 0 ? r.rentPerBed.round() : 0;
        if (roomRent > 0) room.rentOverride = roomRent;

        if (r.beds.isNotEmpty) {
          room.beds.clear();
          for (final b in r.beds) {
            final bed = _PgBedDraft(bedNumber: b.bedNumber);
            bed.isOccupied = b.isOccupied;
            bed.tenantName = b.tenantName ?? '';
            bed.tenantPhone = b.tenantPhone ?? '';
            bed.tenantEmail = b.tenantEmail ?? '';
            if (b.joinDate != null && b.joinDate!.isNotEmpty) {
              bed.tenantStart = DateTime.tryParse(b.joinDate!);
            }
            if (b.advance != null && b.advance! > 0) {
              room.advanceOverride = b.advance!.round();
            }

            final bedRent = (b.rent > 0 ? b.rent : b.rentAmount).round();
            if (bedRent > 0 && bedRent != roomRent) bed.rent = bedRent;

            room.beds.add(bed);
          }

          final advances = r.beds
              .map((b) => (b.advance ?? 0).round())
              .where((a) => a > 0)
              .toSet();
          if (advances.length > 1) {
            for (int i = 0; i < r.beds.length; i++) {
              final a = (r.beds[i].advance ?? 0).round();
              if (a > 0) room.beds[i].advance = a;
            }
          }
        }
        floor.rooms.add(room);
      }
      if (floor.rooms.isEmpty) floor.rooms.add(_newRoom(fi, 0));
      floors.add(floor);
    }
    floorsCount = floors.length;
    roomsPerFloor = floors.map((f) => f.rooms.length).fold<int>(1, (a, b) => a > b ? a : b);
    bedsPerRoom = floors.expand((f) => f.rooms).map((r) => r.beds.length).fold<int>(1, (a, b) => a > b ? a : b);
    expandedFloor = 0;
    selectedRoomIndex = 0;
  }

  void _prefillAmenities({bool rebuild = false}) {
    final p = widget.initial;
    if (p == null || widget.amenityOptions.isEmpty) return;
    final raw = p.rawJson;
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

    final lists = <dynamic>[
      if (raw['amenities'] is List) ...(raw['amenities'] as List),
      ...p.amenities,
    ];
    for (final item in lists) {
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
      }
    }
    for (final name in p.amenityLabels) {
      final n = name.trim().toLowerCase();
      for (final a in widget.amenityOptions) {
        if (a.name.trim().toLowerCase() == n) ids.add(a.id);
      }
    }
    if (ids.isEmpty) return;
    selectedAmenityIds.addAll(ids);
    if (rebuild && mounted) setState(() {});
  }

  _PgRoomDraft _newRoom(int floorIdx, int roomIdx) {
    return _PgRoomDraft(
      id: _generateUuidV4(),
      name: '#${floorIdx + 1}${(roomIdx + 1).toString().padLeft(2, '0')}',
      bedCount: bedsPerRoom,
    );
  }

  void _buildLayoutFromPattern() {
    while (floors.length < floorsCount) {
      floors.add(_PgFloorDraft(name: 'Floor ${floors.length + 1}'));
    }
    while (floors.length > floorsCount) {
      floors.removeLast();
    }
    for (int fi = 0; fi < floors.length; fi++) {
      final f = floors[fi];
      while (f.rooms.length < roomsPerFloor) {
        f.rooms.add(_newRoom(fi, f.rooms.length));
      }
      while (f.rooms.length > roomsPerFloor) {
        f.rooms.removeLast();
      }
      for (final r in f.rooms) {
        r.setBedCount(bedsPerRoom);
      }
    }
    if (expandedFloor >= floors.length) expandedFloor = floors.length - 1;
    if (expandedFloor < 0 && floors.isNotEmpty) expandedFloor = 0;
    selectedRoomIndex = 0;
  }

  void _applyPattern() => setState(_buildLayoutFromPattern);

  void _setFloorRoomsAndBeds(int fi, int roomCount, int bedCount) {
    final f = floors[fi];
    while (f.rooms.length < roomCount) {
      f.rooms.add(_newRoom(fi, f.rooms.length));
    }
    while (f.rooms.length > roomCount) {
      f.rooms.removeLast();
    }
    for (final r in f.rooms) {
      r.setBedCount(bedCount);
    }
    if (selectedRoomIndex >= f.rooms.length) selectedRoomIndex = 0;
  }

  int get _totalRooms => floors.fold(0, (s, f) => s + f.rooms.length);
  int get _totalBeds => floors.fold(
      0, (s, f) => s + f.rooms.fold(0, (a, r) => a + r.beds.length));
  int get _estRevenue => floors.fold(
      0,
          (s, f) =>
      s +
          f.rooms.fold(
              0, (a, r) => a + r.beds.fold(0, (x, b) => x + _bedRent(r, b))));

  Future<void> _pickLocation() async {
    final r = await showMapPicker(context, lat: latitude, lng: longitude);
    if (r == null) return;
    setState(() {
      addressC.text = r.address;
      latitude = r.latitude;
      longitude = r.longitude;
      if (r.city.isNotEmpty) cityC.text = r.city;
      if (r.pincode.isNotEmpty) pincodeC.text = r.pincode;
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _agreementStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Agreement Start Date',
    );
    if (d != null) {
      setState(() {
        _agreementStartDate = d;
        agreementStartDateC.text =
            DateFormat('dd/MMM/yyyy').format(d).toUpperCase();
      });
    }
  }

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
    } catch (e) {
      Get.snackbar('Picker error', '$e');
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
    } catch (e) {
      Get.snackbar('Picker error', '$e');
    }
  }

  void _addCustomRule() {
    setState(() => _showAddRule = true);
  }

  void _saveCustomRule() {
    final txt = customRuleC.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      if (!availableRules.contains(txt)) availableRules.add(txt);
      selectedRules.add(txt);
      customRuleC.clear();
      _showAddRule = false;
    });
  }

  void _cancelCustomRule() {
    setState(() {
      customRuleC.clear();
      _showAddRule = false;
    });
  }

  ButtonStyle get _saveStyle => ElevatedButton.styleFrom(
    backgroundColor: _blue,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
  );

  Future<void> _openEditFloor(int fi) async {
    final floor = floors[fi];
    int rooms = floor.rooms.isEmpty ? 1 : floor.rooms.length;
    int beds = floor.rooms.isEmpty
        ? bedsPerRoom
        : floor.rooms.first.beds.length.clamp(1, 12);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(floor.name),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _labeled(
                  'Rooms / floor',
                  _stepper(rooms, (v) => setD(() => rooms = v), max: 50),
                ),
                const SizedBox(height: 16),
                _labeled(
                  'Beds / room',
                  _stepper(beds, (v) => setD(() => beds = v), max: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'default'),
              child: const Text('Use default',
                  style: TextStyle(color: _muted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text('Save',
                  style: TextStyle(
                      color: _blue, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (res == 'save') {
      setState(() => _setFloorRoomsAndBeds(fi, rooms, beds));
    } else if (res == 'default') {
      setState(
          () => _setFloorRoomsAndBeds(fi, roomsPerFloor, bedsPerRoom));
    }
  }

    Future<void> _openRoomDetails(int fi, int ri) async {
      final room = floors[fi].rooms[ri];
      final nameCtl = TextEditingController(text: room.name);
      final rentCtl = TextEditingController(text: _money(_roomRent(room)));
      final advanceCtl = TextEditingController(
        text: room.advanceOverride != null
            ? _money(room.advanceOverride!)
            : advanceC.text,
      );

      final bedRentCtls = room.beds
          .map((b) => TextEditingController(text: _money(_bedRent(room, b))))
          .toList();
      final bedAdvCtls = room.beds.map((b) {
        final v = _bedAdvance(room, b);
        return TextEditingController(text: v > 0 ? _money(v) : '');
      }).toList();

      final hadBedOverrides =
      room.beds.any((b) => b.rent != null || b.advance != null);
      final features = List<String>.from(room.roomAmenities);
      var applyAll = !hadBedOverrides;
      int? roomPayDate = paymentDate;
      final amenityNames = widget.amenityOptions.isNotEmpty
          ? widget.amenityOptions.map((a) => a.name).toList()
          : const [
        'Wifi',
        'Hot water',
        'AC',
        'Food',
        'Laundry',
        'Housekeeping',
        'Parking',
        'Power backup',
        'CCTV',
      ];

      Widget bedPricingCard(int i, void Function(void Function()) setD) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: 50,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bed_outlined, color: _blue, size: 18),
                    Text('${i + 1}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _blue)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _boxField(
                  'Rent per bed',
                  '6,000',
                  bedRentCtls[i],
                  prefix: '₹ ',
                  keyboard: TextInputType.number,
                  formatters: [_IndianAmountFormatter()],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _boxField(
                  'Advance Amount',
                  '10,000',
                  bedAdvCtls[i],
                  prefix: '₹ ',
                  keyboard: TextInputType.number,
                  formatters: [_IndianAmountFormatter()],
                ),
              ),
            ],
          ),
        );
      }

      final res = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setD) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.meeting_room_outlined,
                      color: _blue, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameCtl,
                        decoration: const InputDecoration(
                          filled: false,
                          fillColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          suffixIcon:
                          Icon(Icons.edit_outlined, size: 16, color: _muted),
                        ),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${floors[fi].name} · ${room.beds.length} beds · Room details',
                        style: const TextStyle(fontSize: 12.5, color: _muted),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(ctx),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, size: 22, color: _muted),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Photos',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _ink)),
                    const SizedBox(height: 8),
                    _fileGrid(
                      files: room.photos,
                      isImage: true,
                      tileWidth: 80,
                      tileHeight: 80,
                      existingUrls: room.existingPhotoUrls,
                      onRemoveExisting: (i) => setD(() => room.existingPhotoUrls.removeAt(i)),
                      onAdd: () async {
                        try {
                          final picked =
                          await FilePicker.pickFiles(type: FileType.image);
                          if (picked.isEmpty) return;
                          final files = await _readAll(picked);
                          setD(() => room.photos.addAll(files));
                        } catch (e) {
                          Get.snackbar('Picker error', '$e');
                        }
                      },
                      onRemove: (i) => setD(() => room.photos.removeAt(i)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Icon(Icons.bed_outlined, size: 18, color: _blue),
                        SizedBox(width: 6),
                        Text('Bed pricing',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _ink)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Apply to all beds',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 2),
                                Text('Set a different rent for each bed',
                                    style:
                                    TextStyle(fontSize: 12, color: _muted)),
                              ],
                            ),
                          ),
                          Text('${room.beds.length} beds',
                              style:
                              const TextStyle(fontSize: 12.5, color: _muted)),
                          const SizedBox(width: 8),
                          Switch(
                            value: applyAll,
                            activeThumbColor: _blue,
                            onChanged: (v) => setD(() {
                              applyAll = v;
                              if (!v && !hadBedOverrides) {
                                for (int i = 0; i < room.beds.length; i++) {
                                  bedRentCtls[i].text = rentCtl.text;
                                  bedAdvCtls[i].text = advanceCtl.text;
                                }
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (applyAll)
                      _twoCol(
                        _uField(
                          'Rent per bed',
                          'e.g. 6,000',
                          rentCtl,
                          prefix: '₹ ',
                          keyboard: TextInputType.number,
                          formatters: [_IndianAmountFormatter()],
                        ),
                        _uField(
                          'Advance Amount',
                          '10000',
                          advanceCtl,
                          keyboard: TextInputType.number,
                          formatters: [_IndianAmountFormatter()],
                        ),
                      )
                    else
                      for (int i = 0; i < room.beds.length; i++)
                        bedPricingCard(i, setD),
                    _gap,
                    _dropdownBox<int>(
                      'Rent Payment Date',
                      roomPayDate,
                      List.generate(31, (i) => i + 1),
                          (v) => setD(() => roomPayDate = v),
                      hint: 'Select',
                      itemLabel: (v) => '$v',
                      height: 40,
                    ),
                    _gap,
                    Row(
                      children: const [
                        Icon(Icons.star_outline, size: 18, color: _blue),
                        SizedBox(width: 6),
                        Text('Amenities',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _ink)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Set common amenities for this room, then apply to every room. You can still customize any room individually.',
                      style: TextStyle(fontSize: 12.5, color: _muted),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: amenityNames.map((a) {
                        final sel = features.contains(a);
                        return _chip(a, sel, (v) {
                          setD(() {
                            if (v) {
                              features.add(a);
                            } else {
                              features.remove(a);
                            }
                          });
                        });
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: _saveStyle,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final newName = nameCtl.text.trim();
      final newRent = _amount(rentCtl.text);
      final newAdvance = _amount(advanceCtl.text);
      final bedRents = bedRentCtls.map((c) => _amount(c.text)).toList();
      final bedAdvs = bedAdvCtls.map((c) => _amount(c.text)).toList();
      nameCtl.dispose();
      rentCtl.dispose();
      advanceCtl.dispose();
      for (final c in bedRentCtls) {
        c.dispose();
      }
      for (final c in bedAdvCtls) {
        c.dispose();
      }
      if (!mounted) return;

      if (res == true) {
        setState(() {
          if (newName.isNotEmpty) room.name = newName;
          room.roomAmenities = features;
          if (roomPayDate != null) paymentDate = roomPayDate;

          if (applyAll) {
            room.rentOverride =
            (newRent > 0 && newRent != _amount(rentC.text)) ? newRent : null;
            room.advanceOverride = newAdvance > 0 ? newAdvance : null;
            for (final b in room.beds) {
              b.rent = null;
              b.advance = null;
            }
            for (final other in floors[fi].rooms) {
              other.rentOverride = room.rentOverride;
              other.advanceOverride = room.advanceOverride;
              other.roomAmenities = List<String>.from(features);
              for (final b in other.beds) {
                b.rent = null;
                b.advance = null;
              }
            }
          } else {
            for (int i = 0; i < room.beds.length; i++) {
              room.beds[i].rent = bedRents[i] > 0 ? bedRents[i] : null;
              room.beds[i].advance = bedAdvs[i] > 0 ? bedAdvs[i] : null;
            }
          }
        });
      }
    }

  Future<void> _openEditBeds(_PgRoomDraft room) async {
    int count = room.beds.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit beds in ${room.name}'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Number of beds',
                  style: TextStyle(fontSize: 14, color: _muted)),
              const SizedBox(width: 20),
              _stepper(count, (v) => setD(() => count = v), max: 12),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: _saveStyle,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) setState(() => room.setBedCount(count));
  }
  Future<void> _openBedDialog(_PgRoomDraft room, _PgBedDraft bed) async {
    final floorName = floors
        .firstWhere((f) => f.rooms.contains(room),
        orElse: () => _PgFloorDraft(name: ''))
        .name;
    final wasOccupied = bed.isOccupied;
    DateTime? start = bed.tenantStart;
    String? error;

    String fmtAmt(int v) => v > 0 ? _money(v) : '';

    final rentCtl = TextEditingController(text: fmtAmt(_bedRent(room, bed)));
    final advCtl = TextEditingController(text: fmtAmt(_bedAdvance(room, bed)));
    final nameCtl = TextEditingController(text: bed.tenantName);
    final phoneCtl = TextEditingController(text: bed.tenantPhone);
    final emailCtl = TextEditingController(text: bed.tenantEmail);
    final dateCtl = TextEditingController(
      text: start == null ? '' : DateFormat('dd-MM-yyyy').format(start!),
    );

    InputDecoration deco(String hint, {IconData? icon, String? prefix}) {
      OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );
      return InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        hoverColor: Colors.transparent,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixText: prefix,
        prefixIcon: icon == null ? null : Icon(icon, color: _blue, size: 20),
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: b(_line),
        enabledBorder: b(_line),
        focusedBorder: b(_blue, 1.5),
      );
    }

    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: t,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569)),
          children: const [
            TextSpan(
                text: ' *',
                style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    const fieldStyle = TextStyle(fontSize: 15, color: _ink);

    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Dialog(
          backgroundColor: Colors.white,
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: wasOccupied
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.single_bed_outlined,
                          size: 26,
                          color: wasOccupied
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wasOccupied ? 'Tenant details' : 'Move tenant in',
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: _ink),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$floorName · ${room.name} · ${bed.bedNumber}',
                              style: const TextStyle(
                                  fontSize: 13, color: _muted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: wasOccupied
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          wasOccupied ? 'Occupied' : 'Vacant',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: wasOccupied
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: _muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Rent amount',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            TextField(
                              controller: rentCtl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_IndianAmountFormatter()],
                              style: fieldStyle.copyWith(
                                  fontWeight: FontWeight.w600),
                              decoration: deco('6,000', prefix: '₹ '),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Advance amount',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            TextField(
                              controller: advCtl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_IndianAmountFormatter()],
                              style: fieldStyle,
                              decoration: deco('Enter amount', prefix: '₹ '),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  label('Full name'),
                  TextField(
                    controller: nameCtl,
                    style: fieldStyle,
                    decoration: deco("Tenant's name",
                        icon: Icons.person_outline_rounded),
                  ),
                  const SizedBox(height: 18),
                  label('Phone number'),
                  TextField(
                    controller: phoneCtl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: fieldStyle,
                    decoration:
                    deco('90000 00000', icon: Icons.phone_outlined),
                  ),
                  const SizedBox(height: 18),
                  label('Gmail'),
                  TextField(
                    controller: emailCtl,
                    keyboardType: TextInputType.emailAddress,
                    style: fieldStyle,
                    decoration: deco('tenant@gmail.com',
                        icon: Icons.mail_outline_rounded),
                  ),
                  const SizedBox(height: 18),
                  label('Tenancy start date'),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final now = DateTime.now();
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: start ?? now,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setD(() {
                          start = d;
                          dateCtl.text = DateFormat('dd-MM-yyyy').format(d);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextField(
                        controller: dateCtl,
                        style: fieldStyle,
                        decoration: deco('dd-mm-yyyy',
                            icon: Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Text(error!,
                        style: const TextStyle(
                            color: Color(0xFFDC2626), fontSize: 13)),
                  ],
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final n = nameCtl.text.trim();
                        final p = phoneCtl.text.trim();
                        final e = emailCtl.text.trim();
                        String? err;
                        if (n.isEmpty) {
                          err = 'Full name is required.';
                        } else if (p.length != 10) {
                          err = 'Please enter a valid 10-digit phone number.';
                        } else if (e.isEmpty || !GetUtils.isEmail(e)) {
                          err = 'Please enter a valid email address.';
                        } else if (start == null) {
                          err = 'Tenancy start date is required.';
                        }
                        if (err != null) {
                          setD(() => error = err);
                          return;
                        }
                        Navigator.pop(ctx, 'save');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        wasOccupied ? 'Update tenant' : 'Move tenant in',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (wasOccupied) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx, 'vacate'),
                        child: const Text('Mark bed as vacant',
                            style: TextStyle(color: Color(0xFFDC2626))),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final tName = nameCtl.text.trim();
    final tPhone = phoneCtl.text.trim();
    final tEmail = emailCtl.text.trim();
    final newRent = _amount(rentCtl.text);
    final newAdv = _amount(advCtl.text);
    rentCtl.dispose();
    advCtl.dispose();
    nameCtl.dispose();
    phoneCtl.dispose();
    emailCtl.dispose();
    dateCtl.dispose();
    if (res == null || !mounted) return;

    setState(() {
      if (res == 'vacate') {
        bed.isOccupied = false;
        bed.tenantName = '';
        bed.tenantPhone = '';
        bed.tenantEmail = '';
        bed.tenantStart = null;
        return;
      }
      bed.isOccupied = true;
      bed.tenantName = tName;
      bed.tenantPhone = tPhone;
      bed.tenantEmail = tEmail;
      bed.tenantStart = start;
      bed.rent = (newRent > 0 && newRent != _roomRent(room)) ? newRent : null;
      bed.advance = newAdv > 0 ? newAdv : null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Missing details', 'Please fix the highlighted fields.');
      return;
    }

    if (floors.isEmpty || floors.any((f) => f.rooms.isEmpty)) {
      Get.snackbar(
          'Missing layout', 'Every floor needs at least one room.');
      return;
    }

    final rentVal = _amount(rentC.text);
    var advanceVal = _amount(advanceC.text);
    if (advanceVal < rentVal) advanceVal = rentVal;

    final floorsJson = floors.asMap().entries.map((fEntry) {
      final fIdx = fEntry.key;
      final f = fEntry.value;
      return {
        'index': fIdx + 1,
        'floorName': f.name,
        'rooms': f.rooms.asMap().entries.map((rEntry) {
          final rIdx = rEntry.key;
          final r = rEntry.value;
          final roomRent = r.rentOverride ?? rentVal;
          var roomAdvance = r.advanceOverride ?? advanceVal;
          if (roomAdvance < roomRent) roomAdvance = roomRent;
          return {
            'index': rIdx + 1,
            'roomName': r.name,
            'existingImages': r.existingPhotoUrls,
            'roomType': r.sharingType,
            'rentPerBed': roomRent,
            'totalBeds': r.beds.length,
            'beds': r.beds.asMap().entries.map((bEntry) {
              final bIdx = bEntry.key;
              final b = bEntry.value;
              final bedRent = b.rent ?? roomRent;
              var bedAdvance = b.advance ?? roomAdvance;
              if (bedAdvance < bedRent) bedAdvance = bedRent;

              return {
                'index': bIdx + 1,
                'bedNumber': b.bedNumber,
                'status': b.isOccupied ? 1 : 0,
                'rent': bedRent,
                'advance': bedAdvance,
                if (b.isOccupied && b.tenantName.trim().isNotEmpty)
                  'tenant': {
                    'fullName': b.tenantName.trim(),
                    'phone': b.tenantPhone.trim(),
                    'email': b.tenantEmail.trim(),
                    'tenancyStart': b.tenantStart == null
                        ? DateTime.now().toUtc().toIso8601String()
                        : DateTime.utc(
                      b.tenantStart!.year,
                      b.tenantStart!.month,
                      b.tenantStart!.day,
                    ).toIso8601String(),
                    'isSelfOwned': true,
                  },
              };
            }).toList(),
          };
        }).toList(),
      };
    }).toList();
    final amenityIds = selectedAmenityIds.toList();
    final amenitiesList = amenityIds.map((id) {
      final match = widget.amenityOptions.firstWhereOrNull((a) => a.id == id);
      return {'id': id, 'name': match?.name ?? ''};
    }).toList();

    final data = <String, dynamic>{
      'name': nameC.text.trim(),
      'description': descC.text.trim(),
      'category': 'PG',
      'propertyType': 7,
      'status': 0,
      'pgType': pgType,
      'genderAllowed': genderAllowed,
      'city': cityC.text.trim().isNotEmpty ? cityC.text.trim() : 'Bengaluru',
      'pincode':
          pincodeC.text.trim().isNotEmpty ? pincodeC.text.trim() : '560001',
      'rentPaymentDate': paymentDate ?? 5,
      'zone': zone ?? 1,
      'contractReference': contractRefC.text.trim().isNotEmpty
          ? contractRefC.text.trim()
          : 'PG-CON-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'address': addressC.text.trim(),
      'latitude': latitude ?? 12.9716,
      'longitude': longitude ?? 77.5946,
      'floor':
          floorC.text.trim().isNotEmpty ? floorC.text.trim() : 'Ground Floor',
      'doorNumber': doorC.text.trim(),
      'houseRules': selectedRules.toList(),
      'amenities': amenitiesList,
      'amenityIds': amenityIds,
      'floors': floorsJson,
      'photos': photos,
      'documents': documents,
      'rent': rentVal,
      'advance': advanceVal,
      'extraProperties': extraPropertiesC.text.trim().isEmpty
          ? null
          : extraPropertiesC.text.trim(),
      'bedrooms': bedrooms ?? _totalRooms,
      'bathrooms': bathrooms ?? 0,
      'kitchen': kitchen ?? 1,
      'builtYear': builtYear ?? DateTime.now().year,
      'existingImages': existingImageUrls,
      'existingDocuments': existingDocs,
      'isSelfOwned': true,
      if (_showLandlordSection)
        'landlord': {
          'name': landlordNameC.text.trim(),
          'phone': landlordPhoneC.text.trim(),
          'email': landlordEmailC.text.trim(),
        },
      'status': _status,
    };

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(data);
      widget.onBack();
    } catch (e) {
      Get.snackbar(
          'Error',
          'Failed to ${_isEdit ? 'update' : 'create'} PG property: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                    final isDesktop = c.maxWidth >= 900;
                    final left = _detailsLeftColumn();
                    final right = _detailsRightColumn();

                    if (!isDesktop) {
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
            _isEdit ? 'Update Property (PG)' : 'Create Property (PG)',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: _submitting ? null : widget.onBack,
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: _submitting
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : Text(_isEdit ? 'Update' : 'Create Property'),
          ),
        ],
      ),
    );
  }

  List<Widget> _detailsLeftColumn() => [
    if (_showLandlordSection)
    _mCard(
      icon: Icons.person_pin_outlined,
      title: 'Landlord Details',
      child: Column(
        children: [
          _uField('Landlord Name', 'e.g. Rajesh Kumar', landlordNameC,
              validator: (v) => _required(v, 'Landlord Name')),
          _gap,
          _uField(
            'Phone Number',
            'Enter 10-digit number',
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
          _gap,
          _uField(
            'Email',
            'landlord@example.com',
            landlordEmailC,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              return GetUtils.isEmail(v.trim())
                  ? null
                  : 'Enter a valid email';
            },
          ),
        ],
      ),
    ),
    _mCard(
      icon: Icons.photo_library_outlined,
      title: 'Property Photos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Photos',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: _muted)),
          const SizedBox(height: 10),
          _fileGrid(
            files: photos,
            onAdd: _pickPhotos,
            onRemove: (i) => setState(() => photos.removeAt(i)),
            isImage: true,
            existingUrls: existingImageUrls,
            onRemoveExisting: (i) =>
                setState(() => existingImageUrls.removeAt(i)),
          ),
          const SizedBox(height: 12),
          const Text(
            'First photo is used as the cover image across listings.',
            style: TextStyle(fontSize: 13, color: _muted),
          ),
        ],
      ),
    ),
    _mCard(
      icon: Icons.info_outline,
      title: 'Basic Info',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _uField('PG Name', 'PG Name', nameC,
              validator: (v) => _required(v, 'PG Name')),
          _gap,
          _uField('Property Description',
              'Shared rooms near tech park...', descC,
              maxLines: 2,
              validator: (v) => _required(v, 'Description')),
          _gap,
          _dropdownBox<int>(
            'PG type',
            pgType,
            [1, 2, 3],
                (v) => setState(() {
              pgType = v ?? 1;
              genderAllowed = pgType;
            }),
            itemLabel: (v) => v == 1
                ? 'Co-ed'
                : v == 2
                ? 'Boys'
                : 'Girls',
          ),
          _gap,
          _twoCol(
            _uField('Door number', 'e.g. 309', doorC),
            _uField('Floor number', 'e.g. 3', floorC),
          ),
          _gap,
          _uField(
            'Property Address',
            'Pick the location on the map.',
            addressC,
            readOnly: true,
            onTap: _pickLocation,
            suffix: IconButton(
              onPressed: _pickLocation,
              icon: const Icon(Icons.location_on_outlined,
                  color: _blue, size: 22),
            ),
            validator: (v) => _required(v, 'Address'),
          ),
          const SizedBox(height: 12),
          _hintBox(
              'Add the full address and include the door number at the beginning (e.g., #309 3rd Floor)'),
          _gap,
          _twoCol(
            _uField('City', 'City', cityC,
                validator: (v) => _required(v, 'City')),
            _uField(
              'Pincode',
              'Pincode',
              pincodeC,
              keyboard: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) => _required(v, 'Pincode'),
            ),
          ),
        ],
      ),
    ),
  ];

  List<Widget> _detailsRightColumn() => [

    _mCard(
      icon: Icons.star_outline,
      title: 'Amenities',
      child: _amenitiesBody(),
    ),
    _mCard(
      icon: Icons.checklist_rounded,
      title: 'House Rules',
      trailing: _circleAdd(_addCustomRule),
      child: (availableRules.isEmpty && !_showAddRule)
          ? null
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (availableRules.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableRules.map((rule) {
                return InputChip(
                  label: Text(rule),
                  selected: true,
                  showCheckmark: false,
                  onDeleted: () {
                    setState(() {
                      availableRules.remove(rule);
                      selectedRules.remove(rule);
                    });
                  },
                  backgroundColor: _lightBlue,
                  selectedColor: _lightBlue,
                  deleteIconColor: _blue,
                  labelStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                  shape: const StadiumBorder(
                    side: BorderSide(color: _blue),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                );
              }).toList(),
            ),
          if (_showAddRule) ...[
            if (availableRules.isNotEmpty) const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customRuleC,
                    autofocus: true,
                    decoration: const InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      hintText: 'Add a house rule',
                      border: UnderlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _saveCustomRule(),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _saveCustomRule,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: _blue,
                    child: Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _cancelCustomRule,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF64748B),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
    _mCard(
      icon: Icons.grid_view_rounded,
      title: 'Default pattern',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _twoCol(
            _labeled(
              'No. of floors',
              _stepper(floorsCount, (v) {
                floorsCount = v;
                _applyPattern();
              }, max: 50),
            ),
            _labeled(
              'Rooms / floor',
              _stepper(roomsPerFloor, (v) {
                roomsPerFloor = v;
                _applyPattern();
              }, max: 50),
            ),
          ),
          _gap,
          _twoCol(
            _labeled(
              'Beds / room',
              _stepper(bedsPerRoom, (v) {
                bedsPerRoom = v;
                _applyPattern();
              }, max: 12),
            ),
            _boxField(
              'Rent per bed',
              '6,000',
              rentC,
              prefix: '₹ ',
              keyboard: TextInputType.number,
              formatters: [_IndianAmountFormatter()],
              validator: (v) => _required(v, 'Rent'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _gap,
          _dropdownBox<int>(
            'Rent Payment Date',
            paymentDate,
            List.generate(31, (i) => i + 1),
            (v) => setState(() => paymentDate = v),
            hint: 'Select',
            itemLabel: (v) => '$v',
            height: 40,
          ),
        ],
      ),
    ),
    ..._layoutRightColumn(),
    _mCard(
      icon: Icons.description_outlined,
      title: 'Documents (Optional)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Documents',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: _muted)),
          const SizedBox(height: 10),
          _fileGrid(
            files: documents,
            onAdd: _pickDocuments,
            onRemove: (i) => setState(() => documents.removeAt(i)),
            isImage: false,
            existingUrls: existingDocs
                .map((d) => (d['fileName'] ?? d['absolutePath'] ?? '').toString())
                .toList(),
            onRemoveExisting: (i) =>
                setState(() => existingDocs.removeAt(i)),
          ),
        ],
      ),
    ),
  ];

  Widget _amenitiesBody() {
    if (widget.amenitiesLoading && widget.amenityOptions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (widget.amenityOptions.isNotEmpty) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: widget.amenityOptions.map((a) {
          final isSel = selectedAmenityIds.contains(a.id);
          return _chip(a.name, isSel, (val) {
            setState(() {
              if (val) {
                selectedAmenityIds.add(a.id);
                amenityDetailMap[a.id] = a.name;
              } else {
                selectedAmenityIds.remove(a.id);
                amenityDetailMap.remove(a.id);
              }
            });
          });
        }).toList(),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        'Wifi',
        'Hot water',
        'AC',
        'Food',
        'Laundry',
        'Housekeeping',
        'Parking',
        'Power backup',
        'CCTV',
      ].map((name) {
        final isSel = selectedAmenityIds.contains(name);
        return _chip(name, isSel, (val) {
          setState(() {
            if (val) {
              selectedAmenityIds.add(name);
            } else {
              selectedAmenityIds.remove(name);
            }
          });
        });
      }).toList(),
    );
  }

  List<Widget> _layoutLeftColumn() => [
    _mCard(
      icon: Icons.grid_view_rounded,
      title: 'Default pattern',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _twoCol(
            _labeled(
              'No. of floors',
              _stepper(floorsCount, (v) {
                floorsCount = v;
                _applyPattern();
              }, max: 50),
            ),
            _labeled(
              'Rooms / floor',
              _stepper(roomsPerFloor, (v) {
                roomsPerFloor = v;
                _applyPattern();
              }, max: 50),
            ),
          ),
          _gap,
          _twoCol(
            _labeled(
              'Beds / room',
              _stepper(bedsPerRoom, (v) {
                bedsPerRoom = v;
                _applyPattern();
              }, max: 12),
            ),
            _boxField(
              'Rent per bed',
              '6,000',
              rentC,
              prefix: '₹ ',
              keyboard: TextInputType.number,
              formatters: [_IndianAmountFormatter()],
              validator: (v) => _required(v, 'Rent'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _gap,
          _twoCol(
            _boxField(
              'Security advance',
              'e.g. 12,000',
              advanceC,
              prefix: '₹ ',
              keyboard: TextInputType.number,
              formatters: [_IndianAmountFormatter()],
              validator: (v) => _required(v, 'Advance'),
            ),
            _dropdownBox<int>(
              'Rent Payment Date',
              paymentDate,
              List.generate(31, (i) => i + 1),
                  (v) => setState(() => paymentDate = v),
              hint: 'Select',
              itemLabel: (v) => '$v',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Changing the pattern re-applies it to every floor.',
            style: TextStyle(fontSize: 12, color: _muted),
          ),
        ],
      ),
    ),
    Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.currency_rupee,
              color: Color(0xFF16A34A), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated revenue at full capacity',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '₹ ${_money(_estRevenue)} / month',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF14532D)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ];

  List<Widget> _layoutRightColumn() => [
    const Align(
      alignment: Alignment.centerLeft,
      child: Text('Per-floor exceptions',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: _ink)),
    ),
    const SizedBox(height: 6),
    const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Expand a floor, open Room details, and tap a vacant bed to add a tenant.',
        style: TextStyle(fontSize: 13.5, color: _muted),
      ),
    ),
    const SizedBox(height: 16),
    for (int i = 0; i < floors.length; i++) _floorCard(i),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tileBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '${_plural(floors.length, 'floor')}, ${_plural(_totalRooms, 'room')}, ${_plural(_totalBeds, 'bed')}.',
        style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
      ),
    ),
  ];

  Widget _floorCard(int fi) {
    final f = floors[fi];
    final expanded = expandedFloor == fi;
    final beds = f.rooms.fold<int>(0, (s, r) => s + r.beds.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: expanded ? const Color(0xFFBFD6FF) : _line,
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() {
              expandedFloor = expanded ? -1 : fi;
              selectedRoomIndex = 0;
            }),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.layers_outlined,
                        color: _blue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.name,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: _ink)),
                        const SizedBox(height: 2),
                        Text(
                          '${_plural(f.rooms.length, 'room')} · ${_plural(beds, 'bed')}',
                          style:
                          const TextStyle(fontSize: 13, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openEditFloor(fi),
                    child: const Text('edit',
                        style: TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _blue,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: _line),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _floorBody(fi),
            ),
          ],
        ],
      ),
    );
  }

  Widget _floorBody(int fi) {
    final f = floors[fi];
    final hasRooms = f.rooms.isNotEmpty;
    final ri = hasRooms
        ? selectedRoomIndex.clamp(0, f.rooms.length - 1).toInt()
        : 0;
    final room = hasRooms ? f.rooms[ri] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rooms',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _blue)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < f.rooms.length; i++)
              _roomChip(
                f.rooms[i].name,
                f.rooms[i].beds.length,
                i == ri,
                    () => setState(() => selectedRoomIndex = i),
              ),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => setState(() {
                f.rooms.add(_newRoom(fi, f.rooms.length));
                selectedRoomIndex = f.rooms.length - 1;
              }),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFBFD6FF)),
                ),
                child: const Icon(Icons.add, color: _blue, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (room == null)
          const Text('No rooms on this floor. Tap + to add one.',
              style: TextStyle(fontSize: 13, color: _muted))
        else ...[
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openRoomDetails(fi, ri),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.meeting_room_outlined, color: _blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Room details',
                        style: TextStyle(fontSize: 15, color: _ink)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: _blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${room.name} beds',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                    ),
                    InkWell(
                      onTap: () => _openEditBeds(room),
                      child: const Text('Edit beds',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_plural(room.beds.length, 'bed')} · ${room.beds.where((b) => b.isOccupied).length} occupied',
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                  room.beds.map((b) => _bedTile(room, b)).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _roomChip(
      String label, int count, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _blue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? _blue : _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _ink)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : _tileBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _blue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bedTile(_PgRoomDraft room, _PgBedDraft bed) {
    final occ = bed.isOccupied;
    final fg = occ ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openBedDialog(room, bed),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: occ ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
              occ ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bed_outlined, size: 20, color: fg),
            const SizedBox(height: 4),
            Text(
              occ
                  ? (bed.tenantName.isEmpty ? 'Occupied' : bed.tenantName)
                  : 'Vacant',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: fg),
            ),
            const SizedBox(height: 2),
            Text('₹${_money(_bedRent(room, bed))}',
                style: const TextStyle(fontSize: 12, color: _muted)),
          ],
        ),
      ),
    );
  }
  Widget _mCard({
    required IconData icon,
    required String title,
    Widget? child,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: _blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _ink),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          if (child != null) ...[
            const Divider(height: 1, color: _line),
            Padding(
              padding: const EdgeInsets.all(18),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _circleAdd(VoidCallback onTap) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration:
        const BoxDecoration(color: _lightBlue, shape: BoxShape.circle),
        child: const Icon(Icons.add, color: _blue, size: 20),
      ),
    );
  }

  Widget _twoCol(Widget a, Widget b) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: a),
      const SizedBox(width: 20),
      Expanded(child: b),
    ],
  );

  Widget _labeled(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _muted)),
      const SizedBox(height: 8),
      child,
    ],
  );

  Widget _stepper(int value, ValueChanged<int> onChanged,
      {int min = 1, int max = 50}) {
    Widget btn(IconData icon, bool enabled, VoidCallback tap) => InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? tap : null,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            size: 18,
            color: enabled ? _blue : const Color(0xFF9DB7E8)),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove, value > min, () => onChanged(value - 1)),
          const SizedBox(width: 14),
          Text('$value',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _blue)),
          const SizedBox(width: 14),
          btn(Icons.add, value < max, () => onChanged(value + 1)),
        ],
      ),
    );
  }

  /// Underline-style field, like the mobile app.
  Widget _uField(
      String label,
      String hint,
      TextEditingController controller, {
        String? prefix,
        Widget? suffix,
        TextInputType? keyboard,
        List<TextInputFormatter>? formatters,
        String? Function(String?)? validator,
        int maxLines = 1,
        bool readOnly = false,
        VoidCallback? onTap,
      }) {
    const underline = UnderlineInputBorder(borderSide: BorderSide(color: _line));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w500, color: _muted)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboard,
          inputFormatters: formatters,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: _ink),
          decoration: InputDecoration(
            filled: false,
            fillColor: Colors.transparent,
            hoverColor: Colors.transparent,
            hintText: hint,
            hintStyle:
            const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
            prefixText: prefix,
            prefixStyle: const TextStyle(
                color: _ink, fontWeight: FontWeight.w600, fontSize: 15),
            suffixIcon: suffix,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: underline,
            enabledBorder: underline,
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _blue, width: 1.5)),
            errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEF4444))),
            focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEF4444), width: 1.5)),
          ),
        ),
      ],
    );
  }

  /// Rounded grey box field (used for rent, like the mobile app).
  Widget _boxField(
      String label,
      String hint,
      TextEditingController controller, {
        String? prefix,
        TextInputType? keyboard,
        List<TextInputFormatter>? formatters,
        String? Function(String?)? validator,
        ValueChanged<String>? onChanged,
      }) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );
    return _labeled(
      label,
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatters,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: _ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
              fontWeight: FontWeight.w400),
          prefixText: prefix,
          prefixStyle: const TextStyle(
              color: _blue, fontWeight: FontWeight.w700, fontSize: 16),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: b(_line),
          enabledBorder: b(_line),
          focusedBorder: b(_blue, 1.5),
          errorBorder: b(const Color(0xFFEF4444)),
          focusedErrorBorder: b(const Color(0xFFEF4444), 1.5),
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
        String Function(T)? itemLabel,
        double? height,
        double menuMaxHeight = 220,
      }) {
    final list =
    (value != null && !items.contains(value)) ? [...items, value] : items;

    return _labeled(
      label,
      Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF8FAFC),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(hint,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
            isExpanded: true,
            isDense: height != null,
            menuMaxHeight: menuMaxHeight,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            items: list
                .map((e) => DropdownMenuItem<T>(
              value: e,
              child: Text(
                itemLabel != null ? itemLabel(e) : '$e',
                style: const TextStyle(fontSize: 14),
              ),
            ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: _lightBlue,
      labelStyle: TextStyle(
        fontSize: 13.5,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? _blue : const Color(0xFF334155),
      ),
      shape: StadiumBorder(
        side: BorderSide(color: selected ? _blue : const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  Widget _hintBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFD6FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: _blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          ),
        ],
      ),
    );
  }

  Widget _fileGrid({
    required List<PickedFile> files,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
    required bool isImage,
    List<String> existingUrls = const [],
    ValueChanged<int>? onRemoveExisting,
    double? tileWidth,
    double? tileHeight,
  }) {
    final double w = tileWidth ?? 130;
    final double h = tileHeight ?? (isImage ? 170 : 130);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onAdd,
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: _tileBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _blue),
            ),
            child: Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: _blue, size: 24),
              ),
            ),
          ),
        ),
        ...existingUrls.asMap().entries.map((entry) {
          final idx = entry.key;
          final url = entry.value;
          return Stack(
            children: [
              Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _line),
                ),
                clipBehavior: Clip.antiAlias,
                child: isImage
                    ? Image.network(url, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            color: _muted))
                    : const Icon(Icons.insert_drive_file_outlined,
                        size: 30, color: _blue),
              ),
              if (onRemoveExisting != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => onRemoveExisting(idx),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        }),
        ...files.asMap().entries.map((entry) {
          final idx = entry.key;
          final f = entry.value;
          return Stack(
            children: [
              Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _line),
                ),
                clipBehavior: Clip.antiAlias,
                child: isImage
                    ? Image.memory(f.bytes, fit: BoxFit.cover)
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 30, color: _blue),
                    const SizedBox(height: 4),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        f.name,
                        style: const TextStyle(fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => onRemove(idx),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child:
                    const Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
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