import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'landlord_bottombar.dart';

class AddDormForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;
  final List<XFile> selectedImages;
  final List<String> securityOptions;
  final List<String> roomTypes;
  final int currentSection;
  final Function(int) onSectionChange;
  final bool isEditing;
  final Function(bool) setEditing;
  final VoidCallback? onSave;

  const AddDormForm({
    super.key,
    required this.formKey,
    required this.formData,
    required this.selectedImages,
    required this.securityOptions,
    required this.roomTypes,
    required this.currentSection,
    required this.onSectionChange,
    required this.isEditing,
    required this.setEditing,
    this.onSave,
  });

  @override
  State<AddDormForm> createState() => _AddDormFormState();
}

class _AddDormFormState extends State<AddDormForm> {
  // Section headers
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF800000),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
        const Divider(color: Color(0xFF800000), thickness: 1),
        const SizedBox(height: 16),
      ],
    );
  }

  // Text input
  Widget _buildTextInput(String label, String fieldKey, {bool isRequired = true, String? hint}) {
    return TextFormField(
      initialValue: widget.formData[fieldKey] ?? '',
      decoration: InputDecoration(
        labelText: label + (isRequired ? '*' : ''),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? 'This field is required' : null
          : null,
      onSaved: (value) => widget.formData[fieldKey] = value,
      onChanged: (value) => widget.formData[fieldKey] = value,
    );
  }

  // Dropdown
  Widget _buildDropdown(String label, String fieldKey, List<String> items, {bool isRequired = true}) {
    return DropdownButtonFormField<String>(
      value: widget.formData[fieldKey]?.isNotEmpty == true ? widget.formData[fieldKey] : null,
      decoration: InputDecoration(
        labelText: label + (isRequired ? '*' : ''),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? 'Please select an option' : null
          : null,
      onChanged: (value) {
        setState(() {
          widget.formData[fieldKey] = value;
        });
      },
      onSaved: (value) => widget.formData[fieldKey] = value,
    );
  }

  // Switch
  Widget _buildSwitch(String label, String fieldKey) {
    return SwitchListTile(
      title: Text(label),
      value: widget.formData[fieldKey] ?? false,
      onChanged: (value) {
        setState(() {
          widget.formData[fieldKey] = value;
        });
      },
      activeColor: const Color(0xFF800000),
    );
  }

  // Multi-select chips
  Widget _buildMultiSelectChips(String label, List<String> options, String fieldKey) {
    List<String> selected = List<String>.from(widget.formData[fieldKey] ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              selectedColor: const Color(0xFF800000),
              checkmarkColor: Colors.white,
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                  widget.formData[fieldKey] = selected;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Image upload section
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Images', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == widget.selectedImages.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(widget.selectedImages[index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.selectedImages.removeAt(index);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => widget.selectedImages.addAll(images));
    }
  }

  // Section indicator
Widget _buildSectionIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          return Container(
            width: 28,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: widget.currentSection == index + 1
                  ? const Color(0xFF800000)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
  // Navigation buttons
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.currentSection > 1)
          ElevatedButton(
            onPressed: () => widget.onSectionChange(widget.currentSection - 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              foregroundColor: Colors.white,
            ),
            child: const Text('Back'),
          ),
        if (widget.currentSection < 6)
          ElevatedButton(
            onPressed: () => widget.onSectionChange(widget.currentSection + 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800000),
              foregroundColor: Colors.white,
            ),
            child: const Text('Next'),
          ),
        if (widget.currentSection == 6)
          ElevatedButton(
            onPressed: () => widget.onSectionChange(7),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800000),
              foregroundColor: Colors.white,
            ),
            child: const Text('Review Listing'),
          ),
      ],
    );
  }

  // Section 1: Basic Info
  Widget _buildSection1() {
    return Column(
      children: [
        _buildSectionHeader('Basic Information', 'Tell us about your dormitory'),
        _buildTextInput('Dormitory Name', 'dormitory_name'),
        const SizedBox(height: 16),
        _buildDropdown('Dormitory Type', 'dormitory_type', ['Shared', 'Studio']),
        const SizedBox(height: 16),
        _buildDropdown('Gender Preference', 'gender_preference', ['Men', 'Women', 'Any']),
        const SizedBox(height: 16),
        _buildTextInput('Description', 'description', isRequired: false, hint: 'Tell potential tenants about your dormitory...'),
      ],
    );
  }

  // Section 2: Location
  Widget _buildSection2() {
    return Column(
      children: [
        _buildSectionHeader('Location Details', 'Where is your dormitory located?'),
        _buildTextInput('Address Line', 'address_line'),
        const SizedBox(height: 16),
        _buildTextInput('City', 'city'),
        const SizedBox(height: 16),
        _buildTextInput('State', 'state'),
        const SizedBox(height: 16),
        _buildTextInput('Distance to UTM KL (km)', 'distance_to_utm_kl_(km)', hint: 'e.g., 2.5'),
        const SizedBox(height: 16),
        _buildTextInput('Nearby Landmark', 'nearby_landmark', isRequired: false, hint: 'e.g., "Next to Petronas, 5 min walk from LRT"'),
      ],
    );
  }

  // Section 3: Images
  Widget _buildSection3() {
    return Column(
      children: [
        _buildSectionHeader('Photos', 'Upload clear photos of your dormitory'),
        _buildImageUploadSection(),
      ],
    );
  }

  // Section 4: Facilities & Amenities
  Widget _buildSection4() {
    return Column(
      children: [
        _buildSectionHeader('Facilities & Amenities', 'What does your dormitory offer?'),
        _buildDropdown('Furnishing', 'furnishing', ['Fully', 'Semi', 'Unfurnished'], isRequired: false),
        const SizedBox(height: 8),
        _buildSwitch('WiFi included', 'wifi'),
        _buildSwitch('Air conditioning', 'air_conditioning'),
        _buildSwitch('Washing machine available', 'washing_machine_available'),
        _buildSwitch('Cooking allowed', 'cooking_allowed'),
        const SizedBox(height: 8),
        _buildDropdown('Kitchen Type', 'kitchen_type', ['Private', 'Shared', 'None'], isRequired: false),
        const SizedBox(height: 16),
        _buildMultiSelectChips('Security Features', widget.securityOptions, 'security_features'),
        const SizedBox(height: 16),
        _buildTextInput('Other Amenities', 'other_amenities', isRequired: false, hint: 'e.g., Gym, Mini Market, Swimming Pool'),
      ],
    );
  }

  // Section 5: Availability
  Widget _buildSection5() {
    return Column(
      children: [
        _buildSectionHeader('Availability', 'Current room availability'),
        _buildTextInput('Total Number of Rooms', 'total_number_of_rooms', hint: 'e.g., 10'),
        const SizedBox(height: 16),
        _buildTextInput('Available Rooms', 'available_rooms', hint: 'e.g., 3'),
        const SizedBox(height: 16),
        _buildTextInput('Occupied Rooms', 'occupied_rooms', hint: 'e.g., 7'),
        const SizedBox(height: 16),
        _buildMultiSelectChips('Room Types Available', widget.roomTypes, 'room_types_available'),
        if (widget.formData['room_types_available']?.contains('Others') ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildTextInput('Please specify other room types', 'please_specify_other_room_types', isRequired: false),
          ),
      ],
    );
  }

  // Section 6: Pricing & Terms
  Widget _buildSection6() {
    return Column(
      children: [
        _buildSectionHeader('Pricing & Terms', 'Set your rental terms and conditions'),
        _buildTextInput('Monthly Rate (RM)', 'monthly_rate_(rm)', hint: 'e.g., 500'),
        const SizedBox(height: 16),
        _buildTextInput('Deposit Required (RM)', 'deposit_required_(rm)', hint: 'e.g., 1000'),
        const SizedBox(height: 8),
        _buildSwitch('Utilities included in rent', 'utilities_included_in_rent'),
        const SizedBox(height: 16),
        _buildTextInput('Additional Charges', 'additional_charges', isRequired: false, hint: 'e.g., "RM 50/month for air-con use"'),
        const SizedBox(height: 16),
        _buildDropdown('Contract Flexibility', 'contract_flexibility', ['Monthly', '3 Months', '6 Months', '1 Year']),
      ],
    );
  }

Widget _buildReviewSection() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.fact_check, size: 30, color: Color(0xFF800000)),
              SizedBox(width: 10),
              Text(
                'Review Your Listing',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[300], thickness: 1, height: 1),
          const SizedBox(height: 12),
          ...widget.formData.entries.where((e) =>
            e.value != null && e.value.toString().isNotEmpty
          ).map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  child: Text(
                    _prettifyField(entry.key),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF800000),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildReviewValue(entry.value),
                ),
              ],
            ),
          )),
          if (widget.selectedImages.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Images:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF800000),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF800000), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(widget.selectedImages[index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Please confirm that all information is correct before posting.',
              style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic, fontSize: 15),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: widget.onSave,
              icon: const Icon(Icons.add),
              label: const Text('Add Dorm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

  // Helper: prettify field names
  String _prettifyField(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'\b\w'), (m) => m.group(0)!.toUpperCase())
        .replaceAll('Rm', 'RM')
        .replaceAll('Id', 'ID');
  }

  // Helper: pretty display for values (lists, bools, etc)
  Widget _buildReviewValue(dynamic value) {
    if (value is List) {
      if (value.isEmpty) return const Text('-');
      return Text(value.join(', '), style: const TextStyle(fontSize: 15));
    }
    if (value is bool) {
      return Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value ? Colors.green : Colors.red,
        size: 20,
      );
    }
    return Text(value.toString(), style: const TextStyle(fontSize: 15));
  }

 @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionIndicator(),
        if (widget.currentSection == 1) _buildSection1(),
        if (widget.currentSection == 2) _buildSection2(),
        if (widget.currentSection == 3) _buildSection3(),
        if (widget.currentSection == 4) _buildSection4(),
        if (widget.currentSection == 5) _buildSection5(),
        if (widget.currentSection == 6) _buildSection6(),
        if (widget.currentSection == 7) _buildReviewSection(),
        const SizedBox(height: 24),
        if (widget.currentSection < 7) _buildNavigationButtons(),
      ],
    );
  }
}