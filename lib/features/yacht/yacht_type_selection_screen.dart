import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/yacht_service.dart';
import '../../config/theme/app_theme.dart';
import '../../shared/components/skeleton/skeleton_card.dart';
import '../../shared/widgets/network_error_widget.dart';
import '../../core/error/network_error_handler.dart';
import 'yacht_results_screen.dart';

class YachtTypeSelectionScreen extends StatefulWidget {
  final bool showBackButton;

  const YachtTypeSelectionScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<YachtTypeSelectionScreen> createState() =>
      _YachtTypeSelectionScreenState();
}

class _YachtTypeSelectionScreenState extends State<YachtTypeSelectionScreen> {
  final YachtService _yachtService = YachtService();
  List<YachtType> _yachtTypes = [];
  bool _isLoading = true;
  NetworkErrorResult? _error;

  @override
  void initState() {
    super.initState();
    _loadYachtTypes();
  }

  Future<void> _loadYachtTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final yachtTypes = await _yachtService.getYachtTypes();
      setState(() {
        _yachtTypes = yachtTypes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is NetworkException
            ? e.errorResult
            : NetworkErrorResult.fromException(e);
        _isLoading = false;
      });
    }
  }

  void _navigateToYachtResults(YachtType yachtType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YachtResultsScreen(
          yachtType: yachtType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Select Yacht Type',
          style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppTheme.textPrimaryColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_yachtTypes.isEmpty) {
      return _buildEmptyState();
    }

    return _buildYachtTypesGrid();
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Yacht Types',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return const SkeletonCard(
                height: 200,
                borderRadius: 16,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: QuickNetworkErrorWidget(
        error: _error?.message ?? 'Failed to load yacht types',
        onRetry: _loadYachtTypes,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_boat,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Yacht Types Available',
            style: AppTheme.heading3.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later or contact support.',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadYachtTypes,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildYachtTypesGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Yacht Types',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _yachtTypes.length,
            itemBuilder: (context, index) {
              final yachtType = _yachtTypes[index];
              return _buildYachtTypeCard(yachtType);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYachtTypeCard(YachtType yachtType) {
    return GestureDetector(
      onTap: () => _navigateToYachtResults(yachtType),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yacht Type Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: yachtType.placeholderImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: yachtType.placeholderImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppTheme.inputFillColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.inputFillColor,
                          child: Icon(
                            _getYachtIcon(yachtType.type),
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.inputFillColor,
                        child: Icon(
                          _getYachtIcon(yachtType.type),
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                      ),
              ),
            ),
            // Yacht Type Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yachtType.type.toUpperCase(),
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryColor,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Available Yachts',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'View Yachts',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getYachtIcon(String yachtType) {
    switch (yachtType.toLowerCase()) {
      case 'yachts':
        return Icons.directions_boat;
      case 'dhows':
        return Icons.sailing;
      case 'speedboat':
        return Icons.directions_boat;
      case 'catamaran':
        return Icons.directions_boat;
      default:
        return Icons.directions_boat;
    }
  }
}
