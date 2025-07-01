import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/theme/app_theme.dart';

class SocialLinksBar extends StatelessWidget {
  const SocialLinksBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Multilingual footer text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'هذا البرنامج أحد الأدوات المستخدمة في المجتمع العربي الأكبر في الويب3 BAG\nThis tool is part of the tools used in the largest Arabic Web3 community – BAG',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightGrayText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Social links row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialLink(
              icon: Icons.language,
              label: 'Website',
              url: 'https://bagguild.com/',
              color: AppTheme.whiteText,
            ),
            const SizedBox(width: 24),
            _buildSocialLink(
              icon: Icons.computer,
              label: 'dApp',
              url: 'https://dapp.bagguild.com/',
              color: AppTheme.whiteText,
            ),
            const SizedBox(width: 24),
            _buildSocialLink(
              icon: Icons.chat,
              label: 'Discord',
              url: 'https://discord.gg/bagguild',
              color: const Color(0xFF5865F2), // Discord blue
            ),
            const SizedBox(width: 24),
            _buildSocialLink(
              icon: Icons.alternate_email,
              label: 'Twitter',
              url: 'https://twitter.com/BagGuild',
              color: const Color(0xFF1DA1F2), // Twitter blue
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLink({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.neutralGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.whiteText,
                fontSize: 12,
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}


