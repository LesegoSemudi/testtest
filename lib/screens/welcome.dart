import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/ui.dart';
import 'checkin.dart';

class WelcomeScreen extends StatefulWidget {
  static const route = '/welcome';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _acFade;
  late final Animation<double> _fade;
  late final AnimationController _acGlow; // animates emphasized gradient text
  late final AnimationController _acPulse; // pulses the Start Check-In button

  @override
  void initState() {
    super.initState();
    _acFade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
    _fade = CurvedAnimation(parent: _acFade, curve: Curves.easeInOut);

    _acGlow =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _acPulse =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _acFade.dispose();
    _acGlow.dispose();
    _acPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft gradient background (reverted)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.surface, scheme.surfaceContainerHighest],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Animated blobs for a modern look
            Positioned(
              top: -60,
              left: -40,
              child: _Blob(
                  color: scheme.primaryContainer.withOpacity(.6), size: 220),
            ),
            Positioned(
              bottom: -50,
              right: -30,
              child: _Blob(
                  color: scheme.secondaryContainer.withOpacity(.5), size: 260),
            ),

            // Content (scroll-safe with bottom padding)
            SafeArea(
              child: MaxWidth(
                maxWidth: 980,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- BEGIN original children (unchanged) ---

                          // Branch name top right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.location_on_outlined, size: 18),
                              SizedBox(width: 6),
                              Text('Mafikeng Branch',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              SizedBox(width: 16),
                            ],
                          ),
                          _Float(
                              child: Image.network(
                                  'https://res.cloudinary.com/dqtr6uqzi/image/upload/v1752961405/smalllogo_ytthch.webp')),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome to ',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFFC1121F),
                                    Color(0xFFB68D40)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  'Panther Funeral Parlour',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _EmphasisLine(ac: _acGlow),
                          const SizedBox(height: 10),
                          Text(
                            'This will take less than a minute.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 420,
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: const [
                                    Text('Step 0 of 3',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 8),
                                    LinearProgressIndicator(value: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Removed 3 bullet sentences here
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: const [
                              _FeatureCard(
                                  icon: Icons.shield_moon_outlined,
                                  title: 'Secure',
                                  desc:
                                      'PIN confirmation and audit trails protect your payments.'),
                              _FeatureCard(
                                  icon: Icons.bolt_outlined,
                                  title: 'Fast',
                                  desc:
                                      'Streamlined steps get you through in under a minute.'),
                              _FeatureCard(
                                  icon: Icons.visibility_outlined,
                                  title: 'Transparent',
                                  desc:
                                      'Instant SMS/Email confirms what was captured.'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // CTA buttons as square blocks
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: 50),
                                  Image.network(
                                    'https://storage.googleapis.com/msgsndr/s6GpMTLhRN9LCvumuK6p/media/6897960ce2eb0c14734decea.png',
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    'Powered by\n Fusion Works Solutions',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SquareBlockButton(
                                    icon: Icons.info_outline,
                                    label: 'Learn\nMore',
                                    onTap: () => _showLearnMore(context),
                                    filled: false,
                                  ),
                                  const SizedBox(width: 20),
                                  _SquareBlockButton(
                                    icon: Icons.play_circle_outline,
                                    label: 'Start\nCheck-In',
                                    onTap: () => Navigator.pushReplacementNamed(
                                        context, CheckInScreen.route),
                                    filled: true,
                                  ),
                                ],
                              ),
                              SizedBox(width: 140)
                            ],
                          ),

                          // --- END original children ---
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLearnMore(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: scheme.primary),
                  const SizedBox(width: 8),
                  const Text('Why this is required',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'The check‑in step links your identity to your policy and payment. It prevents manual errors, wrong allocations and internal fraud. It also gives you a digital proof of payment immediately.',
              ),
              const SizedBox(height: 16),
              const Text('What we collect:',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const _Bullet(text: 'Name and surname (required)', delayMs: 0),
              const _Bullet(text: 'Phone number (required)', delayMs: 80),
              const _Bullet(text: 'Policy number (required)', delayMs: 160),
              const _Bullet(text: 'Email (optional)', delayMs: 240),
              const SizedBox(height: 16),
              const Text('Privacy:',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                  'Your information is used to identify your account, send receipts and keep audit records. It is not shared externally.'),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }
}

class _EmphasisLine extends StatelessWidget {
  final AnimationController ac;
  const _EmphasisLine({required this.ac});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: ac,
      builder: (context, _) {
        // Animate a subtle gradient shift to draw attention
        final t = ac.value;
        final colors = [
          theme.colorScheme.primary.withOpacity(.95),
          theme.colorScheme.secondary.withOpacity(.95),
        ];
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1 + t, 0),
              end: Alignment(1 + t, 0),
              colors: colors,
            ).createShader(rect);
          },
          child: Text(
            'A quick check‑in is REQUIRED BEFORE ANY PAYMENT',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium)
              ]),
              const SizedBox(height: 8),
              Text(desc),
            ],
          ),
        ),
      ),
    );
  }
}

class _Float extends StatefulWidget {
  final Widget child;
  final double amplitude; // vertical travel in px
  final Duration period; // full cycle duration
  const _Float(
      {required this.child,
      this.amplitude = 6,
      this.period = const Duration(seconds: 3),
      Key? key})
      : super(key: key);

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value * 2 * math.pi; // 0..2π
        final dy = math.sin(t) * widget.amplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

class _Blob extends StatefulWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  State<_Blob> createState() => _BlobState();
}

class _BlobState extends State<_Blob> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(6 * math.sin(t), 8 * math.cos(t)),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: widget.color.withOpacity(.25),
                    blurRadius: 24,
                    spreadRadius: 6)
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final int delayMs;
  const _Bullet({required this.text, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delayMs)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            builder: (context, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 12),
                child: Transform.scale(scale: .9 + .1 * v, child: child),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: scheme.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _SquareBlockButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled; // true = gradient filled, false = outlined
  const _SquareBlockButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
    Key? key,
  }) : super(key: key);

  @override
  State<_SquareBlockButton> createState() => _SquareBlockButtonState();
}

class _SquareBlockButtonState extends State<_SquareBlockButton> {
  bool _pressed = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final border = widget.filled
        ? null
        : Border.all(
            color: (_hover ? scheme.primary : scheme.primary.withOpacity(.6)),
            width: 1.6,
          );

    final elevation =
        widget.filled ? (_hover ? 6.0 : 4.0) : (_hover ? 2.0 : 0.0);

    return SizedBox(
      width: 160,
      height: 160,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          scale: _pressed ? 0.97 : 1.0,
          child: AnimatedPhysicalModel(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            elevation: elevation,
            color: Colors.transparent,
            shadowColor: widget.filled
                ? (scheme.primary.withOpacity(.45))
                : (scheme.shadow.withOpacity(.18)),
            borderRadius: BorderRadius.circular(16),
            shape: BoxShape.rectangle,
            child: Material(
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: widget.filled
                      ? const LinearGradient(
                          colors: [Color(0xFFC1121F), Color(0xFFB68D40)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: border,
                  color: widget.filled ? null : scheme.surface,
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          size: 44,
                          color: widget.filled ? Colors.white : scheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            height: 1.2,
                            color:
                                widget.filled ? Colors.white : scheme.onSurface,
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
      ),
    );
  }
}
