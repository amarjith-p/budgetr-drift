import 'package:flutter/material.dart';
import '../../../../core/models/custom_data_models.dart';

class DropdownInputBlock extends StatefulWidget {
  final CustomFieldConfig field;
  final Color accentColor;

  const DropdownInputBlock(
      {super.key, required this.field, required this.accentColor});

  @override
  State<DropdownInputBlock> createState() => _DropdownInputBlockState();
}

class _DropdownInputBlockState extends State<DropdownInputBlock> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addOption() {
    final val = _controller.text.trim();
    if (val.isNotEmpty) {
      setState(() {
        (widget.field.dropdownOptions ??= []).add(val);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (widget.field.dropdownOptions ?? [])
                .map(
                  (opt) => Chip(
                    label: Text(
                      opt,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: widget.accentColor.withOpacity(0.2),
                    deleteIconColor: Colors.white70,
                    onDeleted: () => setState(
                      () => widget.field.dropdownOptions!.remove(opt),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add option...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black12,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onFieldSubmitted: (_) => _addOption(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle, color: widget.accentColor),
                onPressed: _addOption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
