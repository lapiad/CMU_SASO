import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';

class SasoDsh extends StatefulWidget {
  const SasoDsh({super.key});

  @override
  State<SasoDsh> createState() => _SasoDshState();
}

class _SasoDshState extends State<SasoDsh> {
  final PageController pageController = PageController();
  final SideMenuController sideMenu = SideMenuController();

  @override
  void initState() {
    super.initState();
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
      body: Row(
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.auto,
              showHamburger: true,
              hoverColor: Colors.blue[100],
              selectedHoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
              selectedTitleTextStyleExpandable: const TextStyle(
                color: Colors.lightBlue,
              ),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 50,
                    maxWidth: 50,
                  ),
                  child: Image.asset('images/logos.png'),
                ),
                const Divider(indent: 8.0, endIndent: 8.0),
              ],
            ),
            items: [
              SideMenuItem(
                title: 'Dashboard',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.home),
              ),
              SideMenuItem(
                title: 'Violattion Logs',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.view_sidebar),
              ),
              SideMenuItem(
                title: 'Summary of Reports',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.pie_chart),
              ),
              SideMenuItem(
                title: 'Reffered to council',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.download),
              ),
              SideMenuItem(
                builder: (context, displayMode) {
                  return const Divider(indent: 8, endIndent: 8);
                },
              ),
              SideMenuItem(
                title: 'Settings',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.settings),
              ),
              const SideMenuItem(title: 'Exit', icon: Icon(Icons.exit_to_app)),
            ],
          ),
          const VerticalDivider(width: 0),
          Expanded(
            child: PageView(
              controller: pageController,
              children: const [
                Center(
                  child: Text('Dashboard', style: TextStyle(fontSize: 35)),
                ),
                Center(child: Text('Users', style: TextStyle(fontSize: 35))),
                Center(
                  child: Text(
                    'Expansion Item 1',
                    style: TextStyle(fontSize: 35),
                  ),
                ),
                Center(
                  child: Text(
                    'Expansion Item 2',
                    style: TextStyle(fontSize: 35),
                  ),
                ),
                Center(child: Text('Files', style: TextStyle(fontSize: 35))),
                Center(child: Text('Download', style: TextStyle(fontSize: 35))),
                SizedBox.shrink(),
                Center(child: Text('Settings', style: TextStyle(fontSize: 35))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
