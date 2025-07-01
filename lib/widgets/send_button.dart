import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/app/theme/app_theme.dart';

class SendButton extends StatelessWidget {
  final MultiSendController controller;

  const SendButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canSend = controller.canSendFunds && !controller.isLoading.value;
      
      return Column(
        children: [
          // Progress indicator showing completion status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Transaction Setup Progress',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    _buildProgressStep(
                      'Network',
                      controller.isNetworkSelected.value,
                      Icons.network_check,
                    ),
                    _buildProgressConnector(controller.isNetworkSelected.value),
                    _buildProgressStep(
                      'Token',
                      controller.isTokenSelected.value,
                      Icons.token,
                    ),
                    _buildProgressConnector(controller.isTokenSelected.value),
                    _buildProgressStep(
                      'Addresses',
                      controller.areAddressesValid.value,
                      Icons.location_on,
                    ),
                    _buildProgressConnector(controller.areAddressesValid.value),
                    _buildProgressStep(
                      'Amount',
                      controller.isAmountValid.value,
                      Icons.attach_money,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Send Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: canSend ? () => controller.sendFunds() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canSend ? AppTheme.primaryAccent : Colors.grey[600],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[600],
                disabledForegroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canSend ? 4 : 0,
              ),
              child: controller.isLoading.value
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Sending...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    )
                  : Text(
                      canSend ? 'Send Funds' : 'Complete Setup to Send',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: canSend ? Colors.white : Colors.grey[400],
                      ),
                    ),
            ),
          ),
          
          // Helper text
          if (!canSend && !controller.isLoading.value)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _getHelpText(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    });
  }
  
  Widget _buildProgressStep(String label, bool isCompleted, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.primaryAccent : Colors.grey[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isCompleted ? Colors.white : Colors.grey[400],
              fontSize: 10,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressConnector(bool isActive) {
    return Container(
      width: 20,
      height: 2,
      color: isActive ? AppTheme.primaryAccent : Colors.grey[600],
      margin: const EdgeInsets.only(bottom: 20),
    );
  }
  
  String _getHelpText() {
    if (!controller.isNetworkSelected.value) {
      return 'Please select a network to continue';
    } else if (!controller.isTokenSelected.value) {
      return 'Please select a token to continue';
    } else if (!controller.areAddressesValid.value) {
      return 'Please enter valid recipient addresses';
    } else if (!controller.isAmountValid.value) {
      return 'Please enter a valid amount';
    }
    return '';
  }
}
