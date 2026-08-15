import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'logo.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Priyam',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                    ),
                    TextSpan(
                      text: 'TV',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 1.2),
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
  final List<Map<String, dynamic>> _extensions = [];
  bool _isLoading = false;

  // Real HTTP Fetcher for Extension JSON
  Future<void> _fetchRepository(String url) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Supports standard CloudStream/Tachiyomi JSON plugin array structure
        if (data is List) {
          setState(() {
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                _extensions.add({
                  'name': item['name'] ?? item['title'] ?? 'Unknown Extension',
                  'url': item['url'] ?? item['downloadUrl'] ?? item['link'] ?? url,
                  'description': item['description'] ?? item['site'] ?? 'Tap to open download/stream link',
                });
              }
            }
          });
        } else if (data is Map<String, dynamic>) {
          setState(() {
            _extensions.add({
              'name': data['name'] ?? 'Custom Scraper',
              'url': data['url'] ?? url,
              'description': data['description'] ?? 'Stream Source',
            });
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repository extensions loaded successfully!')),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load JSON: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openExtensionLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $urlString')),
      );
    }
  }

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
                    'Paste raw JSON URL (e.g. CloudStream repo) to fetch real plugin & download links.',
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
                        onPressed: () async {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            controller.clear();
                            Navigator.pop(context);
                            await _fetchRepository(text);
                          }
                        },
                        child: const Text('Fetch', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
              colors: [Color(0xFF1A2634), Color(0xFF090C10)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'logo.jpeg',
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Priyam',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextSpan(
                          text: 'TV',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.extension_rounded, color: Colors.white70),
                    onPressed: _showExtensionManager,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'logo.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome back!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _showExtensionManager,
                    icon: const Icon(Icons.add_link, color: Colors.white),
                    label: const Text('Add Extension JSON Repo', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Installed / Parsed Extensions (${_extensions.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _extensions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                            'No extensions fetched yet.\nTap "Add Extension JSON Repo" and paste a repository link.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _extensions.length,
                          itemBuilder: (context, index) {
                            final ext = _extensions[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.download_for_offline, color: Colors.redAccent),
                                title: Text(
                                  ext['name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                subtitle: Text(
                                  ext['description'] ?? '',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 20),
                                onTap: () => _openExtensionLink(ext['url']),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
