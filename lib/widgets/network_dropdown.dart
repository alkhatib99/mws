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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Network:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.whiteText,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.neutralGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryAccent.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedNetwork.value,
                isExpanded: true,
                dropdownColor: AppTheme.primaryBackground,
                style: const TextStyle(
                  color: AppTheme.whiteText,
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.primaryAccent,
                ),
                items: controller.networks.entries.map((entry) {
                  String networkName = entry.key;
                  Network network = entry.value;
                  return DropdownMenuItem<String>(
                    value: networkName,
                    child: Row(
                      children: [
                        // Network Logo
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              network.logoPath,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.network_check,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Network Name
                        Expanded(
                          child: Text(
                            network.name,
                            style: const TextStyle(
                              color: AppTheme.whiteText,
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
          ),
        ),
      ],
    );
  }
}
