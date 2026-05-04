import 'dart:math';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';

class PropertyController extends GetxController {
  final landlords = <LandlordModel>[].obs;
  final tenants = <TenantModel>[].obs;
  final properties = <PropertyModel>[].obs;
  final filteredProperties = <PropertyModel>[].obs;
  final currentPage = 1.obs;
  final searchQuery = ''.obs;
  final isLoading = true.obs;
  final selectedProperty = Rxn<PropertyModel>();
  final returnTabIndex = Rxn<int>();
  final selectedLandlordDetail = Rxn<LandlordModel>();
  final selectedTenantDetail = Rxn<TenantModel>();

  static const int perPage = 30;
  final _rng = Random(42);

  int get totalPages => (filteredProperties.length / perPage).ceil();

  List<PropertyModel> get currentPageProperties {
    final start = (currentPage.value - 1) * perPage;
    final end = min(start + perPage, filteredProperties.length);
    if (start >= filteredProperties.length) return [];
    return filteredProperties.sublist(start, end);
  }

  // Recent logins (top 10 mixed landlords and tenants)
  List<Map<String, dynamic>> get recentLogins {
    final List<Map<String, dynamic>> logins = [];
    for (final l in landlords) {
      logins.add({'type': 'landlord', 'name': l.name, 'time': l.lastLogin, 'id': l.id, 'count': l.propertyCount});
    }
    for (final t in tenants) {
      logins.add({'type': 'tenant', 'name': t.name, 'time': t.lastLogin, 'id': t.id, 'property': t.propertyName});
    }
    logins.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    return logins.take(10).toList();
  }

  // Revenue data for chart
  List<Map<String, dynamic>> get landlordRevenueData {
    return landlords.take(10).map((l) => {
      'name': l.name.split(' ').first,
      'revenue': l.totalRevenue,
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _generateData();
  }

  void _generateData() {
    isLoading.value = true;
    final names = [
      'Rajesh Sharma', 'Priya Patel', 'Amit Kumar', 'Sunita Gupta', 'Vikram Singh',
      'Neha Verma', 'Rahul Joshi', 'Anita Desai', 'Suresh Reddy', 'Kavita Nair',
      'Mohan Das', 'Deepa Iyer', 'Arun Mehta', 'Pooja Shah', 'Sanjay Kapoor',
      'Ritu Agarwal', 'Manoj Tiwari', 'Swati Mishra', 'Kiran Rao', 'Geeta Bhat',
    ];
    final cities = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Pune', 'Hyderabad', 'Kolkata', 'Ahmedabad'];
    final propTypes = ['Apartment', 'Villa', 'Commercial', 'Studio', 'Penthouse', 'Duplex'];
    final areas = ['Green', 'Ocean', 'Blue', 'Whitefield', 'Bandra', 'Juhu', 'Powai', 'Malad', 'Goregaon', 'Thane', 'Worli', 'Dadar', 'Kurla',
                   'Indiranagar', 'Koramangala', 'Whitefield', 'HSR Layout', 'Jayanagar', 'MG Road', 'BTM Layout'];

    // Generate landlords
    final landlordList = <LandlordModel>[];
    for (int i = 0; i < 15; i++) {
      landlordList.add(LandlordModel(
        id: 'L${i + 1}',
        name: names[i],
        phone: '+91 ${9000000000 + _rng.nextInt(999999999)}',
        email: '${names[i].split(' ').first.toLowerCase()}@email.com',
        propertyIds: List.generate(_rng.nextInt(8) + 1, (j) => 'P${i * 8 + j + 1}'),
        totalRevenue: (_rng.nextDouble() * 50 + 5) * 100000,
        lastLogin: DateTime.now().subtract(Duration(hours: _rng.nextInt(72))),
      ));
    }
    landlords.value = landlordList;

    // Generate properties
    final propertyList = <PropertyModel>[];
    int propIdx = 0;
    for (final landlord in landlordList) {
      for (final pid in landlord.propertyIds) {
        final units = _rng.nextInt(20) + 1;
        final occupied = _rng.nextInt(units + 1);
        final rent = (_rng.nextDouble() * 80 + 10) * 1000;
        final status = PropertyStatus.values[_rng.nextInt(PropertyStatus.values.length)];
        
        final propertyImages = [
          'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=600&h=300&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&h=300&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&h=300&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&h=300&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600607687940-c52af096999a?q=80&w=600&h=300&auto=format&fit=crop',
        ];

        // Force deterministic names for the first 10 to match Home screen exactly
        String propName;
        if (propIdx < 10) {
          propName = 'Green Villa ${propIdx + 1}';
        } else {
          propName = '${areas[_rng.nextInt(areas.length)]} ${propTypes[_rng.nextInt(propTypes.length)]} ${propIdx + 1}';
        }

        propertyList.add(PropertyModel(
          id: pid,
          name: propName,
          address: '${_rng.nextInt(500) + 1}, ${areas[_rng.nextInt(areas.length)]}, ${cities[_rng.nextInt(cities.length)]}',
          city: cities[_rng.nextInt(cities.length)],
          landlordId: landlord.id,
          landlordName: landlord.name,
          landlordPhone: landlord.phone,
          landlordEmail: landlord.email,
          rentAmount: rent,
          advanceAmount: rent * 3,
          propertyType: propTypes[_rng.nextInt(propTypes.length)],
          totalUnits: units,
          occupiedUnits: occupied,
          status: status,
          imageUrl: propertyImages[_rng.nextInt(propertyImages.length)],
          serviceRequestCounts: {
            'Plumbing': _rng.nextInt(2),
            'Electrical': _rng.nextInt(2),
            'Pest Control': _rng.nextInt(2),
            'Community': _rng.nextInt(2),
            'Mechanical': _rng.nextInt(2),
            'Maintenance': _rng.nextInt(2),
            'Security': _rng.nextInt(2),
            'Others': _rng.nextInt(2),
          },
          serviceRequestMessages: {
            'Plumbing': 'Kitchen sink is leaking and causing a mess in the cabinet. Needs urgent repair.',
            'Electrical': 'Main hall light flickering and sparks seen from the switchboard. Safety concern.',
            'Maintenance': 'Door hinges are squeaking and the balcony railing feels loose.',
          },
          createdAt: DateTime.now().subtract(Duration(days: _rng.nextInt(365))),
        ));
        propIdx++;
      }
    }
    properties.value = propertyList;
    filteredProperties.value = propertyList;

    // Generate tenants
    final tenantNames = [
      'Aarav Menon', 'Ishika Sen', 'Rohan Pillai', 'Diya Chopra', 'Arjun Saxena',
      'Meera Kulkarni', 'Varun Bansal', 'Nisha Pandey', 'Siddharth Jain', 'Tanya Malhotra',
      'Kunal Sinha', 'Shruti Thakur', 'Vivek Chauhan', 'Anjali Dubey', 'Harsh Goyal',
      'Pallavi Rathore', 'Nikhil Yadav', 'Rashmi Bhatt', 'Akash Soni', 'Divya Kaur',
      'Manish Dutta', 'Sneha More', 'Pranav Hegde', 'Ritika Wagh', 'Aditya Bose',
    ];
    final tenantList = <TenantModel>[];
    for (int i = 0; i < 25; i++) {
      final prop = propertyList[_rng.nextInt(propertyList.length)];
      tenantList.add(TenantModel(
        id: 'T${i + 1}',
        name: tenantNames[i],
        phone: '+91 ${9000000000 + _rng.nextInt(999999999)}',
        email: '${tenantNames[i].split(' ').first.toLowerCase()}@email.com',
        propertyId: prop.id,
        propertyName: prop.name,
        rentAmount: prop.rentAmount,
        lastLogin: DateTime.now().subtract(Duration(hours: _rng.nextInt(96))),
        unitNumber: 'Unit ${_rng.nextInt(20) + 1}',
      ));
    }
    tenants.value = tenantList;
    
    // Assign primary tenant names and contact to properties for display
    // First, clear any existing assignments and ensure all properties with tenant-requiring status have mock data
    for (int i = 0; i < properties.length; i++) {
      final prop = properties[i];
      final needsTenant = prop.status == PropertyStatus.rented || 
                          prop.status == PropertyStatus.booked || 
                          prop.status == PropertyStatus.requested;
      
      if (needsTenant) {
        final firstName = tenantNames[_rng.nextInt(tenantNames.length)].split(' ').first;
        final lastName = tenantNames[_rng.nextInt(tenantNames.length)].split(' ').last;
        final tName = '$firstName $lastName';
        
        properties[i] = PropertyModel(
          id: prop.id,
          name: prop.name,
          address: prop.address,
          city: prop.city,
          landlordId: prop.landlordId,
          landlordName: prop.landlordName,
          landlordPhone: prop.landlordPhone,
          landlordEmail: prop.landlordEmail,
          tenantIds: prop.tenantIds,
          rentAmount: prop.rentAmount,
          advanceAmount: prop.advanceAmount,
          propertyType: prop.propertyType,
          totalUnits: prop.totalUnits,
          occupiedUnits: prop.occupiedUnits,
          status: prop.status,
          primaryTenantName: tName,
          primaryTenantPhone: tName.split(' ').first.toLowerCase() == 'a' ? '+91 9876543210' : '+91 ${9000000000 + _rng.nextInt(999999999)}',
          primaryTenantEmail: '${firstName.toLowerCase()}@email.com',
          tenantJoinedDate: DateTime.now().subtract(Duration(days: _rng.nextInt(730))),
          serviceRequestCounts: prop.serviceRequestCounts,
          serviceRequestMessages: prop.serviceRequestMessages,
          createdAt: prop.createdAt,
        );
      }
    }
    
    // Then overlay with actual tenant list if specific matches exist
    for (var tenant in tenantList) {
      final propIdx = properties.indexWhere((p) => p.id == tenant.propertyId);
      if (propIdx != -1) {
        final prop = properties[propIdx];
        final showTenant = prop.status == PropertyStatus.rented || 
                           prop.status == PropertyStatus.booked || 
                           prop.status == PropertyStatus.requested;

        if (showTenant) {
          properties[propIdx] = PropertyModel(
            id: prop.id,
            name: prop.name,
            address: prop.address,
            city: prop.city,
            landlordId: prop.landlordId,
            landlordName: prop.landlordName,
            landlordPhone: prop.landlordPhone,
            landlordEmail: prop.landlordEmail,
            tenantIds: prop.tenantIds,
            rentAmount: prop.rentAmount,
            advanceAmount: prop.advanceAmount,
            propertyType: prop.propertyType,
            totalUnits: prop.totalUnits,
            occupiedUnits: prop.occupiedUnits,
            status: prop.status,
            primaryTenantName: tenant.name,
            primaryTenantPhone: tenant.phone,
            primaryTenantEmail: tenant.email,
            tenantJoinedDate: prop.tenantJoinedDate ?? DateTime.now().subtract(Duration(days: _rng.nextInt(730))),
            serviceRequestCounts: prop.serviceRequestCounts,
            serviceRequestMessages: prop.serviceRequestMessages,
            createdAt: prop.createdAt,
          );
        }
      }
    }
    filteredProperties.value = List.from(properties);

    isLoading.value = false;
  }

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredProperties.value = properties;
    } else {
      filteredProperties.value = properties.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase()) ||
        p.landlordName.toLowerCase().contains(query.toLowerCase()) ||
        p.address.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    currentPage.value = 1;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void addLandlord(String name, String phone, String email) {
    final newId = 'L${landlords.length + 1}';
    landlords.add(LandlordModel(
      id: newId,
      name: name,
      phone: phone,
      email: email,
      lastLogin: DateTime.now(),
    ));
  }

  void deleteLandlord(String id) {
    landlords.removeWhere((l) => l.id == id);
    properties.removeWhere((p) => p.landlordId == id);
    filteredProperties.value = properties;
  }
}
