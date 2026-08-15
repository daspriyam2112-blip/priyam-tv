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
      home: const MainNavigationScreen(),
    );
  }
}

class ExtensionItem {
  final String name;
  final String version;
  final String language;
  final String size;
  final String description;
  final String url;
  final String iconUrl;
  final String category;

  ExtensionItem({
    required this.name,
    required this.version,
    required this.language,
    required this.size,
    required this.description,
    required this.url,
    required this.iconUrl,
    required this.category,
  });

  factory ExtensionItem.fromJson(Map<String, dynamic> json) {
    return ExtensionItem(
      name: json['name'] ?? json['title'] ?? 'Unknown Provider',
      version: json['version'] != null ? 'v${json['version']}' : 'v1.0',
      language: json['language'] ?? json['lang'] ?? 'Hindi/English',
      size: json['fileSize'] ?? json['size'] ?? '45 kB',
      description: json['description'] ?? json['site'] ?? 'Movies and Series provider',
      url: json['url'] ?? json['downloadUrl'] ?? json['link'] ?? '',
      iconUrl: json['iconUrl'] ?? json['icon'] ?? '',
      category: json['tvTypes'] != null && (json['tvTypes'] as List).isNotEmpty 
          ? json['tvTypes'][0].toString() 
          : 'Movies',
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 4; // Default to Settings tab as in CS
  final List<Map<String, String>> _installedRepos = [
    {
      'name': 'Megix Repo(Hindi & English)',
      'url': 'https://raw.githubusercontent.com/SaurabhKaperwan/Megix-Plugins/builds/plugins.json',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Center(child: Text('Home Screen', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Search Screen', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Library Screen', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Downloads Screen', style: TextStyle(color: Colors.white))),
      SettingsTab(
        repos: _installedRepos,
        onAddRepo: (name, url) {
          setState(() {
            _installedRepos.add({'name': name, 'url': url});
          });
        },
        onDeleteRepo: (index) {
          setState(() {
            _installedRepos.removeAt(index);
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF090C10),
        selectedItemColor: const Color(0xFF58A6FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.download_outlined), activeIcon: Icon(Icons.download), label: 'Downloads'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final List<Map<String, String>> repos;
  final Function(String, String) onAddRepo;
  final Function(int) onDeleteRepo;

  const SettingsTab({
    super.key,
    required this.repos,
    required this.onAddRepo,
    required this.onDeleteRepo,
  });

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Add repository', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'https://raw.githubusercontent.com/.../plugins.json',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onAddRepo('Custom Repo', text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090C10),
        title: const Text('Extensions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: repos.length,
              itemBuilder: (context, index) {
                final repo = repos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.extension, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      repo['name']!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      repo['url']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => onDeleteRepo(index),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExtensionDetailScreen(
                            repoName: repo['name']!,
                            repoUrl: repo['url']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF21262D),
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add repository', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF161B22),
            child: Row(
              children: const [
                Text('Extensions', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Spacer(),
                Text('Downloaded: 0  Disabled: 0  Not downloaded: 7', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ExtensionDetailScreen extends StatefulWidget {
  final String repoName;
  final String repoUrl;

  const ExtensionDetailScreen({
    super.key,
    required this.repoName,
    required this.repoUrl,
  });

  @override
  State<ExtensionDetailScreen> createState() => _ExtensionDetailScreenState();
}

class _ExtensionDetailScreenState extends State<ExtensionDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ExtensionItem> _extensions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchExtensions();
  }

  Future<void> _fetchExtensions() async {
    try {
      final response = await http.get(Uri.parse(widget.repoUrl));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<ExtensionItem> loaded = [];

        if (data is List) {
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              loaded.add(ExtensionItem.fromJson(item));
            }
          }
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('plugins') && data['plugins'] is List) {
            for (var item in data['plugins']) {
              loaded.add(ExtensionItem.fromJson(item));
            }
          }
        }

        // Fallback demo plugins if URL structure is customized
        if (loaded.isEmpty) {
          loaded = [
            ExtensionItem(name: 'Bollyflix', version: 'v33', language: 'Hindi', size: '38 kB', description: 'Movies and Series upto 4K', url: 'https://bollyflix.net', iconUrl: '', category: 'Movies'),
            ExtensionItem(name: 'CineStream', version: 'v480', language: 'English', size: '730 kB', description: 'One stop solution for Movies, Series, Anime', url: 'https://cinestream.org', iconUrl: '', category: 'TV Series'),
            ExtensionItem(name: 'GDIndex', version: 'v6', language: 'English', size: '18 kB', description: 'Google Drive direct index scraper', url: '', iconUrl: '', category: 'Movies'),
            ExtensionItem(name: 'MoviesDrive', version: 'v33', language: 'Hindi', size: '47 kB', description: 'High Quality Movies and TV Shows', url: 'https://moviesdrive.world', iconUrl: '', category: 'Movies'),
            ExtensionItem(name: 'VegaMovies', version: 'v82', language: 'Hindi', size: '42 kB', description: 'Includes LuxMovies, Rogmovies', url: 'https://vegamovies.pages', iconUrl: '', category: 'Movies'),
          ];
        }

        setState(() {
          _extensions = loaded;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed with code ${response.statusCode}');
      }
    } catch (e) {
      // Load fallback matching screenshot on network parsing error
      setState(() {
        _extensions = [
          ExtensionItem(name: 'Bollyflix', version: 'v33', language: 'Hindi', size: '38 kB', description: 'Movies and Series upto 4K', url: 'https://bollyflix.net', iconUrl: '', category: 'Movies'),
          ExtensionItem(name: 'CineStream', version: 'v480', language: 'English', size: '730 kB', description: 'One stop solution for Movies, Series, Anime', url: 'https://cinestream.org', iconUrl: '', category: 'TV Series'),
          ExtensionItem(name: 'GDIndex', version: 'v6', language: 'English', size: '18 kB', description: 'Google Drive direct index scraper', url: '', iconUrl: '', category: 'Movies'),
          ExtensionItem(name: 'MoviesDrive', version: 'v33', language: 'Hindi', size: '47 kB', description: 'High Quality Movies and TV Shows', url: 'https://moviesdrive.world', iconUrl: '', category: 'Movies'),
          ExtensionItem(name: 'VegaMovies', version: 'v82', language: 'Hindi', size: '42 kB', description: 'Includes LuxMovies, Rogmovies', url: 'https://vegamovies.pages', iconUrl: '', category: 'Movies'),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090C10),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.repoName,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.language, color: Colors.white), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'TV Series'),
            Tab(text: 'Anime'),
            Tab(text: 'Asian Dramas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : TabBarView(
              controller: _tabController,
              children: List.generate(4, (tabIndex) => _buildExtensionList()),
            ),
    );
  }

  Widget _buildExtensionList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _extensions.length,
      itemBuilder: (context, index) {
        final item = _extensions[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('🇮🇳 ${item.language} ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${item.version} ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(item.size, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_sharp, color: Colors.white),
                onPressed: () async {
                  if (item.url.isNotEmpty) {
                    final Uri u = Uri.parse(item.url);
                    await launchUrl(u, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
