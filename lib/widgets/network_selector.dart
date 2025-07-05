import 'package:flutter/material.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/services/decentralized_rpc_service.dart';

class NetworkSelector extends StatefulWidget {
  final String selectedChainId;
  final Function(String) onNetworkChanged;
  final bool isEnabled;
  final bool showBalance;
  final double? balance;

  const NetworkSelector({
    Key? key,
    required this.selectedChainId,
    required this.onNetworkChanged,
    this.isEnabled = true,
    this.showBalance = false,
    this.balance,
  }) : super(key: key);

  @override
  State<NetworkSelector> createState() => _NetworkSelectorState();
}

class _NetworkSelectorState extends State<NetworkSelector>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  final List<Map<String, dynamic>> _networks = [
    {
      'chainId': '1',
      'name': 'Ethereum',
      'symbol': 'ETH',
      'color': Color(0xFF627EEA),
      'icon': '🔷',
    },
    {
      'chainId': '56',
      'name': 'BSC',
      'symbol': 'BNB',
      'color': Color(0xFFF3BA2F),
      'icon': '🟡',
    },
    {
      'chainId': '137',
      'name': 'Polygon',
      'symbol': 'MATIC',
      'color': Color(0xFF8247E5),
      'icon': '🟣',
    },
    {
      'chainId': '8453',
      'name': 'Base',
      'symbol': 'ETH',
      'color': Color(0xFF0052FF),
      'icon': '🔵',
    },
    {
      'chainId': '42161',
      'name': 'Arbitrum',
      'symbol': 'ETH',
      'color': Color(0xFF28A0F0),
      'icon': '🔷',
    },
    {
      'chainId': '10',
      'name': 'Optimism',
      'symbol': 'ETH',
      'color': Color(0xFFFF0420),
      'icon': '🔴',
    },
  ];

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

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (!widget.isEnabled) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _selectNetwork(String chainId) {
    widget.onNetworkChanged(chainId);
    _toggleExpanded();
  }

  Map<String, dynamic> get _selectedNetwork {
    return _networks.firstWhere(
      (network) => network['chainId'] == widget.selectedChainId,
      orElse: () => _networks.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Network',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.whiteText,
              fontFamily: 'Montserrat',
            ),
          ),
        ),

        // Network selector
        Container(
          decoration: BoxDecoration(
            color: AppTheme.textFieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isExpanded 
                  ? AppTheme.primaryAccent 
                  : AppTheme.neutralGray.withOpacity(0.3),
              width: _isExpanded ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Selected network display
              _buildSelectedNetworkTile(),

              // Expanded network list
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
                child: _buildNetworkList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedNetworkTile() {
    final network = _selectedNetwork;
    
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Network icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (network['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  network['icon'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Network info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isEnabled 
                          ? AppTheme.whiteText 
                          : AppTheme.lightGrayText,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  if (widget.showBalance && widget.balance != null)
                    Text(
                      '${widget.balance!.toStringAsFixed(4)} ${network['symbol']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.lightGrayText,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                ],
              ),
            ),

            // Expand/collapse icon
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: widget.isEnabled 
                        ? AppTheme.primaryAccent 
                        : AppTheme.lightGrayText,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkList() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.neutralGray.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: _networks
            .where((network) => network['chainId'] != widget.selectedChainId)
            .map((network) => _buildNetworkOption(network))
            .toList(),
      ),
    );
  }

  Widget _buildNetworkOption(Map<String, dynamic> network) {
    return InkWell(
      onTap: () => _selectNetwork(network['chainId']),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.neutralGray.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Network icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (network['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  network['icon'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Network info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.whiteText,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Text(
                    network['symbol'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightGrayText,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.successGreen,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

