import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';

class SearchField extends StatefulWidget {
  final String hint;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.hint = 'Search...',
    this.initialValue,
    required this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _showClear = _controller.text.isNotEmpty;
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _showClear = _controller.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue!;
      _showClear = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 42,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.textMuted,
            size: 20,
          ),
          suffixIcon: _showClear
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    if (widget.onClear != null) widget.onClear!();
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.brandWhite,
          hoverColor: AppTheme.brandWhite,
          focusColor: AppTheme.brandWhite,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.accentGreen),
          ),
        ),
      ),
    );
  }
}
