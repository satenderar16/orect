import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledFormField extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final bool? enabled;
  final GlobalKey<FormFieldState> fieldKey;
  final List<TextInputFormatter>? inputFormatters;

  const LabeledFormField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.obscureText,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    required this.fieldKey,
    this.inputFormatters,
  });

  @override
  State<LabeledFormField> createState() => _LabeledFormFieldState();
}

class _LabeledFormFieldState extends State<LabeledFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label ?? "", style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        TextFormField(
          key: widget.fieldKey,
          controller: widget.controller,
          validator: widget.validator ?? (val) {
            if (val == null || val.isEmpty) return 'Required';
            return null;
          },
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            hintText: widget.label,
            suffixIcon: (widget.obscureText ?? false)
                ? IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _obscure = !_obscure;
                });
              },
            )
                : null,
          ),
          onTap: () {
            if (!widget.fieldKey.currentState!.hasError) return;
            final text = widget.controller.text;
            widget.fieldKey.currentState!.reset();
            widget.controller.text = text;
          },
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }
}
