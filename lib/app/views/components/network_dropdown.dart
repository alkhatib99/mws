import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mws/app/controllers/multi_send_controller.dart';
import 'package:mws/app/data/models/network_model.dart';
import 'package:mws/app/theme/app_theme.dart';

class NetworkDropdown extends StatelessWidget {
  final MultiSendController controller;

  const NetworkDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedNetwork.value,
          decoration: InputDecoration(
            labelText: 'Select Network:',
            labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.whiteText,
                ),
            filled: true,
            fillColor: AppTheme.neutralGray.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppTheme.primaryAccent, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          dropdownColor: AppTheme.primaryBackground,
          style: const TextStyle(color: AppTheme.whiteText),
          iconEnabledColor: AppTheme.whiteText,
          items: controller.networks.keys.map((String networkName) {
            return DropdownMenuItem<String>(
              value: networkName,
              child: Text(
                networkName,
                style: const TextStyle(color: AppTheme.whiteText),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.setSelectedNetwork(newValue);
            }
          },
        ));
  }
}
