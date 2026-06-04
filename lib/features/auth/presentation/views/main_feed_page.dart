import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nexoboard/features/auth/presentation/views/feed/feed_page.dart';
import 'package:nexoboard/features/auth/presentation/views/profile/profile_page.dart';
import 'package:nexoboard/features/auth/presentation/views/forum/create_forum_page.dart';
import 'package:nexoboard/features/auth/presentation/views/forum/my_forum_page.dart';

class MainFeedPage extends StatefulWidget {
  const MainFeedPage({super.key});

  @override
  State<MainFeedPage> createState() => _MainFeedPageState();
}

class _MainFeedPageState extends State<MainFeedPage> {
  int _selectedIndex = 0;

  late final List<Widget> _views = [
    FeedPage(
      forums: const [],
      onCreateForum: () => _onItemTapped(2),
    ),
    const Center(
        child: Text('Búsqueda',
            style: TextStyle(color: Colors.white, fontSize: 18))),
    const SizedBox.shrink(),
    const MyForumPage(),
    const ProfilePage(),
  ];

  void _openCreateForumModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CreateForumPage(
          onForumCreated: (newForum) {
            debugPrint('Foro creado exitosamente: ${newForum.title}');
          },
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _openCreateForumModal(); // Abre el modal desde el Navbar central
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _views,
        ),
      ),
      bottomNavigationBar: CustomFluidBottomBar(
        currentIndex: _selectedIndex == 2 ? 0 : _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CustomFluidBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFluidBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const int itemCount = 5;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double barWidth = screenWidth * 0.92;
    final double itemWidth = barWidth / itemCount;

    final List<IconData> icons = [
      CupertinoIcons.house_fill,
      CupertinoIcons.search,
      CupertinoIcons.plus,
      CupertinoIcons.group_solid,
      CupertinoIcons.person_fill,
    ];

    return Container(
      width: barWidth,
      height: 65,
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            left: currentIndex * itemWidth + (itemWidth - 48) / 2,
            top: 8.5,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedScale(
                  scale: 1.1,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icons[currentIndex],
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(itemCount, (index) {
              final isSelected = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 65,
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: isSelected ? 0.0 : 1.0,
                        child: Icon(
                          icons[index],
                          color: Colors.white38,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
