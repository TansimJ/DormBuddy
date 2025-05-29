import 'package:flutter/material.dart';



//USELESS PAGE, IM KEEPING IT HERE FOR NOW THOUGH
class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedDormType;
  String? selectedGender;
  final Color primaryRed = const Color(0xFF800000);

  final double minPrice = 0;
  final double maxPrice = 3000;
  late RangeValues priceRange;

  @override
  void initState() {
    super.initState();
    priceRange = RangeValues(minPrice, maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: primaryRed,
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('Type of Dormitory', Icons.apartment),
            const SizedBox(height: 10),
            _buildOptionChip(
              'Shared',
              Icons.group,
              selectedDormType == 'Shared',
              () => setState(() => selectedDormType = 'Shared'),
            ),
            const SizedBox(height: 8),
            _buildOptionChip(
              'Studio',
              Icons.home,
              selectedDormType == 'Studio',
              () => setState(() => selectedDormType = 'Studio'),
        
            ),

            const Divider(height: 40, thickness: 1),

            _buildSectionHeader('Price Range', Icons.attach_money),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceField('Minimum', 'RM${priceRange.start.round()}'),
                      const SizedBox(width: 20),
                      _buildPriceField('Maximum', 'RM${priceRange.end.round()}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RangeSlider(
                    values: priceRange,
                    min: minPrice,
                    max: maxPrice,
                    divisions: 30,
                    activeColor: primaryRed,
                    inactiveColor: Colors.grey.shade300,
                    labels: RangeLabels(
                      'RM${priceRange.start.round()}',
                      'RM${priceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      final double start = values.start.clamp(minPrice, maxPrice);
                      final double end = values.end.clamp(minPrice, maxPrice);
                      if (end >= start) {
                        setState(() {
                          priceRange = RangeValues(start, end);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 1),

            _buildSectionHeader('', Icons.person),// removed the etxt fn
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _buildOptionChip(
                      'Woman',
                      Icons.female,
                      selectedGender == 'Woman',
                      () => setState(() => selectedGender = 'Woman'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _buildOptionChip(
                      'Man',
                      Icons.male,
                      selectedGender == 'Man',
                      () => setState(() => selectedGender = 'Man'),
                    ),
                  ),
                ),
                //attempting to add any
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _buildOptionChip(
                      'Any',
                      Icons.male,
                      selectedGender == ' Any',
                      () => setState(() => selectedGender = 'Any' ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedDormType = null;
                        priceRange = RangeValues(minPrice, maxPrice);
                        selectedGender = null;
                      });
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(color: primaryRed),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        'dormType': selectedDormType,
                        'minPrice': priceRange.start.round(),
                        'maxPrice': priceRange.end.round(),
                        'gender': selectedGender,
                      });
                    },
                    child: const Text(
                      'Apply',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: primaryRed),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryRed.withOpacity(0.2) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? primaryRed : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryRed : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryRed : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

//idk what ts is dawg, autopilot added ts
  Widget _buildPriceField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          width: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: Text(value)),
        ),
      ],
    );
  }
}
