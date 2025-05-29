import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddDormPage extends StatefulWidget {
  const AddDormPage({super.key});

  @override
  State<AddDormPage> createState() => _AddDormPageState();
}

class _AddDormPageState extends State<AddDormPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentSection = 1;
  bool _isEditing = true;
  List<XFile> _selectedImages = [];
  final List<String> _securityOptions = ['CCTV', '24/7 Guards', 'Keycard Access'];
  final List<String> _roomTypes = ['Single', 'Twin', 'Double', 'Others'];

  // Form data
  Map<String, dynamic> formData = {
    'dormName': '',
    'dormType': '',
    'genderType': '',
    'description': '',
    'address': '',
    'city': '',
    'state': '',
    'distanceToUTM': '',
    'landmark': '',
    'furnished': '',
    'wifi': false,
    'aircon': false,
    'washingMachine': false,
    'cookingAllowed': false,
    'kitchenType': '',
    'security': [],
    'amenities': '',
    'totalRooms': '',
    'availableRooms': '',
    'occupiedRooms': '',
    'roomTypes': [],
    'monthlyRate': '',
    'deposit': '',
    'utilitiesIncluded': false,
    'additionalCharges': '',
    'contractFlexibility': '',
  };

  // Malaysian states and cities
  final List<String> malaysianStates = [
    'Johor', 'Kedah', 'Kelantan', 'Malacca', 'Negeri Sembilan',
    'Pahang', 'Penang', 'Perak', 'Perlis', 'Sabah', 
    'Sarawak', 'Selangor', 'Terengganu', 'Kuala Lumpur'
  ];
  
  final List<String> malaysianCities = [
    'Kuala Lumpur', 'Petaling Jaya', 'Shah Alam', 'Subang Jaya',
    'Johor Bahru', 'Penang', 'Ipoh', 'Malacca City', 'Kuching'
  ];

    @override
  void initState() {
    super.initState();
    // Load any previously saved data here if needed
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dormitory added successfully!'),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate to landlord dashboard after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/landlord_dashboard', 
          (route) => false
        );
      });
    }
  }


  Widget _buildSectionIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentSection == index + 1 
                ? const Color(0xFF800000)
                : Colors.grey[300],
              border: Border.all(
                color: _currentSection == index + 1 
                  ? const Color(0xFF800000).withOpacity(0.5)
                  : Colors.grey,
                width: 1,
              ),
            ),
          );
        }),
      ),
    );
  }

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

  Widget _buildTextInput(String label, {bool isRequired = true, String? hint}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label + (isRequired ? '*' : ''),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF800000), width: 2),
        ),
      ),
      validator: isRequired 
          ? (value) => value!.isEmpty ? 'This field is required' : null
          : null,
      onSaved: (value) => formData[label.toLowerCase().replaceAll(' ', '_')] = value,
    );
  }

  Widget _buildDropdown(String label, List<String> items, {bool isRequired = true}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label + (isRequired ? '*' : ''),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: isRequired 
          ? (value) => value == null ? 'Please select an option' : null
          : null,
      onChanged: (value) => formData[label.toLowerCase().replaceAll(' ', '_')] = value,
    );
  }

  Widget _buildSwitch(String label, String fieldName) {
    return SwitchListTile(
      title: Text(label),
      value: formData[fieldName] ?? false,
      activeColor: const Color(0xFF800000),
      inactiveTrackColor: Colors.grey[300],
      onChanged: (value) => setState(() => formData[fieldName] = value),
    );
  }

  Widget _buildMultiSelectChips(String label, List<String> options, String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: formData[fieldName]?.contains(option) ?? false,
              selectedColor: const Color(0xFF800000).withOpacity(0.2),
              checkmarkColor: const Color(0xFF800000),
              labelStyle: TextStyle(
                color: formData[fieldName]?.contains(option) ?? false
                    ? const Color(0xFF800000)
                    : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    formData[fieldName].add(option);
                  } else {
                    formData[fieldName].remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Dormitory Photos', 
          'Upload clear photos of your dormitory (minimum 3 photos)'
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.photo_library, color: Colors.white),
          label: const Text('Upload Photos', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800000),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          ),
          onPressed: _pickImages,
        ),
        const SizedBox(height: 20),
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildSection1() {
    return Column(
      children: [
        _buildSectionHeader(
          'Dormitory Information', 
          'Basic details about your dormitory'
        ),
        _buildTextInput('Dormitory Name'),
        const SizedBox(height: 16),
        _buildDropdown('Dormitory Type', ['Shared', 'Studio']),
        const SizedBox(height: 16),
        _buildDropdown('Gender Preference', ['Men', 'Women', 'Any']),
        const SizedBox(height: 16),
        _buildTextInput(
          'Description', 
          isRequired: false,
          hint: 'Tell potential tenants about your dormitory...'
        ),
      ],
    );
  }

  Widget _buildSection2() {
  return Column(
    children: [
      _buildSectionHeader(
        'Location Details', 
        'Where is your dormitory located?'
      ),
      _buildTextInput('Address Line'),
      const SizedBox(height: 16),
      _buildTextInput('City'),
      const SizedBox(height: 16),
      _buildTextInput('State'),
      const SizedBox(height: 16),
      _buildTextInput('Distance to UTM KL (km)', hint: 'e.g., 2.5'),
      const SizedBox(height: 16),
      _buildTextInput(
        'Nearby Landmark', 
        isRequired: false,
        hint: 'e.g., "Next to Petronas, 5 min walk from LRT"'
      ),
    ],
  );
}


  Widget _buildSection3() {
    return _buildImageUploadSection();
  }

  Widget _buildSection4() {
    return Column(
      children: [
        _buildSectionHeader(
          'Facilities & Amenities', 
          'What does your dormitory offer?'
        ),
        _buildDropdown('Furnishing', ['Fully', 'Semi', 'Unfurnished'], isRequired: false),
        const SizedBox(height: 8),
        _buildSwitch('WiFi included', 'wifi'),
        _buildSwitch('Air conditioning', 'aircon'),
        _buildSwitch('Washing machine available', 'washingMachine'),
        _buildSwitch('Cooking allowed', 'cookingAllowed'),
        const SizedBox(height: 8),
        _buildDropdown('Kitchen Type', ['Private', 'Shared', 'None'], isRequired: false),
        const SizedBox(height: 16),
        _buildMultiSelectChips('Security Features', _securityOptions, 'security'),
        const SizedBox(height: 16),
        _buildTextInput(
          'Other Amenities', 
          isRequired: false,
          hint: 'e.g., Gym, Mini Market, Swimming Pool'
        ),
      ],
    );
  }

  Widget _buildSection5() {
    return Column(
      children: [
        _buildSectionHeader(
          'Availability', 
          'Current room availability'
        ),
        _buildTextInput('Total Number of Rooms', hint: 'e.g., 10'),
        const SizedBox(height: 16),
        _buildTextInput('Available Rooms', hint: 'e.g., 3'),
        const SizedBox(height: 16),
        _buildTextInput('Occupied Rooms', hint: 'e.g., 7'),
        const SizedBox(height: 16),
        _buildMultiSelectChips('Room Types Available', _roomTypes, 'roomTypes'),
        if (formData['roomTypes']?.contains('Others') ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildTextInput(
              'Please specify other room types',
              isRequired: false
            ),
          ),
      ],
    );
  }

  Widget _buildSection6() {
    return Column(
      children: [
        _buildSectionHeader(
          'Pricing & Terms', 
          'Set your rental terms and conditions'
        ),
        _buildTextInput('Monthly Rate (RM)', hint: 'e.g., 500'),
        const SizedBox(height: 16),
        _buildTextInput('Deposit Required (RM)', hint: 'e.g., 1000'),
        const SizedBox(height: 8),
        _buildSwitch('Utilities included in rent', 'utilitiesIncluded'),
        const SizedBox(height: 16),
        _buildTextInput(
          'Additional Charges', 
          isRequired: false,
          hint: 'e.g., "RM 50/month for air-con use"'
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          'Contract Flexibility', 
          ['Monthly', '3 Months', '6 Months', '1 Year']
        ),
      ],
    );
  }

  Widget _buildReviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Dormitory Listing Preview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            _buildReviewItem('Dormitory Name', formData['dormName']),
            _buildReviewItem('Type', formData['dormType']),
            _buildReviewItem('For', formData['genderType']),
            _buildReviewItem('Address', formData['address']),
            _buildReviewItem('City/State', '${formData['city']}, ${formData['state']}'),
            _buildReviewItem('Distance to UTM', '${formData['distanceToUTM']} km'),
            _buildReviewItem('Monthly Rate', 'RM ${formData['monthlyRate']}'),
            _buildReviewItem('Deposit', 'RM ${formData['deposit']}'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submitForm,
                child: const Text(
                  'Submit Listing',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: TextStyle(
                color: value == null ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentSection > 1)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Save current section data before navigating back
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
                setState(() => _currentSection--);
              },
              child: const Text('Back'),
            )
          else
            const SizedBox(width: 100),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800000),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save(); // Save data before proceeding
                if (_currentSection == 6) {
                  // On final section, show review instead of proceeding
                  setState(() => _isEditing = false);
                } else {
                  setState(() => _currentSection++);
                }
              }
            },
            child: Text(_currentSection == 6 ? 'Finish' : 'Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Add New Dormitory' : 'Review Listing',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800000),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() {
                _isEditing = true;
                _currentSection = 1;
              }),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              if (_isEditing) ...[
                _buildSectionIndicator(),
                if (_currentSection == 1) _buildSection1(),
                if (_currentSection == 2) _buildSection2(),
                if (_currentSection == 3) _buildSection3(),
                if (_currentSection == 4) _buildSection4(),
                if (_currentSection == 5) _buildSection5(),
                if (_currentSection == 6) _buildSection6(),
                _buildNavigationButtons(),
              ] else
                _buildReviewCard(),
            ],
          ),
        ),
      ),
    );
  }
}