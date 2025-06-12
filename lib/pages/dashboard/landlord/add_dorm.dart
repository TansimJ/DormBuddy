import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_dorm_form.dart';
import 'landlord_bottombar.dart';

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

  void _onSectionChange(int section) {
    setState(() {
      _currentSection = section;
    });
  }

  void _setEditing(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }

  int _bottomBarIndex = 1;
  void _onBottomBarTap(int idx) {
    setState(() {
      _bottomBarIndex = idx;
    });
    // Navigation for bottom bar
    switch (idx) {
      case 0:
        Navigator.pushNamed(context, '/landlord_dashboard');
        break;
      case 1:
        // Already on add dorm
        break;
      case 2:
        Navigator.pushNamed(context, '/landlord_chat');
        break;
      case 3:
        Navigator.pushNamed(context, '/landlord_profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Dormitory',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800000),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AddDormForm(
            formKey: _formKey,
            formData: formData,
            selectedImages: _selectedImages,
            securityOptions: _securityOptions,
            roomTypes: _roomTypes,
            currentSection: _currentSection,
            onSectionChange: _onSectionChange,
            isEditing: _isEditing,
            setEditing: _setEditing,
            onSave: _submitForm, // This will be called from the review section button!
          ),
        ),
      ),
      bottomNavigationBar: LandlordBottomBar(
        currentIndex: _bottomBarIndex,
        onTap: _onBottomBarTap,
      ),
    );
  }
}