import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthCustomTextFormField extends StatefulWidget {
  final GlobalKey<FormFieldState> keyField;
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputters;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const AuthCustomTextFormField({
    super.key,
    required this.keyField,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.inputters,
    this.validator,
    this.focusNode
  });

  @override
  State<AuthCustomTextFormField> createState() => _AuthCustomTextFormFieldState();
}

class _AuthCustomTextFormFieldState extends State<AuthCustomTextFormField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  InputDecoration _inputDecoration(String label, Widget? icon) {
    return InputDecoration(
      labelText: label,
      suffixIcon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      key: widget.keyField,
      controller: widget.controller,
      decoration: _inputDecoration(
        widget.label,
        widget.obscure
            ? IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
        )
            : null,
      ),
      obscureText: _obscure,
      focusNode: widget.focusNode,
      validator: widget.validator,
      inputFormatters: widget.inputters,
      keyboardType: widget.keyboardType,
      onTap: () {
        if (!widget.keyField.currentState!.hasError) return;
        final text = widget.controller.text;
        widget.keyField.currentState?.reset();
        widget.controller.text = text;
      },
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },
    );
  }
}
