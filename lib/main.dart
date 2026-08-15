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
  final List<Map<String, dynamic>> _repositories = [];
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _parseUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> items = [];

      if (data is List) {
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            items.add({
              'name': item['name'] ?? item['title'] ?? 'Plugin Provider',
              'url': item['url'] ?? item['downloadUrl'] ?? item['link'] ?? item['file'] ?? '',
              'description': item['description'] ?? item['site'] ?? item['authors'] ?? 'Provider Plugin',
              'isRepo': item.containsKey('url') && item['url'].toString().endsWith('.json'),
            });
          }
        }
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('plugins') && data['plugins'] is List) {
          for (var plugin in data['plugins']) {
            items.add({
              'name': plugin['name'] ?? 'Provider',
              'url': plugin['url'] ?? plugin['downloadUrl'] ?? '',
              'description': plugin['description'] ?? plugin['authors'] ?? 'Provider Plugin',
              'isRepo': false,
            });
          }
        } else {
          items.add({
            'name': data['name'] ?? 'Custom Provider',
            'url': data['url'] ?? url,
            'description': data['description'] ?? 'Stream Source',
            'isRepo': false,
          });
        }
      }
      return items;
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  Future<void> _addRepository(String url) async {
    setState(() => _isLoading = true);
    try {
      final items = await _parseUrl(url);
      setState(() {
        _repositories.addAll(items);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repository items parsed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading repository: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openSubRepoOrLink(Map<String, dynamic> item) async {
    final String targetUrl = item['url'] ?? '';
    if (targetUrl.isEmpty) return;

    if (targetUrl.endsWith('.json') || item['isRepo'] == true) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF161B22),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _parseUrl(targetUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Failed to load sub-repository:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                }

                final subItems = snapshot.data ?? [];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'] ?? 'Repository Plugins',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10),
                      Text('Providers & Sites (${subItems.length})', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: subItems.length,
                          itemBuilder: (context, index) {
                            final sub = subItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D1117),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.language_rounded, color: Colors.redAccent),
                                title: Text(sub['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                subtitle: Text(sub['description'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                trailing: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 18),
                                onTap: () async {
                                  final Uri u = Uri.parse(sub['url']);
                                  if (!await launchUrl(u, mode: LaunchMode.externalApplication)) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Cannot open: ${sub['url']}')),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
    } else {
      final Uri u = Uri.parse(targetUrl);
      if (!await launchUrl(u, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $targetUrl')),
        );
      }
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
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Repo JSON', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Paste raw CS.json repository index URL.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'https://raw.githubusercontent.com/.../CS.json',
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
                      Navigator.pop(ctx);
                      await _addRepository(text);
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
                      'Installed / Parsed Repositories (${_repositories.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _repositories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                            'No repositories added yet.\nTap "Add Extension JSON Repo" and paste CS.json.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _repositories.length,
                          itemBuilder: (context, index) {
                            final repo = _repositories[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.folder_special_rounded, color: Colors.redAccent),
                                title: Text(
                                  repo['name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                subtitle: Text(
                                  repo['description'] ?? '',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                                onTap: () => _openSubRepoOrLink(repo),
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
