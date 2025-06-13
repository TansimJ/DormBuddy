import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'add_dorm_form.dart'; // Make sure this exists and matches your form above

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};
  List<XFile> selectedImages = [];
  int currentSection = 1;
  bool isEditing = true;
  List<String> securityOptions = [
    "CCTV",
    "Access Card",
    "Guard",
    "Gated",
    "Security Patrol",
  ];
  List<String> roomTypes = ["Single", "Twin", "Triple", "Quad", "Others"];
  String? docId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? property =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (property != null) {
      docId = property['id'];
      formData = {...property}; // Make a copy
      selectedImages = [];
      // Optionally, you can handle loading image URLs into XFile, or handle image editing here
    }
  }

  void onSectionChange(int newSection) {
    setState(() {
      currentSection = newSection;
    });
  }

  void setEditing(bool editing) {
    setState(() {
      isEditing = editing;
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }
    _formKey.currentState!.save();

    // Note: Image upload to Firebase Storage is not included here.
    // If you want to handle image uploads, add the logic here and update the images field in Firestore.

    try {
      await FirebaseFirestore.instance
          .collection('dorms')
          .doc(docId)
          .update(formData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to dashboard
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent empty formData on first build
    if (formData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Property',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800000),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AddDormForm(
                formKey: _formKey,
                formData: formData,
                selectedImages: selectedImages,
                securityOptions: securityOptions,
                roomTypes: roomTypes,
                currentSection: currentSection,
                onSectionChange: onSectionChange,
                isEditing: isEditing,
                setEditing: setEditing,
              ),
              const SizedBox(height: 24),
              if (currentSection == 7) // Show only on review section
                ElevatedButton.icon(
                  onPressed: _saveForm,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
