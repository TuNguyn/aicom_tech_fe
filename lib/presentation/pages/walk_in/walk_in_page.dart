import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app_dependencies.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_strings.dart';
import '../../widgets/walk_in_line_card.dart';
import '../../widgets/logout_dialog.dart';
import '../../providers/walk_ins_provider.dart';

class WalkInPage extends ConsumerStatefulWidget {
  const WalkInPage({super.key});

  @override
  ConsumerState<WalkInPage> createState() => _WalkInPageState();
}

class _WalkInPageState extends ConsumerState<WalkInPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walkInsNotifierProvider.notifier).loadWalkIns();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final walkInsState = ref.watch(walkInsNotifierProvider);
    final lines = walkInsState.sortedServiceLines;

    // Logic: Ticket được coi là Pending nếu có bất kỳ line nào đang WAITING hoặc SERVING
    final pendingCount = walkInsState.activeTicketsCount;
    final isLoading = walkInsState.loadingStatus.isLoading;

    ref.listen<String>(authNotifierProvider.select((state) => state.user.id), (
      previous,
      next,
    ) {
      if (previous != null &&
          previous.isNotEmpty &&
          previous != next &&
          next.isNotEmpty) {
        _isInitialLoad = true;
        ref.read(walkInsNotifierProvider.notifier).loadWalkIns();
      }
    });

    ref.listen<AsyncValue<void>>(
      walkInsNotifierProvider.select((state) => state.loadingStatus),
      (previous, next) {
        next.whenOrNull(
          data: (_) {
            if (_isInitialLoad) {
              setState(() {
                _isInitialLoad = false;
              });
            }
          },
          error: (error, stack) {
            if (_isInitialLoad) {
              setState(() {
                _isInitialLoad = false;
              });
            }
            // Skip toast when offline - banner already shows connectivity status
            if (ref.read(connectivityNotifierProvider).isOffline) return;
            ToastUtils.showError(error.toString());
          },
        );
      },
    );

    ref.listen<bool>(
      socketNotifierProvider.select((state) => state.hasNewAssignedTicket),
      (previous, next) {
        if (next == true) {
          ref.read(walkInsNotifierProvider.notifier).refreshWalkIns();
          ref.read(socketNotifierProvider.notifier).clearAssignedTicketFlag();
        }
      },
    );

    return Container(
      decoration: BoxDecoration(gradient: AppColors.mainBackgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeader(pendingCount, lines.length),
            Expanded(
              child: (isLoading && _isInitialLoad && lines.isEmpty)
                  ? _buildLoadingState()
                  : lines.isEmpty
                  ? _buildEmptyState()
                  : _buildLinesList(lines, isLoading),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int ticketCount, int serviceLineCount) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingXs,
        MediaQuery.of(context).padding.top,
        AppDimensions.spacingXs,
        4,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    context.push(AppRoutes.notifications);
                  },
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.walkInsTitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$serviceLineCount',
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
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white, size: 24),
                  onPressed: () {
                    LogoutDialog.show(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesList(List<ServiceLineDisplay> lines, bool isLoading) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(walkInsNotifierProvider.notifier).refreshWalkIns();
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingM,
          AppDimensions.spacingS,
          AppDimensions.spacingM,
          100,
        ),
        itemCount: lines.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppDimensions.spacingS),
        itemBuilder: (context, index) {
          final line = lines[index];
          return WalkInLineCard(
            key: ValueKey(line.serviceLine.id),
            customerName: line.customerName,
            serviceLine: line.serviceLine,
            createdAt: line.createdAt,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(walkInsNotifierProvider.notifier).refreshWalkIns();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  Text(
                    AppStrings.walkInsEmptyTitle,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    AppStrings.walkInsEmptyMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadius,
                      ),
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
                                AppStrings.walkInsProTipTitle,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppStrings.walkInsProTipMessage,
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
          ),
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
