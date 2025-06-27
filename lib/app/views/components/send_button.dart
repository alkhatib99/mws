import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/app/theme/app_theme.dart';

class SendButton extends StatelessWidget {
  final MultiSendController controller;

  const SendButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.sendFunds(),
            style: AppTheme.primaryButtonStyle,
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
                      Text('Sending...'),
                    ],
                  )
                : const Text(
                    'Send Funds',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
  }
}
