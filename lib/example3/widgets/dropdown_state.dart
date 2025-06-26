import 'package:flutter/material.dart';

class DropdownState extends StatelessWidget {
  final String selectedState;
  final ValueChanged<String?> onChanged;

  const DropdownState({
    Key? key,
    required this.selectedState,
    required this.onChanged,
  }) : super(key: key);

  static const List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedState.isEmpty ? null : selectedState,
      decoration: InputDecoration(
        labelText: 'State *',
        hintText: 'Select your state',
        prefixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      isExpanded: true,
      items: indianStates.map((String state) {
        return DropdownMenuItem<String>(
          value: state,
          child: Text(
            state,
            style: TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a state';
        }
        return null;
      },
      dropdownColor: Colors.white,
      style: TextStyle(
        color: Colors.grey[800],
        fontSize: 14,
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: Colors.grey[600],
      ),
      menuMaxHeight: 300, // Limit dropdown height for better UX
    );
  }
}