import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design/budgetr_colors.dart';

class SecureTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;
  final bool isSecureByDefault;
  final bool isNumeric;

  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  // [NEW] Added errorText and onChanged for inline validation
  final String? errorText;
  final void Function(String)? onChanged;

  const SecureTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.isSecureByDefault = true,
    this.isNumeric = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.errorText, // [NEW]
    this.onChanged, // [NEW]
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isSecureByDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged, // [NEW] Bind onChanged
        obscureText: _isObscured,
        inputFormatters: widget.inputFormatters,
        keyboardType: widget.isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : widget.keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.white54),
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
          prefixIcon: Icon(widget.icon,
              color: BudgetrColors.accent.withOpacity(0.7), size: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.03),

          // [NEW] Setup Error Styling
          errorText: widget.errorText,
          errorStyle: const TextStyle(
              color: Colors.redAccent, fontWeight: FontWeight.w600),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: BudgetrColors.accent.withOpacity(0.6), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          suffixIcon: widget.isSecureByDefault
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                )
              : null,
        ),
      ),
    );
  }
}
