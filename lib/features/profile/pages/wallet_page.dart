import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';
import '../../../shared/components/virtual_card.dart';

class WalletPage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const WalletPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Wallet',
          style: AppTheme.heading3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Virtual Card
            VirtualCard(
              firstName: profile['firstName']?.toString() ?? '',
              lastName: profile['lastName']?.toString() ?? '',
              points: profile['loyaltyPoints']?.toString() ?? '0',
              walletBalance: profile['walletBalance']?.toString() ?? '0.00',
              loyaltyTier: profile['loyaltyTier']?.toString() ?? 'bronze',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Wallet: \$${profile['walletBalance'] ?? 0.0} | Points: ${profile['loyaltyPoints'] ?? 0}',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Wallet Details
            Text(
              'Wallet Details',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: 16),

            _buildDetailCard(
              icon: LucideIcons.wallet,
              title: 'Wallet Balance',
              value: '\$${profile['walletBalance']?.toString() ?? '0.00'}',
              color: AppTheme.primaryColor,
            ),

            _buildDetailCard(
              icon: LucideIcons.award,
              title: 'Loyalty Points',
              value: '${profile['loyaltyPoints']?.toString() ?? '0'} pts',
              color: Colors.amber,
            ),

            _buildDetailCard(
              icon: LucideIcons.trophy,
              title: 'Loyalty Tier',
              value: (profile['loyaltyTier']?.toString() ?? 'bronze')
                  .toUpperCase(),
              color:
                  _getTierColor(profile['loyaltyTier']?.toString() ?? 'bronze'),
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: 16),

            _buildActionButton(
              context,
              icon: LucideIcons.plus,
              title: 'Add Funds',
              subtitle: 'Top up your wallet',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Add funds feature coming soon',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),

            _buildActionButton(
              context,
              icon: LucideIcons.history,
              title: 'Transaction History',
              subtitle: 'View your transactions',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Transaction history feature coming soon',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),

            _buildActionButton(
              context,
              icon: LucideIcons.gift,
              title: 'Redeem Points',
              subtitle: 'Use your loyalty points',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Redeem points feature coming soon',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondaryColor.withOpacity(0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      default:
        return const Color(0xFFCD7F32);
    }
  }
}
