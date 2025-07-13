import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(LumaMatchaApp());
}

class MenuItem {
  final String title;
  final Icon icon;
  final String route;
  final MenuItemData? data;
  MenuItem({required this.title, required this.icon, required this.route, required this.data});
}

class MenuItemData {
  final String menuType;
  final String url;
  MenuItemData({required this.menuType, required this.url});
}

const constMenuTypeLoadImage = 'image';
const constMenuTypeRedirectExternalLink = 'redirect-external-link';

const constBackgroundColor = Color.fromRGBO(254, 255, 250, 1);
const constPrimaryColor = Color.fromRGBO(69, 99, 48, 1); // Green color

class LumaMatchaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luma Matcha Jogja',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {'/': (_) => MenuPage(), '/image': (_) => ImageViewerPage()},
    );
  }
}

class MenuPage extends StatelessWidget {
  final List<MenuItem> items = [
    MenuItem(
      title: 'Menu',
      icon: Icon(Icons.menu_book, color: Colors.white),
      data: MenuItemData(
        menuType: constMenuTypeLoadImage,
        url: 'https://drive.google.com/file/d/1reRLBc3yqy4PwQiPpYibnOkyh6e0_mOR/view?usp=sharing',
      ),
      route: '/image',
    ),
    MenuItem(
      title: 'Instagram',
      icon: Icon(Icons.camera_alt, color: Colors.white),
      data: MenuItemData(
        menuType: constMenuTypeRedirectExternalLink,
        url: 'https://www.instagram.com/luma.matcha/',
      ),
      route: '/',
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
          SizedBox(height: 32),
          CircleAvatar(
            radius: 48,
            backgroundImage: Image.asset('assets/logo.png').image,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Luma Matcha Jogja',
            style: TextStyle(
              color: constPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your #MatchaToGo at 𝑌𝑜𝑔𝑦𝑎𝑘𝑎𝑟𝑡𝑎',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constPrimaryColor,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '𝙊𝙧𝙙𝙚𝙧 𝙗𝙮 𝘿𝙈/𝙒𝙝𝙖𝙩𝙨𝙖𝙥𝙥 𝙖𝙩𝙖𝙪 𝙂𝙧𝙖𝙗𝙛𝙤𝙤𝙙',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constPrimaryColor,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '• Selasa - Sabtu 10.00-22.00',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constPrimaryColor,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '• Grab buka pukul 12.00-22.00',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constPrimaryColor,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
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
                      if (item.data?.menuType == constMenuTypeRedirectExternalLink) {
                        final url = item.data!.url;
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      } else {
                        Navigator.pushNamed(context, item.route, arguments: item);
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
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    // Safe type-check and cast
    if (args is! MenuItem) {
      return Scaffold(
        backgroundColor: constBackgroundColor,
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('No image selected or wrong arguments')),
      );
    }

    final item = args as MenuItem;

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Center(child: Image.network(item.data?.url ?? 'https://via.placeholder.com/150')),
    );
  }
}
