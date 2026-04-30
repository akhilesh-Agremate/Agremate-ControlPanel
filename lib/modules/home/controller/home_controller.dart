import 'package:get/get.dart';

class HomeController extends GetxController {
  final List<String> periods = [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
  ];

  // Selected periods for each card
  var rentPeriod = 'This Month'.obs;
  var pendingPeriod = 'This Month'.obs;
  var subAmountPeriod = 'This Month'.obs;
  var subExpiredPeriod = 'This Month'.obs;

  // Mock data mapping
  final Map<String, Map<String, String>> mockData = {
    'Total Rent Collections': {
      'This Month': '₹4,50,000',
      'Last Month': '₹4,20,000',
      'Last 3 Months': '₹12,80,000',
      'Last 6 Months': '₹25,40,000',
      'Last Year': '₹52,00,000',
    },
    'Pending Payments': {
      'This Month': '₹85,000',
      'Last Month': '₹62,000',
      'Last 3 Months': '₹1,45,000',
      'Last 6 Months': '₹2,10,000',
      'Last Year': '₹3,50,000',
    },
    'Total Subscriptions': {
      'This Month': '₹1,20,000',
      'Last Month': '₹1,15,000',
      'Last 3 Months': '₹3,50,000',
      'Last 6 Months': '₹6,80,000',
      'Last Year': '₹14,20,000',
    },
    'Subscription Expired': {
      'This Month': '12',
      'Last Month': '8',
      'Last 3 Months': '45',
      'Last 6 Months': '92',
      'Last Year': '185',
    },
  };

  // Expanded states for lists
  var expandedLists = <String, bool>{}.obs;

  void toggleList(String key) {
    expandedLists[key] = !(expandedLists[key] ?? false);
  }

  // Mock data for lists
  final List<Map<String, dynamic>> recentRent = List.generate(10, (i) => {
    'title': 'Green Villa ${i + 1}', 
    'detail': 'Landlord: John Doe ${i + 1} | Tenant: Alex Smith ${i + 1}\nRent: ₹${25000 + i * 500}',
    'propertyName': 'Green Villa ${i + 1}',
    'tenantName': 'Alex Smith ${i + 1}',
    'landlordName': 'John Doe ${i + 1}',
    'rentAmount': '₹${25000 + i * 500}',
    'advanceAmount': '₹${(25000 + i * 500) * 3}',
    'location': 'Mumbai Block ${i + 10}',
    'propertyImage': 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=600&h=300&auto=format&fit=crop',
    'propertyStatus': 'Rented',
  });
  final List<String> _indianNames = ['Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Ayaan', 'Krishna', 'Ishaan', 'Shaurya'];
  final List<String> _indianLastNames = ['Patel', 'Sharma', 'Singh', 'Kumar', 'Das', 'Bose', 'Gupta', 'Mehta', 'Trivedi', 'Jain'];

  late final List<Map<String, dynamic>> recentSubs = List.generate(10, (i) {
    String name = '${_indianNames[i % _indianNames.length]} ${_indianLastNames[(i+2) % _indianLastNames.length]}';
    int propertyCount = (i % 5 == 0) ? 12 : ((i % 3 == 0) ? 7 : (i % 4) + 1); // Mix of 1-4, 7, 12 properties
    String plan;
    if (propertyCount >= 10) {
      plan = 'Custom Subscription';
    } else if (propertyCount >= 6) {
      plan = '₹799 Subscription';
    } else {
      plan = '₹299 Subscription';
    }
    
    List<Map<String, String>> properties = List.generate(propertyCount, (pIndex) {
      bool isBooked = (pIndex % 2 == 0); // Alternate booked/available
      return {
        'name': 'Property ${100 + i * 10 + pIndex}',
        'location': 'Block ${String.fromCharCode(65 + pIndex)}, Mumbai',
        'status': isBooked ? 'Booked' : 'Available',
        'tenantName': isBooked ? '${_indianNames[(i+pIndex) % _indianNames.length]} Tenant' : '',
      };
    });

    return {
      'title': name, 
      'detail': '$propertyCount Properties | Plan: $plan',
      'propertyName': 'Multiple Properties ($propertyCount)',
      'landlordName': name,
      'subscriptionPlan': plan,
      'landlordDetails': 'Email: ${name.toLowerCase().split(' ')[0]}@example.com\nPhone: +91 98765${43210+i}',
      'properties': properties,
    };
  });
  final List<Map<String, dynamic>> recentServices = List.generate(10, (i) => {
    'title': 'Blue Villa ${i + 1}', 
    'detail': 'Issue: Plumbing Leak\nStatus: High Priority'
  });
  final List<Map<String, dynamic>> propertyList = List.generate(10, (i) => {
    'title': 'Ocean Villa ${i + 1}', 
    'detail': 'Landlord: Robert Brown | Location: Block ${101 + i}\nStatus: Available'
  });
  final List<Map<String, dynamic>> documentList = List.generate(10, (i) => {
    'title': 'Lease_Agreement_${i + 1}.pdf', 
    'detail': 'Landlord: John Doe | Tenant: Alex Smith'
  });
  final List<Map<String, dynamic>> supportList = List.generate(10, (i) => {
    'title': 'Support Ticket ${i + 1}', 
    'detail': 'Category: Billing\nStatus: Open'
  });

  String getAmount(String label, String period) {
    return mockData[label]?[period] ?? '0';
  }

  void updatePeriod(String cardLabel, String period) {
    if (cardLabel == 'Total Rent Collections') rentPeriod.value = period;
    if (cardLabel == 'Pending Payments') pendingPeriod.value = period;
    if (cardLabel == 'Total Subscriptions') subAmountPeriod.value = period;
    if (cardLabel == 'Subscription Expired') subExpiredPeriod.value = period;
  }

  RxString getPeriodVar(String cardLabel) {
    if (cardLabel == 'Total Rent Collections') return rentPeriod;
    if (cardLabel == 'Pending Payments') return pendingPeriod;
    if (cardLabel == 'Total Subscriptions') return subAmountPeriod;
    return subExpiredPeriod;
  }
}
