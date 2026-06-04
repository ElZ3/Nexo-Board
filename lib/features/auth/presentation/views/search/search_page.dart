import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nexoboard/features/auth/data/forum_service.dart';
import 'package:nexoboard/features/auth/data/user_service.dart';
import 'package:nexoboard/features/auth/data/models/forum_model.dart';
import 'package:nexoboard/features/auth/presentation/views/profile/public_profile_page.dart';

enum SearchFilter { forums, mostLiked, mostDisliked, users }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ForumService _forumService = ForumService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  SearchFilter _filter = SearchFilter.forums;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isUserSearch => _filter == SearchFilter.users;

  // ─────────────────── FILTRADO DE FOROS ───────────────────
  List<ForumModel> _filterForums(List<ForumModel> forums) {
    final q = _query.trim().toLowerCase();
    List<ForumModel> result = forums;

    if (q.isNotEmpty) {
      if (q.startsWith('#')) {
        // Autocompletado por hashtag.
        final term = q.substring(1);
        result = forums
            .where((f) =>
                f.hashtag.toLowerCase().replaceFirst('#', '').contains(term))
            .toList();
      } else {
        // Por nombre de foro o hashtag.
        result = forums
            .where((f) =>
                f.title.toLowerCase().contains(q) ||
                f.hashtag.toLowerCase().contains(q))
            .toList();
      }
    }

    switch (_filter) {
      case SearchFilter.mostLiked:
        result.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case SearchFilter.mostDisliked:
        result.sort((a, b) => b.dislikes.compareTo(a.dislikes));
        break;
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  List<UserSummary> _filterUsers(List<UserSummary> users) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where((u) =>
            u.username.toLowerCase().contains(q) ||
            u.fullName.toLowerCase().contains(q))
        .toList();
  }

  // ─────────────────── BUILD ───────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            const SizedBox(height: 8),
            Expanded(
              child: _isUserSearch ? _buildUserResults() : _buildForumResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: _isUserSearch
              ? 'Buscar usuarios por nombre o @usuario...'
              : 'Buscar foros (#hashtag o nombre)...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: const Icon(LucideIcons.search, color: Colors.white38),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white38),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = [
      (SearchFilter.forums, 'Foros', LucideIcons.layoutGrid),
      (SearchFilter.mostLiked, 'Más Likeados', LucideIcons.thumbsUp),
      (SearchFilter.mostDisliked, 'Más Dislikeados', LucideIcons.thumbsDown),
      (SearchFilter.users, 'Usuarios', LucideIcons.users),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: chips.map((c) {
          final selected = _filter == c.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(
                c.$3,
                size: 16,
                color: selected ? Colors.white : Colors.white54,
              ),
              label: Text(c.$2),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              selected: selected,
              showCheckmark: false,
              backgroundColor: const Color(0xFF1A1A1A),
              selectedColor: Colors.deepPurple[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected ? Colors.deepPurple : Colors.white12,
                ),
              ),
              onSelected: (_) => setState(() => _filter = c.$1),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────── RESULTADOS DE FOROS ───────────────────
  Widget _buildForumResults() {
    return StreamBuilder<List<ForumModel>>(
      stream: _forumService.streamAllForums(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _errorState('${snapshot.error}');
        }

        final forums = _filterForums(snapshot.data ?? []);
        if (forums.isEmpty) {
          return _emptyState(
            _query.isEmpty
                ? 'No hay foros disponibles todavía.'
                : 'Sin resultados para "$_query".',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forums.length,
          itemBuilder: (context, index) => _buildForumResultTile(forums[index]),
        );
      },
    );
  }

  Widget _buildForumResultTile(ForumModel forum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfilePage(uid: forum.creatorId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: forum.coverImageUrl == null
                        ? LinearGradient(
                            colors: [Colors.purple[600]!, Colors.blue[600]!])
                        : null,
                    image: forum.coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(forum.coverImageUrl!),
                            fit: BoxFit.cover)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        forum.hashtag,
                        style: TextStyle(
                          color: Colors.deepPurple[300],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        forum.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _miniStat(LucideIcons.thumbsUp, forum.likes),
                          const SizedBox(width: 12),
                          _miniStat(LucideIcons.thumbsDown, forum.dislikes),
                          const SizedBox(width: 12),
                          _miniStat(
                              LucideIcons.messageCircle, forum.commentCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 150.ms);
  }

  // ─────────────────── RESULTADOS DE USUARIOS ───────────────────
  Widget _buildUserResults() {
    return StreamBuilder<List<UserSummary>>(
      stream: _userService.streamAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _errorState('${snapshot.error}');
        }

        final users = _filterUsers(snapshot.data ?? []);
        if (users.isEmpty) {
          return _emptyState(
            _query.isEmpty
                ? 'Escribe para buscar usuarios.'
                : 'Sin usuarios para "$_query".',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) => _buildUserResultTile(users[index]),
        );
      },
    );
  }

  Widget _buildUserResultTile(UserSummary user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfilePage(
                  uid: user.uid,
                  username: user.username,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2A2A2A),
                  backgroundImage: user.profileImageUrl != ''
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  child: user.profileImageUrl == ''
                      ? const Icon(Icons.person, color: Colors.white54)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.fullName,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _miniStat(LucideIcons.thumbsUp, user.accumulatedLikes),
                    const SizedBox(width: 6),
                    const Icon(LucideIcons.chevronRight,
                        color: Colors.white24, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 150.ms);
  }

  // ─────────────────── HELPERS ───────────────────
  Widget _miniStat(IconData icon, int value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 3),
        Text('$value',
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.searchX, color: Colors.grey[700], size: 56),
          const SizedBox(height: 14),
          Text(message,
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Text('Error: $error',
          style: const TextStyle(color: Colors.redAccent)),
    );
  }
}
