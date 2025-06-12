import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_dorm_form.dart';
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

  Map<String, dynamic> formData = {
    'dormitory_name': '',
    'dormitory_type': '',
    'gender_preference': '',
    'description': '',
    'address_line': '',
    'city': '',
    'state': '',
    'distance_to_utm_kl_(km)': '',
    'nearby_landmark': '',
    'furnishing': '',
    'wifi': false,
    'air_conditioning': false,
    'washing_machine_available': false,
    'cooking_allowed': false,
    'kitchen_type': '',
    'security_features': [],
    'other_amenities': '',
    'total_number_of_rooms': '',
    'available_rooms': '',
    'occupied_rooms': '',
    'room_types_available': [],
    'please_specify_other_room_types': '',
    'monthly_rate_(rm)': '',
    'deposit_required_(rm)': '',
    'utilities_included_in_rent': false,
    'additional_charges': '',
    'contract_flexibility': '',
  };

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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isEditing = false);

      try {
        await FirebaseFirestore.instance.collection('dorms').add({
          ...formData,
          'createdAt': FieldValue.serverTimestamp(),
          'landlordId': FirebaseAuth.instance.currentUser?.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dormitory added successfully!'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/landlord_dashboard',
            (route) => false,
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add dormitory: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isEditing = true);
      }
    }
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
            _buildReviewItem('Dormitory Name', formData['dormitory_name']),
            _buildReviewItem('Type', formData['dormitory_type']),
            _buildReviewItem('For', formData['gender_preference']),
            _buildReviewItem('Address', formData['address_line']),
            _buildReviewItem('City/State', '${formData['city']}, ${formData['state']}'),
            _buildReviewItem('Distance to UTM', '${formData['distance_to_utm_kl_(km)']} km'),
            _buildReviewItem('Monthly Rate', 'RM ${formData['monthly_rate_(rm)']}'),
            _buildReviewItem('Deposit', 'RM ${formData['deposit_required_(rm)']}'),
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
              if (_isEditing)
                AddDormForm(
                  formKey: _formKey,
                  formData: formData,
                  selectedImages: _selectedImages,
                  securityOptions: _securityOptions,
                  roomTypes: _roomTypes,
                  currentSection: _currentSection,
                  onSectionChange: (section) => setState(() => _currentSection = section),
                  isEditing: _isEditing,
                  setEditing: (editing) => setState(() => _isEditing = editing),
                )
              else
                _buildReviewCard(),
            ],
          ),
        ),
      ),
    );
  }
}