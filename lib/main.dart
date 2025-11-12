// lib/main.dart
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const TuneStreamAesthetic());

class TuneStreamAesthetic extends StatelessWidget {
  const TuneStreamAesthetic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuneStream — Aesthetic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0D),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7F5AF0),
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 14, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 13, color: Colors.white60),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}

/* ------------------------------
   Demo data (small playlist)
   Replace URLs with your own later.
   ------------------------------ */
final List<Map<String, String>> demoSongs = [
  {
    'id': '1',
    'title': 'Night Drive',
    'artist': 'Lumen',
    'image':
        'https://images.unsplash.com/photo-1485579149621-3123dd979885?w=1200&q=80',
  },
  {
    'id': '2',
    'title': 'Soft Neon',
    'artist': 'ECHO',
    'image':
        'https://images.unsplash.com/photo-1535223289827-42f1e9919769?w=1200&q=80',
  },
  {
    'id': '3',
    'title': 'Afterglow',
    'artist': 'Sora',
    'image':
        'https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2?w=1200&q=80',
  },
];

/* ------------------------------
   Main Shell with navigation
   ------------------------------ */
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  int _playingIndex = -1; // -1 means nothing playing
  bool _isPlaying = false;

  // simple animation controller for subtle motion
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _playTap(int i) {
    setState(() {
      if (_playingIndex == i) {
        _isPlaying = !_isPlaying;
      } else {
        _playingIndex = i;
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onPlay: _playTap, playingIndex: _playingIndex),
      SearchPage(onPlay: _playTap, playingIndex: _playingIndex),
      LibraryPage(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ),
        title: const Text('TuneStream', style: TextStyle(letterSpacing: 0.2)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: Colors.white10,
              child: const Icon(Icons.person, color: Colors.white70),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // gradient background + soft glowing design blobs
          const _BackgroundDecor(),
          // main pages with animated switch
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: pages[_index],
            ),
          ),
          // bottom-aligned mini player
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // small draggable handle
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // progress skeleton (mock)
                  if (_playingIndex >= 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: LinearProgressIndicator(
                        value: _isPlaying ? 0.35 : 0.0,
                        backgroundColor: Colors.white.withOpacity(0.03),
                        color: const Color(0xFF7F5AF0),
                        minHeight: 3,
                      ),
                    ),
                  const SizedBox(height: 10),
                  // glass mini player
                  _GlassMiniPlayer(
                    isPlaying: _isPlaying,
                    onPlayPause: () {
                      if (_playingIndex >= 0) {
                        setState(() => _isPlaying = !_isPlaying);
                      } else {
                        // nothing playing -> start first
                        setState(() {
                          _playingIndex = 0;
                          _isPlaying = true;
                        });
                      }
                    },
                    onTapExpand: () {
                      if (_playingIndex >= 0) {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) {
                              return PlayerFullScreen(
                                index: _playingIndex,
                                isPlaying: _isPlaying,
                                onToggle: () =>
                                    setState(() => _isPlaying = !_isPlaying),
                              );
                            },
                          ),
                        );
                      }
                    },
                    title: _playingIndex >= 0
                        ? demoSongs[_playingIndex]['title']!
                        : 'Nothing playing',
                    subtitle: _playingIndex >= 0
                        ? demoSongs[_playingIndex]['artist']!
                        : '',
                    imageUrl: _playingIndex >= 0
                        ? demoSongs[_playingIndex]['image']!
                        : '',
                    pulse: _pulseController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: Colors.white.withOpacity(0.03),
            selectedItemColor: const Color(0xFF7F5AF0),
            unselectedItemColor: Colors.white60,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music_outlined),
                label: 'Library',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------
   Background decorative layer
   ------------------------------ */
class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    // layered gradient + soft neon blobs + subtle noise via blur
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.9, -0.8),
          end: Alignment(0.9, 0.9),
          colors: [Color(0xFF07070B), Color(0xFF090A10), Color(0xFF101018)],
        ),
      ),
      child: Stack(
        children: [
          // top-left purple glow
          Positioned(
            left: -80,
            top: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7F5AF0).withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // bottom-right teal glow
          Positioned(
            right: -100,
            bottom: -140,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2CB67D).withOpacity(0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // soft blurred vignette overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------
    Home page (aesthetic cards)
   ------------------------------ */
class HomePage extends StatelessWidget {
  final void Function(int) onPlay;
  final int playingIndex;
  const HomePage({required this.onPlay, required this.playingIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('home'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Featured',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.86),
              itemCount: demoSongs.length,
              itemBuilder: (context, i) {
                final item = demoSongs[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: _GlassFeaturedCard(
                    title: item['title']!,
                    subtitle: item['artist']!,
                    imageUrl: item['image']!,
                    onPlay: () => onPlay(i),
                    isPlaying: playingIndex == i,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          _sectionTitle('Recommended'),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              scrollDirection: Axis.horizontal,
              itemCount: demoSongs.length,
              itemBuilder: (context, i) {
                final s = demoSongs[i];
                return _SongTile(
                  title: s['title']!,
                  subtitle: s['artist']!,
                  imageUrl: s['image']!,
                  onTap: () => onPlay(i),
                  isPlaying: playingIndex == i,
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          _sectionTitle('Playlists'),
          const SizedBox(height: 12),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 3.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: List.generate(4, (i) => _PlaylistChip(index: i)),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

Widget _sectionTitle(String text) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    TextButton(onPressed: () {}, child: const Text('View all')),
  ],
);

/* ------------------------------
   Reusable UI components
   ------------------------------ */

class _GlassFeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onPlay;
  final bool isPlaying;
  const _GlassFeaturedCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onPlay,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          // background glass
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onPlay,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        label: Text(isPlaying ? 'Playing' : 'Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7F5AF0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // album art
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Hero(
                    tag: title,
                    child: Image.network(
                      imageUrl,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // soft violet glow border
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;
  final bool isPlaying;
  const _SongTile({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // overlay gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // small play badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isPlaying ? Icons.equalizer : Icons.play_arrow,
                          size: 18,
                          color: isPlaying
                              ? const Color(0xFF2CB67D)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistChip extends StatelessWidget {
  final int index;
  const _PlaylistChip({required this.index});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.queue_music),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text('Vibe Mix #${index + 1}')),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------
   Glass Mini Player
   ------------------------------ */
class _GlassMiniPlayer extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onTapExpand;
  final String title;
  final String subtitle;
  final String imageUrl;
  final AnimationController pulse;

  const _GlassMiniPlayer({
    required this.isPlaying,
    required this.onPlayPause,
    required this.onTapExpand,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 360),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F5AF0).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // animated pulse album art
            ScaleTransition(
              scale: Tween(begin: 0.98, end: 1.03).animate(
                CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Colors.white12,
                        child: const Icon(Icons.music_note),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onPlayPause,
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                size: 36,
                color: const Color(0xFF7F5AF0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------
   Player full-screen (expanded)
   ------------------------------ */
class PlayerFullScreen extends StatelessWidget {
  final int index;
  final bool isPlaying;
  final VoidCallback onToggle;
  const PlayerFullScreen({
    required this.index,
    required this.isPlaying,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final song = demoSongs[index];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            children: [
              Hero(
                tag: song['title']!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    song['image']!,
                    width: 320,
                    height: 320,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                song['title']!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                song['artist']!,
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 18),
              // progress mock
              Slider(value: isPlaying ? 0.36 : 0.0, onChanged: (_) {}),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.skip_previous, size: 30),
                  ),
                  const SizedBox(width: 14),
                  FloatingActionButton(
                    onPressed: onToggle,
                    backgroundColor: const Color(0xFF7F5AF0),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.skip_next, size: 30),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------
   Search & Library simple pages
   ------------------------------ */

class SearchPage extends StatelessWidget {
  final void Function(int) onPlay;
  final int playingIndex;
  const SearchPage({
    required this.onPlay,
    required this.playingIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('search'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search songs, artists...',
                hintStyle: TextStyle(color: Colors.white54),
                icon: Icon(Icons.search, color: Colors.white60),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: List.generate(demoSongs.length, (i) {
                final s = demoSongs[i];
                return GestureDetector(
                  onTap: () => onPlay(i),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          s['image']!,
                          fit: BoxFit.cover,
                          height: 150,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s['title']!,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        s['artist']!,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('library'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Library',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: List.generate(
                6,
                (i) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: Colors.white10,
                      child: const Icon(Icons.album),
                    ),
                  ),
                  title: Text('Saved Mix #${i + 1}'),
                  subtitle: const Text(
                    'Created playlist',
                    style: TextStyle(color: Colors.white60),
                  ),
                  trailing: const Icon(Icons.more_vert),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
