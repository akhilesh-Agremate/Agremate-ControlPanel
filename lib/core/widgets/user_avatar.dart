import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 56,
    this.color = const Color(0xFF2083D5),
  });

  final String name;
  final String? imageUrl;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    Widget letter() => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (!hasImage) return letter();

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (c, child, progress) =>
        progress == null ? child : letter(),
        errorBuilder: (c, e, s) => letter(),
      ),
    );
  }
}