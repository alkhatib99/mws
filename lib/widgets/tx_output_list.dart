import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/wallet_controller.dart';
import '../themes/app_theme.dart';

class TxOutputList extends StatelessWidget {
  const TxOutputList({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Transaction Links:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.whiteText,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.textFieldBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Obx(() {
            if (controller.transactionLinks.isEmpty) {
              return const Center(
                child: Text(
                  'Transaction links will appear here after sending funds',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              itemCount: controller.transactionLinks.length,
              itemBuilder: (context, index) {
                final link = controller.transactionLinks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _launchUrl(link),
                          child: Text(
                            link,
                            style: const TextStyle(
                              color: AppTheme.secondaryAccent,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              fontFamily: 'Arial',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _copyToClipboard(link),
                        icon: const Icon(
                          Icons.copy,
                          size: 16,
                          color: AppTheme.neutralGray,
                        ),
                        tooltip: 'Copy link',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _launchUrl(link),
                        icon: const Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: AppTheme.secondaryAccent,
                        ),
                        tooltip: 'Open in browser',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Transaction link copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successGreen,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open the link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
