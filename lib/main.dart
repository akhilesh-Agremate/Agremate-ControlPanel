import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

void main() {
  runApp(const AgremateAdmin());
}

class AgremateAdmin extends StatelessWidget {
  const AgremateAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Agremate Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
