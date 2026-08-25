import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_layout.dart';

/// Shows navigation instructions only until the user acknowledges them.
class GestureTutorialWidget extends StatefulWidget {
  const GestureTutorialWidget({super.key});

  static const preferenceKey = 'has_seen_gesture_tutorial';

  @override
  State<GestureTutorialWidget> createState() => _GestureTutorialWidgetState();
}

class _GestureTutorialWidgetState extends State<GestureTutorialWidget> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    final preferences = await SharedPreferences.getInstance();
    final hasSeenTutorial =
        preferences.getBool(GestureTutorialWidget.preferenceKey) ?? false;
    if (mounted && !hasSeenTutorial) {
      setState(() => _isVisible = true);
    }
  }

  Future<void> _dismiss() async {
    setState(() => _isVisible = false);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(GestureTutorialWidget.preferenceKey, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: BlockSemantics(
        child: Material(
          color: AppColors.space.withValues(alpha: 0.9),
          child: SafeArea(
            child: Center(
              child: Semantics(
                container: true,
                liveRegion: true,
                label: 'Solar System navigation tutorial',
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.card,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 24),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.explore_rounded,
                        color: AppColors.secondary,
                        size: 32,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Explore the Solar System',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _GestureHintWidget(
                        icon: Icons.swipe_rounded,
                        title: 'Drag with one finger',
                        description: 'Orbit the camera around the planets.',
                      ),
                      const _GestureHintWidget(
                        icon: Icons.pinch_rounded,
                        title: 'Use two fingers',
                        description: 'Zoom the view in or out.',
                      ),
                      const _GestureHintWidget(
                        icon: Icons.ads_click_rounded,
                        title: 'Tap a celestial body',
                        description: 'Open its details and focus the camera.',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _dismiss,
                          child: const Text('Start exploring'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GestureHintWidget extends StatelessWidget {
  const _GestureHintWidget({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$title. ',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
