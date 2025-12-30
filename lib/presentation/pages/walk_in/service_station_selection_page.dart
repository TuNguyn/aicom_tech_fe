import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ServiceStationSelectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialServices;
  final String? initialStation;
  final String initialTab;

  const ServiceStationSelectionPage({
    super.key,
    required this.initialServices,
    this.initialStation,
    this.initialTab = 'Service',
  });

  @override
  State<ServiceStationSelectionPage> createState() =>
      _ServiceStationSelectionPageState();
}

class _ServiceStationSelectionPageState
    extends State<ServiceStationSelectionPage> {
  late String _selectedTab;
  late String _selectedCategory;
  late List<Map<String, dynamic>> _selectedServices;
  late String? _selectedStation;

  // Mock services data by category
  final Map<String, List<Map<String, dynamic>>> _servicesByCategory = {
    'ACRYLICS': [
      {
        'name': 'Acrylic Full Set',
        'duration': 90,
        'price': 60.0,
        'categoryName': 'ACRYLICS'
      },
      {
        'name': 'Acrylic Fill',
        'duration': 60,
        'price': 40.0,
        'categoryName': 'ACRYLICS'
      },
      {
        'name': 'Acrylic Remove',
        'duration': 30,
        'price': 20.0,
        'categoryName': 'ACRYLICS'
      },
    ],
    'Manicures': [
      {'name': 'Design', 'duration': 30, 'price': 0.0, 'categoryName': 'Manicures'},
      {
        'name': 'Hand Treatment',
        'duration': 20,
        'price': 0.0,
        'categoryName': 'Manicures'
      },
      {
        'name': 'Luxe Manicure',
        'duration': 60,
        'price': 45.0,
        'categoryName': 'Manicures'
      },
      {
        'name': 'Mini Manicure',
        'duration': 30,
        'price': 35.0,
        'categoryName': 'Manicures'
      },
      {
        'name': 'No Chip Manicure',
        'duration': 45,
        'price': 25.0,
        'categoryName': 'Manicures'
      },
      {
        'name': 'Take Off + basic Manicure',
        'duration': 50,
        'price': 30.0,
        'categoryName': 'Manicures'
      },
      {
        'name': 'Classic Manicure',
        'duration': 45,
        'price': 35.0,
        'categoryName': 'Manicures'
      },
      {'name': 'Nail Art', 'duration': 30, 'price': 25.0, 'categoryName': 'Manicures'},
    ],
    'Pedicures': [
      {
        'name': 'Gel Pedicure',
        'duration': 60,
        'price': 50.0,
        'categoryName': 'Pedicures'
      },
      {
        'name': 'Spa Pedicure',
        'duration': 75,
        'price': 55.0,
        'categoryName': 'Pedicures'
      },
      {
        'name': 'Deluxe Pedicure',
        'duration': 90,
        'price': 65.0,
        'categoryName': 'Pedicures'
      },
      {
        'name': 'Basic Pedicure',
        'duration': 45,
        'price': 40.0,
        'categoryName': 'Pedicures'
      },
    ],
    'WAC': [
      {
        'name': 'Paraffin Treatment',
        'duration': 20,
        'price': 15.0,
        'categoryName': 'WAC'
      },
      {
        'name': 'Waxing - Eyebrows',
        'duration': 15,
        'price': 12.0,
        'categoryName': 'WAC'
      },
      {
        'name': 'Waxing - Upper Lip',
        'duration': 10,
        'price': 8.0,
        'categoryName': 'WAC'
      },
      {
        'name': 'Foot Massage',
        'duration': 30,
        'price': 25.0,
        'categoryName': 'WAC'
      },
    ],
  };

  final List<String> _stations = ['SPA1', 'SPA2', 'SPA3', 'SPA4', 'SPA5'];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _selectedCategory = 'Manicures';
    _selectedServices = List.from(widget.initialServices);
    _selectedStation = widget.initialStation;
  }

  List<Map<String, dynamic>> _getServicesForCategory(String category) {
    return _servicesByCategory[category] ?? [];
  }

  bool _isServiceSelected(Map<String, dynamic> service) {
    return _selectedServices.any((s) => s['name'] == service['name']);
  }

  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      if (_isServiceSelected(service)) {
        _selectedServices.removeWhere((s) => s['name'] == service['name']);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  void _selectStation(String station) {
    setState(() {
      _selectedStation = station;
    });
  }

  void _handleSave() {
    Navigator.pop(context, {
      'services': _selectedServices,
      'station': _selectedStation,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Detail'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _handleSave,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabSegmentedControl(),
          Expanded(
            child: _selectedTab == 'Service'
                ? _buildServiceTab()
                : _buildStationTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSegmentedControl() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabButton('Service'),
          _buildTabButton('Station'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            tab,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTab() {
    return Column(
      children: [
        _buildCategoryTabs(),
        Expanded(child: _buildServiceGrid()),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['ACRYLICS', 'Manicures', 'Pedicures', 'WAC'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceGrid() {
    final servicesForCategory = _getServicesForCategory(_selectedCategory);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: servicesForCategory.length,
      itemBuilder: (context, index) {
        final service = servicesForCategory[index];
        final isSelected = _isServiceSelected(service);

        return GestureDetector(
          onTap: () => _toggleService(service),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Service image placeholder
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Icon(
                          Icons.spa,
                          size: 40,
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                    // Service info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              '\$${service['price'].toStringAsFixed(0)}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Checkbox indicator
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStationTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _stations.length,
      itemBuilder: (context, index) {
        final station = _stations[index];
        final isSelected = _selectedStation == station;

        return GestureDetector(
          onTap: () => _selectStation(station),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.secondary : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Station icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary.withValues(alpha: 0.2)
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.table_restaurant, // Desk/table icon
                    size: 30,
                    color: isSelected ? AppColors.secondary : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // Station name
                Text(
                  station,
                  style: TextStyle(
                    color: isSelected ? AppColors.secondary : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
