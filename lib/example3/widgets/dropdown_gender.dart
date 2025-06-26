import 'package:flutter/material.dart';

class DropdownGender extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String?> onChanged;

  const DropdownGender({
    Key? key,
    required this.selectedGender,
    required this.onChanged,
  }) : super(key: key);

  static const List<String> genderOptions = [
    'Male',
    'Female',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person, size: 20),
              SizedBox(width: 8),
              Text(
                'Gender *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          ...genderOptions.map((gender) {
            return RadioListTile<String>(
              title: Text(gender),
              value: gender,
              groupValue: selectedGender,
              onChanged: onChanged,
              secondary: Icon(
                gender == 'Male' ? Icons.male : Icons.female,
                color: gender == 'Male' ? Colors.blue : Colors.pink,
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }
}
