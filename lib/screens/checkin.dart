import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/ui.dart';
import 'payment_method.dart';
import 'admin_stub.dart';

class CheckInScreen extends StatefulWidget {
  static const route = '/';
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _policy = TextEditingController();
  final _idNumber = TextEditingController();
  String? _photoPath;
  bool _submitted = false;

  late final AnimationController _acIntro; // entrance anim
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fadeIn;

  late final AnimationController _bgPulse; // lively header gradient

  @override
  void initState() {
    super.initState();

    // Animate in
    _acIntro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _slideIn = Tween<Offset>(begin: const Offset(0.0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _acIntro, curve: Curves.easeOutCubic));
    _fadeIn = CurvedAnimation(parent: _acIntro, curve: Curves.easeIn);
    _acIntro.forward();

    // Gentle pulsing gradient in header
    _bgPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Update header text live as user types
    for (final c in [_firstName, _lastName, _policy]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _acIntro.dispose();
    _bgPulse.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _policy.dispose();
    _idNumber.dispose();
    super.dispose();
  }

  String? _require(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _requirePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final digits = v.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length < 8) return 'Enter a valid phone number';
    return null;
  }

  String? _optionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRe.hasMatch(v.trim())) {
      return 'Enter a valid email or leave blank';
    }
    return null;
  }

  String? _requireId13(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 13) return 'Enter a valid 13‑digit ID number';
    return null;
  }

  String get _dynamicTitle {
    final fn = _firstName.text.trim();
    final ln = _lastName.text.trim();
    final pol = _policy.text.trim();
    if (fn.isEmpty && ln.isEmpty && pol.isEmpty) return 'Client Check‑In';
    final name = [fn, ln].where((e) => e.isNotEmpty).join(' ');
    if (name.isNotEmpty && pol.isNotEmpty) return 'Hi, $name • Policy: $pol';
    if (name.isNotEmpty) return 'Hi, $name';
    if (pol.isNotEmpty) return 'Policy: $pol';
    return 'Client Check‑In';
  }

  Future<void> _ensurePhotoCaptured() async {
    if (_photoPath != null) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.photo_camera_front_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              const Text('Quick photo required'),
            ],
          ),
          content: const Text(
            'For your security and to prevent fraud, we take a quick face photo before capturing your details. ',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final picker = ImagePicker();
                final img = await picker.pickImage(
                  source: ImageSource.camera,
                  preferredCameraDevice: CameraDevice.front,
                  imageQuality: 70,
                );
                if (img != null) {
                  setState(() => _photoPath = img.path);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Take Photo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('EEE, d MMM yyyy • HH:mm').format(DateTime.now());
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Check‑In'),
        actions: [
          IconButton(
            tooltip: 'Admin',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AdminStubScreen.route),
          ),
        ],
      ),
      body: MaxWidth(
        maxWidth: 820,
        child: SlideTransition(
          position: _slideIn,
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lively header / hero
                AnimatedBuilder(
                  animation: _bgPulse,
                  builder: (context, _) {
                    final t = _bgPulse.value; // 0..1
                    final a = 0.65 + 0.25 * math.sin(t * math.pi * 2);
                    final b = 0.50 + 0.25 * math.cos(t * math.pi * 2);
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primaryContainer.withOpacity(a),
                            scheme.secondaryContainer.withOpacity(b),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AnimatedRotation(
                            turns: 0.02 * math.sin(t * math.pi * 2),
                            duration: const Duration(milliseconds: 400),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: scheme.surface.withOpacity(.65),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.verified_user_outlined,
                                  size: 36),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 350),
                                  transitionBuilder: (child, anim) =>
                                      SizeTransition(
                                          sizeFactor: anim,
                                          child: FadeTransition(
                                              opacity: anim, child: child)),
                                  child: Text(
                                    _dynamicTitle,
                                    key: ValueKey(_dynamicTitle),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Check‑in time: $now'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Why we need this info (block)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: const Icon(Icons.privacy_tip_outlined),
                    ),
                    title: const Text('Why we collect this'),
                    subtitle: const Text(
                      'Your name, phone and policy number are used to find your policy and send receipts/updates. '
                      'Email is optional (for digital receipts). We respect your privacy.',
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Expanded(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Personal block (with photo next to names)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline,
                                          color: scheme.primary),
                                      const SizedBox(width: 8),
                                      Text('Personal details',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Avatar + Retake button
                                      Column(
                                        children: [
                                          AnimatedBuilder(
                                            animation: _bgPulse,
                                            builder: (_, __) =>
                                                Transform.rotate(
                                              angle: 0.02 *
                                                  math.sin(_bgPulse.value *
                                                      math.pi *
                                                      2),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                curve: Curves.easeOut,
                                                height: 72,
                                                width: 72,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: scheme.surfaceVariant,
                                                  border: Border.all(
                                                      color: scheme
                                                          .outlineVariant),
                                                ),
                                                child: ClipOval(
                                                  child: _photoPath == null
                                                      ? const Icon(
                                                          Icons.person_outline,
                                                          size: 36)
                                                      : Image.file(
                                                          File(_photoPath!),
                                                          fit: BoxFit.cover),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          OutlinedButton.icon(
                                            onPressed: () async {
                                              final picker = ImagePicker();
                                              final img =
                                                  await picker.pickImage(
                                                source: ImageSource.camera,
                                                preferredCameraDevice:
                                                    CameraDevice.front,
                                                imageQuality: 70,
                                              );
                                              if (img != null) {
                                                setState(() =>
                                                    _photoPath = img.path);
                                              }
                                            },
                                            icon: const Icon(Icons.autorenew),
                                            label: Text(_photoPath == null
                                                ? 'Take Photo'
                                                : 'Retake'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      // Name fields
                                      Expanded(
                                        child: Wrap(
                                          runSpacing: 16,
                                          spacing: 16,
                                          children: [
                                            SizedBox(
                                              width: 360,
                                              child: TextFormField(
                                                controller: _firstName,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'First Name *',
                                                  prefixIcon: Icon(
                                                      Icons.badge_outlined),
                                                ),
                                                validator: _require,
                                                textInputAction:
                                                    TextInputAction.next,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 360,
                                              child: TextFormField(
                                                controller: _lastName,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Last Name *',
                                                  prefixIcon: Icon(Icons.badge),
                                                ),
                                                validator: _require,
                                                textInputAction:
                                                    TextInputAction.next,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Contact block
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.contact_phone_outlined,
                                          color: scheme.primary),
                                      const SizedBox(width: 8),
                                      Text('Contact',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    runSpacing: 16,
                                    spacing: 16,
                                    children: [
                                      SizedBox(
                                        width: 360,
                                        child: TextFormField(
                                          controller: _phone,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              signed: false, decimal: false),
                                          decoration: const InputDecoration(
                                            labelText: 'Phone Number *',
                                            prefixIcon:
                                                Icon(Icons.call_outlined),
                                          ),
                                          validator: _requirePhone,
                                          textInputAction: TextInputAction.next,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 360,
                                        child: TextFormField(
                                          controller: _email,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                            labelText: 'Email (optional)',
                                            prefixIcon:
                                                Icon(Icons.alternate_email),
                                          ),
                                          validator: _optionalEmail,
                                          textInputAction: TextInputAction.next,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Policy block
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.assignment_turned_in_outlined,
                                          color: scheme.primary),
                                      const SizedBox(width: 8),
                                      Text('Policy & ID',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    runSpacing: 16,
                                    spacing: 16,
                                    children: [
                                      SizedBox(
                                        width: 360,
                                        child: TextFormField(
                                          controller: _policy,
                                          decoration: const InputDecoration(
                                            labelText: 'Policy Number *',
                                            prefixIcon: Icon(Icons
                                                .confirmation_number_outlined),
                                          ),
                                          validator: _require,
                                          textInputAction: TextInputAction.next,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 360,
                                        child: TextFormField(
                                          controller: _idNumber,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(),
                                          decoration: const InputDecoration(
                                            labelText:
                                                'South African ID Number (13 digits) *',
                                            prefixIcon:
                                                Icon(Icons.perm_identity),
                                          ),
                                          validator: _requireId13,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Photo verification block (REQUIRED) — kept as visible confirmation
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.photo_camera_front_outlined,
                                          color: scheme.primary),
                                      const SizedBox(width: 8),
                                      Text('Face verification (required)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      AnimatedBuilder(
                                        animation: _bgPulse,
                                        builder: (_, __) => Transform.rotate(
                                          angle: 0.02 *
                                              math.sin(
                                                  _bgPulse.value * math.pi * 2),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeOut,
                                            height: 72,
                                            width: 72,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: scheme.surfaceVariant,
                                              border: Border.all(
                                                  color: scheme.outlineVariant),
                                            ),
                                            child: ClipOval(
                                              child: _photoPath == null
                                                  ? const Icon(
                                                      Icons.person_outline,
                                                      size: 36)
                                                  : Image.file(
                                                      File(_photoPath!),
                                                      fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      FilledButton.icon(
                                        onPressed: () async {
                                          final picker = ImagePicker();
                                          final img = await picker.pickImage(
                                            source: ImageSource.camera,
                                            preferredCameraDevice:
                                                CameraDevice.front,
                                            imageQuality: 70,
                                          );
                                          if (img != null) {
                                            setState(() {
                                              _photoPath = img.path;
                                              _submitted = false;
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                            Icons.photo_camera_outlined),
                                        label: Text(_photoPath == null
                                            ? 'Take Photo'
                                            : 'Retake Photo'),
                                      ),
                                    ],
                                  ),
                                  if (_submitted && _photoPath == null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'A clear face photo is required to continue.',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Next',
                        onPressed: () {
                          setState(() => _submitted = true);
                          final validForm =
                              _formKey.currentState?.validate() ?? false;
                          final hasPhoto = _photoPath != null;
                          if (!hasPhoto) {
                            _ensurePhotoCaptured();
                            return;
                          }
                          if (validForm && hasPhoto) {
                            Navigator.pushNamed(
                              context,
                              PaymentMethodScreen.route,
                              arguments: {
                                'firstName': _firstName.text.trim(),
                                'lastName': _lastName.text.trim(),
                                'phone': _phone.text.trim(),
                                'email': _email.text.trim(),
                                'policy': _policy.text.trim(),
                                'idNumber': _idNumber.text.trim(),
                                'photoPath': _photoPath,
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
