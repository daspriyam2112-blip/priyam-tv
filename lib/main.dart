import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PriyamTVApp());
}

class PriyamTVApp extends StatelessWidget {
  const PriyamTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PriyamTV Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0E12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A90E2),
          surface: Color(0xFF161920),
        ),
      ),
      home: const OnboardingCheckScreen(),
    );
  }
}

class OnboardingCheckScreen extends StatefulWidget {
  const OnboardingCheckScreen({super.key});

  @override
  State<OnboardingCheckScreen> createState() => _OnboardingCheckScreenState();
}

class _OnboardingCheckScreenState extends State<OnboardingCheckScreen> {
  bool _isLoading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkSavedUser();
  }

  Future<void> _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('priyam_user');
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _username = savedName;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: PriyamFaceLoader()),
      );
    }

    if (_username != null && _username!.isNotEmpty) {
      return MainHomeScreen(username: _username!);
    }

    return const SetupProfileScreen();
  }
}

// Custom Retro Pixel Face Loader & Avatar Widget
class PriyamFaceAvatar extends StatelessWidget {
  final double size;
  const PriyamFaceAvatar({super.key, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2838),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5A88B5), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          'https://raw.githubusercontent.com/daspriyam2112-blip/priyam-tv/main/assets/face_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              painter: PixelFacePainter(),
            );
          },
        ),
      ),
    );
  }
}

class PriyamFaceLoader extends StatefulWidget {
  const PriyamFaceLoader({super.key});

  @override
  State<PriyamFaceLoader> createState() => _PriyamFaceLoaderState();
}

class _PriyamFaceLoaderState extends State<PriyamFaceLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          PriyamFaceAvatar(size: 80),
          SizedBox(height: 16),
          Text(
            "PRIYAM TV",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: Color(0xFF7CA6D8),
            ),
          )
        ],
      ),
    );
  }
}

class PixelFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7CA6D8)
      ..style = PaintingStyle.fill;

    // Drawn fallback digital face pattern
    double w = size.width / 8;
    double h = size.height / 8;
    canvas.drawRect(Rect.fromLTWH(w * 2, h * 2, w * 4, h * 1), paint);
    canvas.drawRect(Rect.fromLTWH(w * 2, h * 4, w * 1, h * 1), paint);
    canvas.drawRect(Rect.fromLTWH(w * 5, h * 4, w * 1, h * 1), paint);
    canvas.drawRect(Rect.fromLTWH(w * 3, h * 6, w * 2, h * 1), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveAndProceed() async {
    if (_nameController.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('priyam_user', _nameController.text.trim());

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainHomeScreen(username: _nameController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: PriyamFaceAvatar(size: 90)),
            const SizedBox(height: 24),
            const Text(
              "Welcome to PriyamTV",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter your name to set up account profile",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Username",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF161920),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2A3140)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B6D9E),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveAndProceed,
              child: const Text("Create Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final String username;
  const MainHomeScreen({super.key, required this.username});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  List<String> _extensionRepos = [];
  final TextEditingController _repoInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRepos();
  }

  Future<void> _loadRepos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extensionRepos = prefs.getStringList('priyam_extension_repos') ?? [];
    });
  }

  Future<void> _addRepo(String url) async {
    if (url.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extensionRepos.add(url.trim());
    });
    await prefs.setStringList('priyam_extension_repos', _extensionRepos);
    _repoInputController.clear();
  }

  Future<void> _removeRepo(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extensionRepos.removeAt(index);
    });
    await prefs.setStringList('priyam_extension_repos', _extensionRepos);
  }

  void _openExtensionManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14171E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                      const Text(
                        "Extensions & Repositories",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add JSON provider repository URLs below to load media scrapers.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _repoInputController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "https://raw.githubusercontent.com/.../repo.json",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF1E232E),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B6D9E),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onPressed: () {
                          if (_repoInputController.text.isNotEmpty) {
                            _addRepo(_repoInputController.text);
                            setModalState(() {});
                          }
                        },
                        child: const Text("Add", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Installed Repositories:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7CA6D8)),
                  ),
                  const SizedBox(height: 8),
                  _extensionRepos.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              "No extension repositories added yet.",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        )
                      : Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _extensionRepos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E232E),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.extension_outlined, color: Color(0xFF5A88B5), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _extensionRepos[index],
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        _removeRepo(index);
                                        setModalState(() {});
                                      },
                                    )
                                  ],
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
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161920),
          title: const Text("PriyamTV Settings", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.storage, color: Color(0xFF7CA6D8)),
                title: const Text("Clear Scraper Cache", style: TextStyle(color: Colors.white, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cache cleared successfully!")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFF7CA6D8)),
                title: const Text("Version Info", style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text("PriyamTV v1.0.0 (Official Build)", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Color(0xFF7CA6D8))),
            )
          ],
        );
      },
    );
  }

  void _openAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161920),
          title: Row(
            children: const [
              PriyamFaceAvatar(size: 32),
              SizedBox(width: 10),
              Text("User Account", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Logged in as: ${widget.username}", style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 8),
              Text("Installed Extensions: ${_extensionRepos.length}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SetupProfileScreen()),
                  (route) => false,
                );
              },
              child: const Text("Reset Account", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Color(0xFF7CA6D8))),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF10141D),
        elevation: 2,
        title: Row(
          children: [
            // Retro Facebook-Style Header Bar Avatar
            const PriyamFaceAvatar(size: 32),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'Priyam', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: 'TV', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A88B5))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.extension_rounded, color: Color(0xFF7CA6D8)),
            onPressed: _openExtensionManager,
            tooltip: "Extensions",
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: _openSettingsDialog,
            tooltip: "Settings",
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white70),
            onPressed: _openAccountDialog,
            tooltip: "Account Profile",
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PriyamFaceAvatar(size: 100),
              const SizedBox(height: 24),
              Text(
                "Welcome back, ${widget.username}!",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Active Extensions: ${_extensionRepos.length}",
                style: const TextStyle(color: Color(0xFF7CA6D8), fontSize: 14),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283446),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  side: const BorderSide(color: Color(0xFF5A88B5)),
                ),
                onPressed: _openExtensionManager,
                icon: const Icon(Icons.add_link, color: Colors.white),
                label: const Text("Manage Provider Repositories", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
