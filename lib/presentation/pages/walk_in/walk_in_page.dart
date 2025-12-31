import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app_dependencies.dart';
import '../../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/walk_in_card.dart';
import 'walk_in_edit_detail_page.dart';

class WalkInPage extends ConsumerStatefulWidget {
  const WalkInPage({super.key});

  @override
  ConsumerState<WalkInPage> createState() => _WalkInPageState();
}

class _WalkInPageState extends ConsumerState<WalkInPage> {
  final ScrollController _scrollController = ScrollController();

  // Mock walk-in data
  final List<Map<String, dynamic>> _mockWalkIns = [
    {
      'id': '1',
      'customerName': 'John Smith',
      'customerPhone': '(555) 111-2222',
      'services': [
        {
          'name': 'Classic Manicure',
          'duration': 45,
          'price': 35.0,
          'categoryName': 'Manicures'
        },
      ],
      'checkInTime': DateTime.now().subtract(const Duration(minutes: 15)),
      'status': 'waiting',
      'assignedStation': null,
      'notes': '',
    },
    {
      'id': '2',
      'customerName': 'Emily Davis',
      'customerPhone': '(555) 333-4444',
      'services': [
        {
          'name': 'Gel Pedicure',
          'duration': 60,
          'price': 50.0,
          'categoryName': 'Pedicures'
        },
        {'name': 'Nail Art', 'duration': 30, 'price': 25.0, 'categoryName': 'Manicures'},
      ],
      'checkInTime': DateTime.now().subtract(const Duration(minutes: 30)),
      'status': 'inService',
      'assignedStation': 'SPA2',
      'notes': 'Prefers natural colors',
    },
    {
      'id': '3',
      'customerName': 'Michael Brown',
      'customerPhone': '(555) 555-6666',
      'services': [
        {
          'name': 'Acrylic Full Set',
          'duration': 90,
          'price': 60.0,
          'categoryName': 'ACRYLICS'
        },
        {'name': 'Nail Art', 'duration': 30, 'price': 25.0, 'categoryName': 'Manicures'},
        {
          'name': 'Paraffin Treatment',
          'duration': 20,
          'price': 15.0,
          'categoryName': 'WAC'
        },
      ],
      'checkInTime': DateTime.now().subtract(const Duration(minutes: 5)),
      'status': 'waiting',
      'assignedStation': null,
      'notes': 'First time customer',
    },
    {
      'id': '4',
      'customerName': 'Sarah Johnson',
      'customerPhone': '(555) 777-8888',
      'services': [
        {'name': 'Spa Pedicure', 'duration': 75, 'price': 55.0, 'categoryName': 'Pedicures'},
      ],
      'checkInTime': DateTime.now().subtract(const Duration(minutes: 45)),
      'status': 'inService',
      'assignedStation': 'SPA1',
      'notes': '',
    },
  ];

  List<Map<String, dynamic>> _getFilteredWalkIns() {
    return _mockWalkIns
      ..sort((a, b) {
        // Sort by status (waiting first) then by check-in time
        if (a['status'] == 'waiting' && b['status'] != 'waiting') return -1;
        if (a['status'] != 'waiting' && b['status'] == 'waiting') return 1;
        return (b['checkInTime'] as DateTime)
            .compareTo(a['checkInTime'] as DateTime);
      });
  }

  void _handleStationAssign(int index, String? station) {
    setState(() {
      _mockWalkIns[index]['assignedStation'] = station;
      if (station != null) {
        _mockWalkIns[index]['status'] = 'inService';
      }
    });
  }

  Future<void> _navigateToEditDetail(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalkInEditDetailPage(
          walkInData: _mockWalkIns[index],
          onSave: (updatedData) {
            setState(() {
              _mockWalkIns[index] = updatedData;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walkIns = _getFilteredWalkIns();
    final walkInCount = walkIns.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(walkInCount),
          Expanded(
            child: walkIns.isEmpty
                ? _buildEmptyState()
                : _buildWalkInsList(walkIns),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int walkInCount) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingS,
        MediaQuery.of(context).padding.top + AppDimensions.spacingXs,
        AppDimensions.spacingS,
        AppDimensions.spacingS,
      ),
      child: Column(
        children: [
          // Top row with icons and user name
          SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.push(AppRoutes.notifications);
                  },
                ),
                Expanded(
                  child: Text(
                    'Walk-Ins',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app,
                      color: Colors.white, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
          ),
          // Walk-ins count row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Walk-Ins Today',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$walkInCount',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkInsList(List<Map<String, dynamic>> walkIns) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingS,
        AppDimensions.spacingM,
        100, // Extra bottom padding to account for bottom nav bar
      ),
      itemCount: walkIns.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        return WalkInCard(
          walkIn: walkIns[index],
          onTap: () {
            _navigateToEditDetail(index);
          },
          onStationAssign: (station) {
            _handleStationAssign(index, station);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative illustration
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 60,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  Positioned(
                    right: 35,
                    top: 30,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    bottom: 35,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              'No Walk-Ins',
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Ready to serve customers!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            // Pro tip card
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro Tip',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Assign stations to walk-ins to track their service status',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
