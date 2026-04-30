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
    'Plumbing': Color(0xFF00BCD4),
    'Electricity': Color(0xFFFFB300),
    'Pest Control': Color(0xFF4CAF50),
    'Community': Color(0xFF9C27B0),
    'Mechanical': Color(0xFFFF5722),
    'Maintenance': Color(0xFF2196F3),
    'Security': Color(0xFFE91E63),
    'Others': Color(0xFF607D8B),
  };

  static const int propertiesPerPage = 30;

  // Nav items
  static const List<Map<String, dynamic>> navItems = [
    {'icon': Icons.home_rounded, 'label': 'Home', 'index': 0},
    {'icon': Icons.apartment_rounded, 'label': 'Property', 'index': 1},
    {'icon': Icons.home_repair_service_rounded, 'label': 'Services', 'index': 2},
    {'icon': Icons.account_balance_wallet_rounded, 'label': 'Finance', 'index': 3},
    {'icon': Icons.folder_rounded, 'label': 'Documents', 'index': 4},
    {'icon': Icons.support_agent_rounded, 'label': 'Support', 'index': 5},
    {'icon': Icons.group_rounded, 'label': 'User', 'index': 6},
  ];
}
