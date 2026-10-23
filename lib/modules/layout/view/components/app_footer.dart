import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agremate_admin/core/theme/theme.dart';

class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  bool _isHovered = false;

  Future<void> _launchWebsite() async {
    final uri = Uri.parse('https://www.agremate.com');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, webOnlyWindowName: '_blank');
      } else {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              '© 2025 AGREMATE Private Limited. All rights reserved.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '·',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: _launchWebsite,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isHovered
                        ? AppTheme.accentGreen
                        : AppTheme.brandSteelBlue,
                    decoration: _isHovered
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: AppTheme.accentGreen,
                  ),
                  child: const Text('www.agremate.com'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
