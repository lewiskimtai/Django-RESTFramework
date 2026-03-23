import 'package:flutter/material.dart';
// import 'dart:convert'; // if you need to parse JSON manually

// Replace with your real API service implementation
class ApiService {

  static Future<Map<String, dynamic>> getHome() async {
    // Example using http package (add 'http' to pubspec.yaml if not already)
    /*
    final token = await getStoredToken(); // your token storage logic
    final response = await http.get(
      Uri.parse('http://your-api.com/api/auth/home/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired or invalid
      throw Exception('Session expired. Please log in again.');
    } else {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }
    */

    // Simulated response for testing
    await Future.delayed(const Duration(seconds: 1));
    return {
      'message': 'Welcome Kimtai!',
      'user': {
        'username': 'Kimtai',
        'id': 1,
        // 'email': 'example@email.com',  // if you send it
      },
    };
  }

  static Future<void> logout() async {
    // Clear token from secure storage / shared preferences
    // await storage.delete(key: 'access_token');
    debugPrint("User logged out");
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getHome();
      setState(() {
        _profileData = data;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Profile loaded!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      String errorText = e.toString().replaceFirst('Exception: ', '');

      if (errorText.contains('Session expired') || errorText.contains('401')) {
        // Token expired → logout and redirect to login
        await ApiService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session expired. Please log in again."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = errorText;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorText), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Optional: auto-fetch on screen load
    // _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await ApiService.logout();
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Greeting / Header
              Text(
                _profileData != null
                    ? 'Hello, ${_profileData!['user']?['username'] ?? 'User'}!'
                    : 'Welcome Back!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),
              Text(
                _profileData != null
                    ? _profileData!['message'] ?? 'You are logged in'
                    : 'Press the button to load your profile',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),

              const SizedBox(height: 48),

              // Profile Data Card
              if (_profileData != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Profile",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Username: ${_profileData!['user']?['username'] ?? 'N/A'}",
                        ),
                        if (_profileData!['user']?['id'] != null)
                          Text("User ID: ${_profileData!['user']['id']}"),
                        // Add more fields as your backend returns them
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Fetch Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchProfile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isLoading ? 'Loading...' : 'Fetch Profile',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              // Optional: extra navigation or info
              OutlinedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/settings');
                },
                child: const Text("Settings / More"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
