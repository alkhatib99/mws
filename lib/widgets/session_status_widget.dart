import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/session_service.dart';
import '../../app/theme/app_theme.dart';

class SessionStatusWidget extends StatelessWidget {
  const SessionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = Get.find<SessionService>();

    return Obx(() {
      if (!sessionService.isSessionActive.value) {
        return const SizedBox.shrink();
      }

      final remainingTime = sessionService.getRemainingSessionTime();
      final isExpiringSoon = sessionService.isSessionExpiringSoon();

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isExpiringSoon 
              ? Colors.orange.withOpacity(0.1)
              : AppTheme.secondaryBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpiringSoon 
                ? Colors.orange.withOpacity(0.3)
                : AppTheme.neutralGray.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpiringSoon ? Icons.warning_amber : Icons.timer,
              color: isExpiringSoon ? Colors.orange : AppTheme.primaryAccent,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Session: ${remainingTime}m remaining',
              style: TextStyle(
                color: isExpiringSoon ? Colors.orange : AppTheme.whiteText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            if (isExpiringSoon) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => sessionService.extendSession(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Extend',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

