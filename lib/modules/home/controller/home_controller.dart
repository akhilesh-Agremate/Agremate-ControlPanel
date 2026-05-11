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
  var globalPeriod = 'This Month'.obs;
  var rentPeriod = 'This Month'.obs;
  var pendingPeriod = 'This Month'.obs;
  var subAmountPeriod = 'This Month'.obs;
  var subExpiredPeriod = 'This Month'.obs;

  void updateGlobalPeriod(String newPeriod) {
    globalPeriod.value = newPeriod;
    rentPeriod.value = newPeriod;
    pendingPeriod.value = newPeriod;
    subAmountPeriod.value = newPeriod;
    subExpiredPeriod.value = newPeriod;
  }

  // Detail view state
  var selectedSubscription = Rxn<Map<String, dynamic>>();

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
  final List<Map<String, dynamic>> recentRent = List.generate(
    10,
    (i) => {
      'title': 'Green Villa ${i + 1}',
      'detail':
          'Landlord: John Doe ${i + 1} | Tenant: Alex Smith ${i + 1}\nRent: ₹${25000 + i * 500}',
      'propertyName': 'Green Villa ${i + 1}',
      'tenantName': 'Alex Smith ${i + 1}',
      'landlordName': 'John Doe ${i + 1}',
      'rentAmount': '₹${25000 + i * 500}',
      'advanceAmount': '₹${(25000 + i * 500) * 3}',
      'location': 'Mumbai Block ${i + 10}',
      'propertyImage':
          'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=600&h=300&auto=format&fit=crop',
      'propertyStatus': 'Rented',
      'joinedDate': 'Jan 2024',
    },
  );
  final List<String> _indianNames = [
    'Aarav',
    'Vivaan',
    'Aditya',
    'Vihaan',
    'Arjun',
    'Sai',
    'Ayaan',
    'Krishna',
    'Ishaan',
    'Shaurya',
  ];
  final List<String> _indianLastNames = [
    'Patel',
    'Sharma',
    'Singh',
    'Kumar',
    'Das',
    'Bose',
    'Gupta',
    'Mehta',
    'Trivedi',
    'Jain',
  ];

  late final List<Map<String, dynamic>> recentSubs = List.generate(10, (i) {
    String name =
        '${_indianNames[i % _indianNames.length]} ${_indianLastNames[(i + 2) % _indianLastNames.length]}';
    int propertyCount =
        (i % 5 == 0)
            ? 12
            : ((i % 3 == 0) ? 7 : (i % 4) + 1); // Mix of 1-4, 7, 12 properties
    String plan;
    int maxProps;
    if (propertyCount >= 10) {
      plan = 'Custom Subscription';
      maxProps = propertyCount + 5;
    } else if (propertyCount >= 6) {
      plan = '₹799 Subscription';
      maxProps = 10;
    } else {
      plan = '₹299 Subscription';
      maxProps = 5;
    }

    List<Map<String, String>> properties = List.generate(propertyCount, (
      pIndex,
    ) {
      bool isBooked = (pIndex % 2 == 0); // Alternate booked/available
      return {
        'name': 'Property ${100 + i * 10 + pIndex}',
        'location': 'Block ${String.fromCharCode(65 + pIndex)}, Mumbai',
        'status': isBooked ? 'Booked' : 'Available',
        'tenantName':
            isBooked ? _indianNames[(i + pIndex) % _indianNames.length] : '',
        'tenantPhone': isBooked ? '+91 98765${12345 + i + pIndex}' : '',
        'tenantEmail':
            isBooked
                ? '${_indianNames[(i + pIndex) % _indianNames.length].toLowerCase()}@example.com'
                : '',
        'joinedDate': 'Jan 2024',
      };
    });

    return {
      'title': name,
      'detail': 'Plan: $plan',
      'propertyName': 'Multiple Properties ($propertyCount)',
      'landlordName': name,
      'subscriptionPlan': plan,
      'propertyCount': propertyCount,
      'maxProperties': maxProps,
      'usedProperties': propertyCount,
      'totalProperties': maxProps,
      'landlordDetails':
          'Email: ${name.toLowerCase().split(' ')[0]}@example.com\nPhone: +91 98765${43210 + i}',
      'properties': properties,
      'status': i % 4 == 0 ? 'Expired' : 'Active',
    };
  });
  late final List<Map<String, dynamic>> recentServices = List.generate(10, (i) {
    bool isSolved = i % 3 == 0;
    final issues = [
      'Plumbing Leak',
      'Electrical Repair',
      'Maintenance Request',
      'AC Servicing',
      'Painting Work',
      'Carpentry Issue',
    ];
    String issue = issues[i % issues.length];
    final String tenantName =
        '${_indianNames[i % _indianNames.length]} ${_indianLastNames[(i + 1) % _indianLastNames.length]}';
    final String landlordName =
        '${_indianNames[(i + 1) % _indianNames.length]} ${_indianLastNames[i % _indianLastNames.length]}';

    // Generate mock chat messages for this service request
    final List<Map<String, dynamic>> chatMessages =
        i % 4 == 1
            ? [] // Some have no chat yet
            : [
              {
                'sender': 'tenant',
                'senderName': tenantName,
                'message':
                    'Hi, I wanted to report a $issue problem in the property. It needs urgent attention.',
                'time': 'May ${10 + i}, 2024 · 09:15 AM',
                'isRead': true,
              },
              {
                'sender': 'landlord',
                'senderName': landlordName,
                'message':
                    'Thanks for letting me know. I\'ll arrange for someone to come and check it as soon as possible.',
                'time': 'May ${10 + i}, 2024 · 10:30 AM',
                'isRead': true,
              },
              {
                'sender': 'tenant',
                'senderName': tenantName,
                'message': 'Please hurry, it\'s causing inconvenience.',
                'time': 'May ${10 + i}, 2024 · 11:00 AM',
                'isRead': true,
              },
              if (isSolved) ...[
                {
                  'sender': 'landlord',
                  'senderName': landlordName,
                  'message':
                      'The technician visited today and fixed the issue. Please let me know if everything is fine now.',
                  'time': 'May ${12 + i}, 2024 · 03:45 PM',
                  'isRead': true,
                },
                {
                  'sender': 'tenant',
                  'senderName': tenantName,
                  'message': 'Yes, all good now. Thank you for the quick resolution! 👍',
                  'time': 'May ${12 + i}, 2024 · 04:10 PM',
                  'isRead': true,
                },
              ] else ...[
                {
                  'sender': 'landlord',
                  'senderName': landlordName,
                  'message': 'I have scheduled a technician for tomorrow morning. Please be available.',
                  'time': 'May ${11 + i}, 2024 · 06:00 PM',
                  'isRead': false,
                },
              ],
            ];

    return {
      'title': 'Green Villa ${i + 1}',
      'propertyName': 'Green Villa ${i + 1}',
      'detail': 'Issue: $issue',
      'landlordName': landlordName,
      'tenantName': tenantName,
      'location': 'Mumbai Block ${i + 5}',
      'raisedDate': 'May ${10 + i}, 2024',
      'resolvedDate': isSolved ? 'May ${12 + i}, 2024' : null,
      'status': isSolved ? 'Solved' : 'Pending',
      'activeStatus': isSolved ? 'Completed' : 'Active',
      'chatMessages': chatMessages,
    };
  });
  late final List<Map<String, dynamic>> propertyList = List.generate(10, (i) {
    final landlord =
        '${_indianNames[(i + 2) % _indianNames.length]} ${_indianLastNames[(i + 1) % _indianLastNames.length]}';
    return {
      'title': 'Green Villa ${i + 1}',
      'landlordName': landlord,
      'location': 'Block ${101 + i}, Mumbai',
      'status': i % 2 == 0 ? 'Available' : 'Rented',
      'joinedDate': 'Jan 2024',
      'propertyImages': List.generate((i == 0) ? 15 : ((i % 3 == 0) ? 12 : 3), (
        index,
      ) {
        final List<String> villaImages = [
          'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600585154340-be6191da95b4?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1480074568708-e7b720bb3f09?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=400&h=400&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1449156001437-37c647dce501?q=80&w=400&h=400&auto=format&fit=crop',
        ];
        return villaImages[index % villaImages.length];
      }),
      'detail':
          'Landlord: $landlord | Location: Block ${101 + i}\nStatus: ${i % 2 == 0 ? 'Available' : 'Rented'}',
    };
  });
  late final List<Map<String, dynamic>> documentList = List.generate(
    10,
    (i) => {
      'title': 'Lease_Agreement_${i + 1}.pdf',
      'propertyName': 'Green Villa ${i + 1}',
      'landlordName':
          _indianNames[i % _indianNames.length] +
          ' ' +
          _indianLastNames[(i + 1) % _indianLastNames.length],
      'fileTypes': ['pdf', 'jpg', 'doc', 'svg'].take((i % 4) + 1).toList(),
      'date': 'Oct ${10 + i}, 2023',
      'detail': 'Landlord: John Doe | Tenant: Alex Smith',
    },
  );
  late final List<Map<String, dynamic>> supportList = List.generate(10, (i) {
    final categories = ['Technical', 'Billing', 'Account', 'General'];
    final statuses = ['Pending', 'In Progress', 'Solved'];
    final messages = [
      'System login issue',
      'Payment failure',
      'Update profile details',
      'Feature request',
      'Bug report',
    ];
    final status = statuses[i % statuses.length];
    return {
      'title': 'Ticket #${i + 1001}',
      'category': categories[i % categories.length],
      'status': status,
      'message': messages[i % messages.length],
      'date': 'May ${15 + i}, 2024',
      'resolvedDate': status == 'Solved' ? 'May ${17 + i}, 2024' : null,
      'detail':
          'Category: ${categories[i % categories.length]} | Status: $status\nMessage: ${messages[i % messages.length]}',
    };
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
