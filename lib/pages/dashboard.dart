import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final PageController pageController = PageController();
  final SideMenuController sidemenu = SideMenuController();

  @override
  void initState() {
    super.initState();
    sidemenu.addListener((index) {
      pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(""), centerTitle: true),
      body: Row(
        children: [
          SideMenu(
            controller: sidemenu,
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

            items: [
              SideMenuItem(
                title: 'Dashboard',
                onTap: (index, _) => sidemenu.changePage(index),
                icon: const Icon(Icons.home),
              ),
              SideMenuItem(
                title: 'Violation Logs',
                onTap: (index, _) => sidemenu.changePage(index),
                icon: const Icon(Icons.view_sidebar),
              ),
              SideMenuItem(
                title: 'Summary of Reports',
                onTap: (index, _) => sidemenu.changePage(index),
                icon: const Icon(Icons.pie_chart),
              ),
              SideMenuItem(
                title: 'Referred to Council',
                onTap: (index, _) => sidemenu.changePage(index),
                icon: const Icon(Icons.bookmark),
              ),
              SideMenuItem(
                builder: (context, displayMode) {
                  return const Divider(indent: 8, endIndent: 8);
                },
              ),
            ],
          ),
          const VerticalDivider(width: 0),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                Center(
                  child: Text('Dashboard', style: TextStyle(fontSize: 30)),
                ),
                Center(
                  child: Text('Violation Logs', style: TextStyle(fontSize: 30)),
                ),
                Center(
                  child: Text(
                    'Summary of Reports',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Center(
                  child: Text(
                    'Referred to Council',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
