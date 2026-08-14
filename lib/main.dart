import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PriyamTVApp());
}

class PriyamTVApp extends StatelessWidget {
  const PriyamTVApp({Super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PriyamTV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000), // OLED Pure Black
      ),
      home: const OnboardingCheckScreen(),
    );
  }
}

// Check saved user session
class OnboardingCheckScreen extends StatefulWidget {
  const OnboardingCheckScreen({Super.key});

  @override
  State<OnboardingCheckScreen> createState() => _OnboardingCheckScreenState();
}

class _OnboardingCheckScreenState extends State<OnboardingCheckScreen> {
  bool _isLoading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  Future<void> _checkUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: PriyamTVAnimatedLoader()),
      );
    }

    if (_username == null || _username!.isEmpty) {
      return const SetupProfileScreen();
    }

    return MainHomeScreen(username: _username!);
  }
}

// Glowing Pulse Animated Logo Loader
class PriyamTVAnimatedLoader extends StatefulWidget {
  const PriyamTVAnimatedLoader({Super.key});

  @override
  State<PriyamTVAnimatedLoader> createState() => _PriyamTVAnimatedLoaderState();
}

class _PriyamTVAnimatedLoaderState extends State<PriyamTVAnimatedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Priyam',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            TextSpan(
              text: 'TV',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE50914),
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Color(0xFFE50914),
                    blurRadius: 18,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Zero-Login Setup Screen
class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({Super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isFinished = false;

  Future<void> _saveUsername() async {
    if (_nameController.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _nameController.text.trim());

    setState(() {
      _isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isFinished
                ? _buildYouAreAllSetCard(context)
                : _buildSetupCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupCard() {
    return Container(
      key: const ValueKey("SetupCard"),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: PriyamTVAnimatedLoader()),
          const SizedBox(height: 30),
          const Text(
            "Language",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("English", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Icon(Icons.check_circle, color: Color(0xFFE50914), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Account Name",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter your username...",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF181818),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE50914)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveUsername,
              child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouAreAllSetCard(BuildContext context) {
    return Container(
      key: const ValueKey("SetCard"),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE50914).withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, size: 64, color: Color(0xFFE50914)),
          const SizedBox(height: 16),
          const Text(
            "You're All Set!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Welcome to PriyamTV, ${_nameController.text}!",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainHomeScreen(username: _nameController.text),
                  ),
                );
              },
              child: const Text("Launch PriyamTV Engine", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// Main Interface
class MainHomeScreen extends StatefulWidget {
  final String username;
  const MainHomeScreen({Super.key, required this.username});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  List<String> _extensionRepos = [];

  @override
  void initState() {
    super.initState();
    _loadExtensionRepos();
  }

  Future<void> _loadExtensionRepos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extensionRepos = prefs.getStringList('extension_repos') ?? [];
    });
  }

  Future<void> _addExtensionRepo(String url) async {
    if (url.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extensionRepos.add(url.trim());
    });
    await prefs.setStringList('extension_repos', _extensionRepos);
  }

  Future<void> _removeExtensionRepo(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extensionRepos.removeAt(index);
    });
    await prefs.setStringList('extension_repos', _extensionRepos);
  }

  void _openExtensionManager() {
    final TextEditingController urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      const Row(
                        children: [
                          Icon(Icons.extension_rounded, color: Color(0xFFE50914), size: 28),
                          SizedBox(width: 10),
                          Text(
                            "Extensions",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Add JSON Extension Repositories to load media providers into PriyamTV.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: urlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "https://example.com/repo.json",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF181818),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_link, color: Color(0xFFE50914)),
                        onPressed: () async {
                          if (urlController.text.trim().isNotEmpty) {
                            await _addExtensionRepo(urlController.text);
                            urlController.clear();
                            setModalState(() {});
                          }
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE50914)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "INSTALLED REPOSITORIES",
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 10),
                  _extensionRepos.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: const Text(
                            "No extension repos added yet.",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      : Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _extensionRepos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141414),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF222222)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.folder_zip_rounded, color: Colors.grey, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _extensionRepos[index],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () async {
                                        await _removeExtensionRepo(index);
                                        setModalState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text("PriyamTV Profile", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Logged in as: ${widget.username}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Policy: Zero-Login / Local Device Session", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFFE50914))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Priyam', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(text: 'TV', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.extension_rounded, color: Colors.white),
            onPressed: _openExtensionManager,
            tooltip: 'Extension',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: _showProfileDialog,
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1F1F1F)),
                ),
                child: Column(
                  children: [
                    const PriyamTVAnimatedLoader(),
                    const SizedBox(height: 24),
                    Text(
                      "Welcome back, ${widget.username}!",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Active Extension Repositories: ${_extensionRepos.length}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                      onPressed: _openExtensionManager,
                      icon: const Icon(Icons.extension_rounded, color: Colors.white),
                      label: const Text("Manage Extensions", style: TextStyle(color: Colors.white)),
                    )
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
