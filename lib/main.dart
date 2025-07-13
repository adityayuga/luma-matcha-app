import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const LumaMatchaApp());
}

class MenuItem {
  final String title;
  final Icon icon;
  final MenuItemData? data;
  MenuItem({
    required this.title, 
    required this.icon, 
    required this.data
  });
}

class MenuItemData {
  final String menuType;
  final String url;
  MenuItemData({required this.menuType, required this.url});
}

const constMenuTypeLoadImage = 'image';
const constMenuTypeRedirectExternalLink = 'redirect-external-link';
const constMenuTypeOpenMap = 'open-map';

const constBackgroundColor = Color.fromRGBO(254, 255, 250, 1);
const constPrimaryColor = Color.fromRGBO(69, 99, 48, 1); // Green color

// GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MenuPage(),
    ),
    GoRoute(
      path: '/image/:title',
      name: 'image',
      builder: (context, state) {
        final title = state.pathParameters['title'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        return ImageViewerPage(
          menuItem: extra?['menuItem'] as MenuItem?,
          title: title,
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: constBackgroundColor,
    appBar: AppBar(
      title: const Text('Error'),
      backgroundColor: constPrimaryColor,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Page not found'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);

class LumaMatchaApp extends StatelessWidget {
  const LumaMatchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luma Matcha Jogja',
      theme: ThemeData(primarySwatch: Colors.green),
      routerConfig: _router,
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  List<MenuItem> get items => [
    MenuItem(
      title: 'Menu',
      icon: Icon(Icons.menu_book, color: Colors.white),
      data: MenuItemData(
        menuType: constMenuTypeLoadImage,
        url: 'assets/menu.png', // Replace with actual image path
      ),
    ),
    MenuItem(
      title: 'GrabFood',
      icon: Icon(Icons.food_bank, color: Colors.white),
      data: MenuItemData(
        menuType: constMenuTypeRedirectExternalLink,
        url: 'https://r.grab.com/g/6-20250713_164813_C10EF76AD5A04A29861AE106E1DAD9A2_MEXMPS-6-C7AFJCKVT2JYGT', // Replace with actual coordinates or address
      ),
    ),
    MenuItem(
      title: 'WhatsApp',
      icon: Icon(Icons.chat, color: Colors.white),
      data: MenuItemData(
        menuType: constMenuTypeRedirectExternalLink,
        url: 'https://api.whatsapp.com/send?phone=6285946404657', // Replace with actual WhatsApp number
      ),
    ),
    MenuItem(
      title: 'Instagram',
      icon: Icon(Icons.camera_alt, color: Colors.white),
      data: MenuItemData(
        menuType: constMenuTypeRedirectExternalLink,
        url: 'https://www.instagram.com/luma.matcha/',
      ),
    ),
    MenuItem(title: 'Tiktok', icon: Icon(Icons.tiktok, color: Colors.white), data: MenuItemData(
        menuType: constMenuTypeRedirectExternalLink,
        url: 'https://www.tiktok.com/@luma.matcha',
      )),
    MenuItem(
      title: 'Location',
      icon: Icon(Icons.location_on, color: Colors.white),
      data: MenuItemData(
        menuType: constMenuTypeOpenMap,
        url: 'https://g.co/kgs/dS8aNC7', // Replace with actual coordinates or address
      ),
    ),
    // Add more links here if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constBackgroundColor,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: Image.asset('assets/logo.png').image,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Luma Matcha Jogja',
            style: GoogleFonts.crimsonText(
              color: constPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          StyledTextContainer(text: 'Your #MatchaToGo at 𝑌𝑜𝑔𝑦𝑎𝑘𝑎𝑟𝑡𝑎'),
          StyledTextContainer(text: '𝙊𝙧𝙙𝙚𝙧 𝙗𝙮 𝘿𝙈/𝙒𝙝𝙖𝙩𝙨𝙖𝙥𝙥 𝙖𝙩𝙖𝙪 𝙂𝙧𝙖𝙗𝙛𝙤𝙤𝙙'),
          StyledTextContainer(text: '• Selasa - Sabtu 10.00-22.00'),
          StyledTextContainer(text: '• Grab buka pukul 12.00-22.00'),
          SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return Material(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(32),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () async {
                      if (item.data?.menuType == constMenuTypeRedirectExternalLink ||
                          item.data?.menuType == constMenuTypeOpenMap) {
                        final url = item.data!.url;
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      } else if (item.data?.menuType == constMenuTypeLoadImage) {
                        // Navigate to image viewer using GoRouter with named route
                        context.goNamed(
                          'image',
                          pathParameters: {'title': item.title.toLowerCase()},
                          extra: {'menuItem': item},
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 24,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          item.icon,
                          SizedBox(width: 8),
                          Text(
                            item.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class ImageViewerPage extends StatelessWidget {
  final MenuItem? menuItem;
  final String? title;
  
  const ImageViewerPage({super.key, this.menuItem, this.title});

  @override
  Widget build(BuildContext context) {
    if (menuItem == null) {
      return Scaffold(
        backgroundColor: constBackgroundColor,
        appBar: AppBar(
          title: Text(title ?? 'Error'),
          backgroundColor: constPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('No image selected')),
      );
    }

    return Scaffold(
      body: Center(
        child: Image.asset(
          menuItem!.data?.url ?? 'assets/logo.png',
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Could not load image'),
                const SizedBox(height: 8),
                Text(menuItem!.data?.url ?? 'No URL'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class StyledTextContainer extends StatelessWidget {
  final String text;
  
  const StyledTextContainer({super.key, required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: constPrimaryColor,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
