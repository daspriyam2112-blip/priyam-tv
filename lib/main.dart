import 'package:flutter/material.dart';

void main() {
  runApp(const PriyamTVApp());
}

class PriyamTVApp extends StatelessWidget {
  const PriyamTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PriyamTV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090C10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF238636),
          surface: Color(0xFF161B22),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Custom Smooth Splash Screen (Prevents awkward OS zoom transitions)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    'https://raw.githubusercontent.com/daspriyam2112-blip/priyam-tv/main/logo.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Priyam',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                    ),
                    TextSpan(
                      text: 'TV',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _installedProviders = [
    {'name': 'SuperStream Provider', 'type': 'Movies & Series', 'url': 'https://provider.superstream.repo'},
    {'name': 'VidSrc Scraper', 'type': 'Multi-Source Embed', 'url': 'https://vidsrc.me/api'},
  ];

  final List<String> _repositoryUrls = [];

  void _showExtensionManager() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Extensions & Repositories',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add JSON Repository Collection URLs to pull available media streaming scrapers.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'https://raw.githubusercontent.com/.../plugins.json',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0D1117),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF238636),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            setModalState(() {
                              _repositoryUrls.add(controller.text.trim());
                              _installedProviders.add({
                                'name': 'Custom Scraper Source ${_installedProviders.length + 1}',
                                'type': 'Stream Extraction',
                                'url': controller.text.trim(),
                              });
                              controller.clear();
                            });
                            setState(() {});
                          }
                        },
                        child: const Text('Add', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Available Streaming Providers:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  _installedProviders.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text('No providers extracted yet. Add a repository link above.',
                                style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _installedProviders.length,
                          itemBuilder: (context, index) {
                            final provider = _installedProviders[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D1117),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.hub_rounded, color: Colors.redAccent),
                                title: Text(
                                  provider['name'] ?? '',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${provider['type']} • Ready',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setModalState(() {
                                      _installedProviders.removeAt(index);
                                    });
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        content: const Text('Playback and UI settings will appear here.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFF58A6FF))),
          )
        ],
      ),
    );
  }

  void _showAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Account Profile', style: TextStyle(color: Colors.white)),
        content: const Text('User profiles and sync settings will appear here.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFF58A6FF))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A2634), // Dark bluish face background tone
                Color(0xFF090C10), // Fades smoothly to deep black
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Facebook-style Face avatar in top bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      'https://raw.githubusercontent.com/daspriyam2112-blip/priyam-tv/main/logo.jpeg',
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 38,
                        height: 38,
                        color: Colors.blueGrey,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title text with "Priyam" in White and "TV" in Red
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Priyam',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'TV',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.extension_rounded, color: Colors.white70),
                    onPressed: _showExtensionManager,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                    onPressed: _showSettingsDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white70),
                    onPressed: _showAccountDialog,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center Face Profile Card
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://raw.githubusercontent.com/daspriyam2112-blip/priyam-tv/main/logo.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.tv,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome back!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Active Scrapers & Providers: ${_installedProviders.length}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF30363D)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _showExtensionManager,
              icon: const Icon(Icons.link_rounded, color: Colors.redAccent),
              label: const Text('Manage Provider Repositories'),
            ),
          ],
        ),
      ),
    );
  }
}
