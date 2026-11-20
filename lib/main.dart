import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const SessionHubApp());

class SessionHubApp extends StatelessWidget {
  const SessionHubApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Session Hub',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF125B54),
        surface: const Color(0xFFF7F8F5),
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F8F5),
      fontFamily: 'Roboto',
    ),
    home: const HomeScreen(),
  );
}

class ManagedApp {
  ManagedApp(this.name, this.description, this.initial, this.color, this.icon);
  final String name;
  final String description;
  final bool initial;
  final Color color;
  final IconData icon;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _native = MethodChannel('session_hub/apps');
  final apps = <ManagedApp>[
    ManagedApp(
      'COPS',
      'Business operations',
      false,
      const Color(0xFF315DA8),
      Icons.business_center_rounded,
    ),
    ManagedApp(
      'Appco',
      'Business & collections',
      false,
      const Color(0xFFB66A35),
      Icons.point_of_sale_rounded,
    ),
    ManagedApp(
      'Tricolab',
      'Staff workspace',
      false,
      const Color(0xFF7056A3),
      Icons.science_rounded,
    ),
    ManagedApp(
      'Greti',
      'Field services',
      false,
      const Color(0xFF287C70),
      Icons.route_rounded,
    ),
  ];
  late final Map<String, bool> sessions = {
    for (final app in apps) app.name: app.initial,
  };
  final Map<String, String> packageIds = {};
  bool busy = false;
  int get activeCount => sessions.values.where((value) => value).length;

  Future<void> setAll(bool signedIn) async {
    if (busy) return;
    setState(() => busy = true);
    // Demo connector: replace this loop with per-provider API/SSO calls.
    for (final app in apps) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (mounted) setState(() => sessions[app.name] = signedIn);
    }
    if (!mounted) return;
    setState(() => busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          signedIn
              ? 'All apps marked signed in on the checklist'
              : 'All apps marked signed out on the checklist',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void toggle(ManagedApp app) {
    setState(() => sessions[app.name] = !(sessions[app.name] ?? false));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${app.name}: checklist marked ${(sessions[app.name] ?? false) ? 'signed in' : 'signed out'}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> openApp(ManagedApp app) async {
    var packageId = packageIds[app.name];
    if (packageId == null || packageId.isEmpty) {
      final controller = TextEditingController();
      packageId = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Set up ${app.name}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Android package name',
              hintText: 'com.company.app',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (packageId == null || packageId.isEmpty || !mounted) return;
      packageIds[app.name] = packageId;
    }
    try {
      final opened =
          await _native.invokeMethod<bool>('launchPackage', {
            'packageName': packageId,
          }) ??
          false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? 'Opened ${app.name}. Sign in or out inside that app.'
                : '${app.name} was not found. Check its package name and installation.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PlatformException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Could not open ${app.name}'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 22,
        title: const Row(
          children: [
            Icon(Icons.hub_rounded, color: Color(0xFF125B54)),
            SizedBox(width: 10),
            Text(
              'Session Hub',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showInfo(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF124F49), Color(0xFF217C70)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shield_moon_rounded,
                        color: Color(0xFFBCE5D8),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'STAFF ACCESS',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFFBCE5D8),
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'One place.\nEvery work session.',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$activeCount of ${apps.length} sessions active',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: .82),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroButton(
                          label: 'Mark all in',
                          icon: Icons.login_rounded,
                          onPressed: busy ? null : () => setAll(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroButton(
                          label: 'Mark all out',
                          icon: Icons.logout_rounded,
                          outlined: true,
                          onPressed: busy ? null : () => setAll(false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your applications',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
                Text(
                  '4 CONNECTORS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF687671),
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            ...apps.map(
              (app) => _AppCard(
                app: app,
                active: sessions[app.name] ?? false,
                busy: busy,
                onTap: () => toggle(app),
                onOpen: () => openApp(app),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1EE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 19,
                    color: Color(0xFF315D53),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Prototype · Open each app here, then complete login or logout there. Status is a manual checklist; real session control needs provider SSO/API support.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF36554D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Session Hub works',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12),
          Text(
            'Open app launches an installed service by its Android package name. Complete sign-in or sign-out inside that app, then use Mark in/out as a checklist. Real session control requires company SSO (such as OIDC/SAML) or an approved service API.',
          ),
          SizedBox(height: 10),
          Text(
            'Android apps cannot silently sign in to or remotely sign out of unrelated apps by themselves. Never collect staff passwords in this hub. Ask each provider for supported SSO, OAuth, or admin session controls.',
          ),
        ],
      ),
    ),
  );
}

class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.app,
    required this.active,
    required this.busy,
    required this.onTap,
    required this.onOpen,
  });
  final ManagedApp app;
  final bool active;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9ECE8)),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: app.color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(app.icon, color: app.color),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                app.description,
                style: const TextStyle(color: Color(0xFF75807B), fontSize: 12),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? const Color(0xFF27866D)
                          : const Color(0xFFB7C0BB),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    active ? 'Signed in' : 'Signed out',
                    style: TextStyle(
                      fontSize: 11,
                      color: active
                          ? const Color(0xFF28755F)
                          : const Color(0xFF78817D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.tonal(
              onPressed: busy ? null : onOpen,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Open app'),
            ),
            TextButton(
              onPressed: busy ? null : onTap,
              child: Text(
                active ? 'Mark out' : 'Mark in',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool outlined;
  @override
  Widget build(BuildContext context) => outlined
      ? OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: .38)),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        )
      : FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF14574E),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        );
}
