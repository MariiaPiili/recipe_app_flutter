import 'package:flutter/material.dart';
import '../widgets/signup_sheet.dart';
import 'home_screen.dart'; 

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;

  final pages = const [
    _OnboardData(
      title: 'Explore',
      subtitle: 'Find recipes from different cuisines and satisfy your taste.',
      imageAsset: 'assets/images/onboarding_1.png',
    ),
    _OnboardData(
      title: 'Welcome',
      subtitle: 'Discover more delicious recipes from around the world.',
      imageAsset: 'assets/images/onboarding_2.png',
    ),
    _OnboardData(
      title: 'Cook & Enjoy',
      subtitle: 'Save favorites and generate your shopping list instantly.',
      imageAsset: 'assets/images/onboarding_3.png',
    ),
  ];

  void next() {
    if (index < pages.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      openSignup();
    }
  }

  void skip() => openSignup();

  void openSignup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SignupSheet(
        onSignedUp: () {
          // закрываем bottom sheet
          Navigator.of(context).pop();

          // и заменяем онбординг на главный экран
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => index = i),
                itemBuilder: (_, i) {
                  final p = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // картинка
                        SizedBox(
                          height: 380,
                          width: double.infinity,
                          child: Center(
                            child: Image.asset(
                              p.imageAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          p.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),

            // точки
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                final active = i == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: active ? 18 : 6,
                  decoration: BoxDecoration(
                    color: active ? cs.primary : cs.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),

            const SizedBox(height: 22),

            // кнопки снизу
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PillButton(
                    text: 'Skip',
                    onTap: skip,
                    bg: cs.surfaceVariant,
                    fg: cs.onSurfaceVariant,
                  ),
                  _PillButton(
                    text: index == pages.length - 1 ? 'Done' : 'Next',
                    onTap: next,
                    bg: cs.primary,
                    fg: cs.onPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String subtitle;
  final String imageAsset;

  const _OnboardData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });
}

class _PillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;

  const _PillButton({
    required this.text,
    required this.onTap,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(color: fg, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
