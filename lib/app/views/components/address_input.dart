import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/app/theme/app_theme.dart';
import 'package:mws/widgets/custom_text_field.dart';
 
class AddressInput extends StatelessWidget {
  final MultiSendController controller;

  const AddressInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Recipient Addresses (one per line):',
          hint: 'Paste wallet addresses here, one per line',
          controller: controller.addressesController,
          // maxLines: 4, // Removed maxLines as CustomTextField does not support it
          onChanged: (value) => controller.addresses.value = value,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.loadAddressesFromFile(),
            style: AppTheme.neutralButtonStyle,
            child: const Text('Load Addresses from .txt'),
          ),
        ),
      ],
    );
  }
}
