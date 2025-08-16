import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class TokenInfoWidget extends StatefulWidget {
  const TokenInfoWidget({super.key});

  @override
  State<TokenInfoWidget> createState() => _TokenInfoWidgetState();
}

class _TokenInfoWidgetState extends State<TokenInfoWidget> {
  Map<String, dynamic>? _sessionStatus;
  final bool _isExpanded = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSessionStatus();
    // Refresh session status every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadSessionStatus();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadSessionStatus() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionStatus == null) {
      return const SizedBox.shrink();
    }

    final tokenInfo = _sessionStatus!['tokenInfo'] as Map<String, dynamic>?;
    final isAuthenticated = _sessionStatus!['isAuthenticated'] as bool;
    final hasValidToken = _sessionStatus!['hasValidToken'] as bool;

    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Row(
          children: [
            Icon(
              hasValidToken ? Icons.security : Icons.warning,
              color: hasValidToken ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Session Status',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        subtitle: Text(
          hasValidToken ? 'Session Active' : 'Session Expired',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: hasValidToken ? Colors.green : Colors.orange,
          ),
        ),
        children: [
          if (tokenInfo != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Status', hasValidToken ? 'Valid' : 'Expired'),
                  _buildInfoRow(
                      'Expires In', _formatDuration(tokenInfo['expiresIn'])),
                  _buildInfoRow(
                      'Expires At', _formatDateTime(tokenInfo['expiresAt'])),
                  _buildInfoRow('Token Type', tokenInfo['tokenType']),
                  if (tokenInfo['user'] != null) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    _buildInfoRow('User', tokenInfo['user']['name']),
                    _buildInfoRow('Email', tokenInfo['user']['email']),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            _loadSessionStatus(); // Refresh immediately
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    true
                                        ? 'Token refreshed successfully'
                                        : 'Failed to refresh token',
                                    style:
                                        GoogleFonts.inter(color: Colors.white),
                                  ),
                                  backgroundColor:
                                        true ? Colors.green : Colors.red,
                                ),
                              );
                              _loadSessionStatus(); // Refresh again after token refresh
                            }
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text(
                            'Refresh Token',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _loadSessionStatus,
                        icon: const Icon(Icons.refresh, size: 16),
                        tooltip: 'Refresh Status',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 0) return 'Expired';
    if (seconds < 60) return '$seconds seconds';
    if (seconds < 3600) return '${(seconds / 60).round()} minutes';
    return '${(seconds / 3600).round()} hours';
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
