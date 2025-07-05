import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mws/app/theme/app_theme.dart';

class WalletStatusCard extends StatefulWidget {
  final String? connectedAddress;
  final String? walletName;
  final String? networkName;
  final String? networkSymbol;
  final double? balance;
  final bool isConnected;
  final VoidCallback? onDisconnect;
  final VoidCallback? onSwitchNetwork;
  final bool isDesktop;

  const WalletStatusCard({
    Key? key,
    this.connectedAddress,
    this.walletName,
    this.networkName,
    this.networkSymbol,
    this.balance,
    this.isConnected = false,
    this.onDisconnect,
    this.onSwitchNetwork,
    this.isDesktop = false,
  }) : super(key: key);

  @override
  State<WalletStatusCard> createState() => _WalletStatusCardState();
}

class _WalletStatusCardState extends State<WalletStatusCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _copyAddress() {
    if (widget.connectedAddress != null) {
      Clipboard.setData(ClipboardData(text: widget.connectedAddress!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Address copied to clipboard'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  String _formatAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatBalance(double? balance) {
    if (balance == null) return '0.0000';
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    } else if (balance >= 1) {
      return balance.toStringAsFixed(4);
    } else if (balance > 0) {
      return balance.toStringAsFixed(6);
    } else {
      return '0.0000';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isConnected) {
      return _buildDisconnectedState();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryAccent.withOpacity(0.1),
            AppTheme.primaryAccent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main status display
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(widget.isDesktop ? 20.0 : 16.0),
              child: Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppTheme.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Wallet info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connected to ${widget.walletName ?? 'Wallet'}',
                          style: TextStyle(
                            fontSize: widget.isDesktop ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.whiteText,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _formatAddress(widget.connectedAddress ?? ''),
                              style: TextStyle(
                                fontSize: widget.isDesktop ? 14 : 12,
                                color: AppTheme.lightGrayText,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _copyAddress,
                              child: Icon(
                                Icons.copy,
                                size: 16,
                                color: AppTheme.primaryAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Balance display
                  if (widget.balance != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatBalance(widget.balance),
                          style: TextStyle(
                            fontSize: widget.isDesktop ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.whiteText,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          widget.networkSymbol ?? 'ETH',
                          style: TextStyle(
                            fontSize: widget.isDesktop ? 12 : 10,
                            color: AppTheme.lightGrayText,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(width: 12),

                  // Expand/collapse icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryAccent.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.isDesktop ? 20.0 : 16.0),
        child: Column(
          children: [
            // Network info
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppTheme.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightGrayText,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        widget.networkName ?? 'Unknown Network',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.whiteText,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onSwitchNetwork != null)
                  TextButton(
                    onPressed: widget.onSwitchNetwork,
                    child: Text(
                      'Switch',
                      style: TextStyle(
                        color: AppTheme.primaryAccent,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyAddress,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Address'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryAccent,
                      side: BorderSide(color: AppTheme.primaryAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onDisconnect,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildDisconnectedState() {
    return Container(
      padding: EdgeInsets.all(widget.isDesktop ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neutralGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.lightGrayText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No wallet connected',
              style: TextStyle(
                fontSize: widget.isDesktop ? 16 : 14,
                color: AppTheme.lightGrayText,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          Icon(
            Icons.account_balance_wallet_outlined,
            color: AppTheme.lightGrayText,
            size: 20,
          ),
        ],
      ),
    );
  }
}

