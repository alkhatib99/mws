import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../themes/app_theme.dart';

class NetworkDropdown extends StatelessWidget {
  const NetworkDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Select Network:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.whiteText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedNetwork.value,
              isExpanded: true,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
              dropdownColor: AppTheme.primaryBackground,
              items: controller.networks.keys.map((String network) {
                return DropdownMenuItem<String>(
                  value: network,
                  child: Text(
                    network,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Arial',
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.setSelectedNetwork(newValue);
                }
              },
            ),
          ),
        )),
      ],
    );
  }
}

