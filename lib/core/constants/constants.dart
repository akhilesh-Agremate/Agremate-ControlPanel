import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Agremate Admin';
  static const String appVersion = '1.0.0';
  static const String currency = '₹';
  static const String currencyCode = 'INR';

  // Service types
  static const List<String> serviceTypes = [
    'Plumbing',
    'Electricity',
    'Pest Control',
    'Community',
    'Mechanical',
    'Maintenance',
    'Security',
    'Others',
  ];

  static const Map<String, IconData> serviceIcons = {
    'Plumbing': Icons.plumbing,
    'Electricity': Icons.electrical_services,
    'Pest Control': Icons.bug_report,
    'Community': Icons.groups,
    'Mechanical': Icons.build,
    'Maintenance': Icons.handyman,
    'Security': Icons.security,
    'Others': Icons.more_horiz,
  };

  static const Map<String, Color> serviceColors = {
    'Plumbing':     Color(0xFF2083D5), // Steel Blue
    'Electricity':  Color(0xFF6CA0DA), // Blue Grey
    'Pest Control': Color(0xFF2083D5), // Steel Blue
    'Community':    Color(0xFF6CA0DA), // Blue Grey
    'Mechanical':   Color(0xFF2083D5), // Steel Blue
    'Maintenance':  Color(0xFFE24B4A), // Red (error/maintenance)
    'Security':     Color(0xFF6CA0DA), // Blue Grey
    'Others':       Color(0xFFCEE1F3), // Pale Sky
  };

  static const int propertiesPerPage = 30;

  // Nav items
  static const List<Map<String, dynamic>> navItems = [
    {'icon': Icons.home_rounded, 'label': 'Home', 'index': 0},
    {'icon': Icons.apartment_rounded, 'label': 'Property', 'index': 1},
    {'icon': Icons.home_repair_service_rounded, 'label': 'Services', 'index': 2},
    {'icon': Icons.account_balance_wallet_rounded, 'label': 'Finance', 'index': 3},
    {'icon': Icons.folder_rounded, 'label': 'Documents', 'index': 4},
    {'icon': Icons.group_rounded, 'label': 'User', 'index': 6},
  ];
}
