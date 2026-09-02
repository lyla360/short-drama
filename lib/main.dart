import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'data/mock_dramas.dart';
import 'providers/app_state.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const ShortDramaApp()));
}

class ShortDramaApp extends StatelessWidget {
  const ShortDramaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Short Drama',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pages = [
      const HomeFeedScreen(),
      const SearchScreen(),
      const MyListScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: state.currentTab, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF14141F),
          border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.gold.withOpacity(0.18),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.inter(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600);
              }
              return GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.gold);
              }
              return const IconThemeData(color: AppColors.textMuted);
            }),
          ),
          child: NavigationBar(
            height: 72,
            selectedIndex: state.currentTab,
            onDestinationSelected: (i) => context.read<AppState>().setTab(i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'My List'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- HOME FEED ----------------
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  String tab = 'For You';
  late PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  List<Drama> get filtered {
    if (tab == 'Trending') return mockDramas.where((d) => d.isTrending).toList();
    if (tab == 'For You') return mockDramas;
    return mockDramas;
  }

  @override
  Widget build(BuildContext context) {
    final list = filtered;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: list.length,
            onPageChanged: (i) {
              setState(() => currentPage = i);
              context.read<AppState>().addHistory(list[i].id);
            },
            itemBuilder: (context, idx) {
              final drama = list[idx];
              return DramaFeedCard(drama: drama, isActive: idx == currentPage);
            },
          ),
          // Top bar: logo + tabs + coins
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF59E0B)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 18),
                          const SizedBox(width: 4),
                          Text('SHORT', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 12)),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Text('Drama', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18)),
                      const Spacer(),
                      Consumer<AppState>(builder: (_, s, __) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.monetization_on, color: AppColors.gold, size: 16),
                            const SizedBox(width: 4),
                            Text('${s.coins}', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                s.addCoins(50);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+50 coins added!', style: GoogleFonts.inter()), backgroundColor: AppColors.card, duration: const Duration(seconds: 1)));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                                child: const Icon(Icons.add, size: 12, color: Colors.black),
                              ),
                            )
                          ]),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Tabs For You / Trending
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['For You', 'Trending'].map((t) {
                      final sel = tab == t;
                      return GestureDetector(
                        onTap: () => setState(() => tab = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(t, style: GoogleFonts.inter(color: sel ? Colors.black : Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Page indicator dots on right
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(list.length, (i) {
                  final active = i == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    width: active ? 4 : 3,
                    height: active ? 18 : 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.gold : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DramaFeedCard extends StatefulWidget {
  final Drama drama;
  final bool isActive;
  const DramaFeedCard({super.key, required this.drama, required this.isActive});
  @override
  State<DramaFeedCard> createState() => _DramaFeedCardState();
}

class _DramaFeedCardState extends State<DramaFeedCard> {
  bool playing = true;
  double progress = 0.35;

  @override
  Widget build(BuildContext context) {
    final d = widget.drama;
    return GestureDetector(
      onTap: () => setState(() => playing = !playing),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient cover = video placeholder
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: d.gradient,
              ),
            ),
          ),
          // dark overlay gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x990A0A12), Color(0xFF0A0A12)],
                stops: [0.4, 0.75, 1],
              ),
            ),
          ),
          // play/pause center
          Center(
            child: AnimatedOpacity(
              opacity: playing ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42),
              ),
            ),
          ),
          // episode badge top-center below tabs spacer
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.movie_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text('EP 1 / ${d.episodes}', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('${d.rating} ★', style: GoogleFonts.inter(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          // Bottom info + right actions
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          children: d.tags.map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                                ),
                                child: Text(t, style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                              )).toList(),
                        ),
                        const SizedBox(height: 10),
                        Text(d.title, style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
                        const SizedBox(height: 6),
                        Text(d.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.82), fontSize: 13, height: 1.4)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(drama: d)));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF59E0B)]),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                child: Row(children: [
                                  const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                                  const SizedBox(width: 2),
                                  Text('Play', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14)),
                                ]),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Consumer<AppState>(builder: (_, s, __) {
                              final fav = s.isFav(d.id);
                              return GestureDetector(
                                onTap: () => s.toggleFav(d.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: fav ? AppColors.rose : Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: fav ? AppColors.rose : Colors.white.withOpacity(0.16)),
                                  ),
                                  child: Row(children: [
                                    Icon(fav ? Icons.bookmark : Icons.bookmark_border, color: Colors.white, size: 18),
                                    const SizedBox(width: 6),
                                    Text(fav ? 'Saved' : 'Add to List', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                  ]),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: Colors.white.withOpacity(0.18),
                            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('02:14 / 06:20', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
                            Text('${(progress * 100).toInt()}%', style: GoogleFonts.inter(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Right vertical actions
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ActionButton(
                        icon: Icons.favorite,
                        label: '12.5K',
                        isActive: context.watch<AppState>().isLiked(d.id),
                        activeColor: AppColors.rose,
                        onTap: () => context.read<AppState>().toggleLike(d.id),
                      ),
                      const SizedBox(height: 18),
                      _ActionButton(icon: Icons.chat_bubble, label: '892', onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comments — Coming soon', style: GoogleFonts.inter()), backgroundColor: AppColors.card, duration: const Duration(seconds: 1)));
                      }),
                      const SizedBox(height: 18),
                      _ActionButton(icon: Icons.share_rounded, label: 'Share', onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link copied — share your drama!', style: GoogleFonts.inter()), backgroundColor: AppColors.card, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 1)));
                      }),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(drama: d))),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gold.withOpacity(0.7), width: 2),
                            gradient: LinearGradient(colors: d.gradient),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8)],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.menu, color: Colors.white, size: 18),
                              Positioned(bottom: 4, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(8)), child: Text('${d.episodes} EP', style: GoogleFonts.inter(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color activeColor;
  const _ActionButton({required this.icon, required this.label, required this.onTap, this.isActive = false, this.activeColor = AppColors.rose});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.white.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? activeColor : Colors.white.withOpacity(0.14)),
            boxShadow: isActive ? [BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 10)] : null,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ---------------- SEARCH ----------------
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  String selectedCat = 'All';
  @override
  Widget build(BuildContext context) {
    final cats = ['All', ...categories];
    final filtered = mockDramas.where((d) {
      final q = query.toLowerCase();
      final matchQ = q.isEmpty || d.title.toLowerCase().contains(q) || d.tags.any((t) => t.toLowerCase().contains(q));
      final matchCat = selectedCat == 'All' || d.category == selectedCat || d.tags.contains(selectedCat);
      return matchQ && matchCat;
    }).toList();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.08))),
                    child: TextField(
                      onChanged: (v) => setState(() => query = v),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search Billionaire, Revenge...',
                        hintStyle: GoogleFonts.inter(color: AppColors.textDim, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textDim),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.tune, color: Colors.black),
                ),
              ]),
            ),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = cats[i];
                  final sel = c == selectedCat;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCat = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.gold : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? AppColors.gold : Colors.white.withOpacity(0.08)),
                      ),
                      child: Text(c, style: GoogleFonts.inter(color: sel ? Colors.black : Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text('No dramas found', style: GoogleFonts.inter(color: AppColors.textMuted)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _PosterCard(drama: filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  final Drama drama;
  const _PosterCard({required this.drama});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(drama: drama))),
      child: Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: drama.gradient),
              ),
              child: Stack(children: [
                Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.12))), child: Row(children: [const Icon(Icons.star, color: AppColors.gold, size: 12), const SizedBox(width: 3), Text('${drama.rating}', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))]))),
                if (drama.isTrending)
                  Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.rose, borderRadius: BorderRadius.circular(20)), child: Text('HOT', style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))),
                Center(child: Icon(Icons.play_circle_outline, color: Colors.white.withOpacity(0.92), size: 44)),
                Positioned(bottom: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(8)), child: Text('${drama.episodes} EP', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)))),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(drama.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 4),
              Text(drama.tags.take(2).join(' • '), style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.visibility_outlined, color: AppColors.textDim, size: 12),
                const SizedBox(width: 4),
                Text('${drama.views}K views', style: GoogleFonts.inter(color: AppColors.textDim, fontSize: 11)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ---------------- MY LIST ----------------
class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final favs = context.watch<AppState>().favoriteDramas;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              Text('My List', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gold.withOpacity(0.35))), child: Text('${favs.length} titles', style: GoogleFonts.inter(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700))),
              const Spacer(),
              if (favs.isNotEmpty)
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sort & Filter — soon', style: GoogleFonts.inter()), backgroundColor: AppColors.card)),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.08))), child: const Icon(Icons.swap_vert, color: Colors.white70, size: 18)),
                ),
            ]),
          ),
          if (favs.isEmpty)
            Expanded(
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 88, height: 88, decoration: BoxDecoration(color: AppColors.card, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.08))), child: const Icon(Icons.bookmark_border, color: AppColors.textDim, size: 36)),
                  const SizedBox(height: 16),
                  Text('Your list is empty', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Tap bookmark on any drama to save it', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => context.read<AppState>().setTab(0),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF59E0B)]), borderRadius: BorderRadius.circular(24)), child: Text('Discover Dramas', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700))),
                  ),
                ]),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: favs.length,
                itemBuilder: (_, i) {
                  final d = favs[i];
                  return Stack(children: [
                    _PosterCard(drama: d),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () => context.read<AppState>().toggleFav(d.id),
                        child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.rose, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)]), child: const Icon(Icons.close, color: Colors.white, size: 14)),
                      ),
                    ),
                  ]);
                },
              ),
            ),
        ]),
      ),
    );
  }
}

// ---------------- PROFILE ----------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final history = state.historyDramas;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // header
            Row(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF59E0B)]),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.black, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Drama Lover', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 2),
                  Text('ID: 8842 9921 • VIP Member', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF59E0B)]), borderRadius: BorderRadius.circular(20)), child: Text('VIP 2  •  Premium', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11))),
                ]),
              ),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.08))), child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20)),
            ]),
            const SizedBox(height: 18),
            // coins card glassmorphism 2xl
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF1E1E2E), const Color(0xFF252538)]),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.18), shape: BoxShape.circle, border: Border.all(color: AppColors.gold.withOpacity(0.35))), child: const Icon(Icons.monetization_on, color: AppColors.gold, size: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('My Coins', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Text('${state.coins}', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 22)),
                      const SizedBox(width: 6),
                      const Icon(Icons.monetization_on, color: AppColors.gold, size: 18),
                    ]),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    state.addCoins(100);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('100 coins added!', style: GoogleFonts.inter()), backgroundColor: AppColors.card));
                  },
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF59E0B)]), borderRadius: BorderRadius.circular(20)), child: Text('+ Get Coins', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13))),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.rose.withOpacity(0.18))),
              child: Row(children: [
                const Icon(Icons.card_giftcard, color: AppColors.rose, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Daily check-in: get 10 free coins every day!', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))),
                Text('Claim', style: GoogleFonts.inter(color: AppColors.rose, fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 20),
            if (history.isNotEmpty) ...[
              Text('Watch History', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final d = history[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(drama: d))),
                      child: Column(children: [
                        Container(width: 78, height: 78, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: d.gradient), border: Border.all(color: Colors.white.withOpacity(0.08))), child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 26)),
                        const SizedBox(height: 6),
                        SizedBox(width: 78, child: Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500))),
                      ]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF2D1B2D)]),
                border: Border.all(color: AppColors.gold.withOpacity(0.18)),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)), child: Text('LIMITED', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 10))),
                    const SizedBox(height: 8),
                    Text('Unlock all episodes', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Get unlimited access + ad-free', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)), child: Text('Upgrade', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700))),
              ]),
            ),
            const SizedBox(height: 20),
            _settingsTile(Icons.history, 'My Downloads', '3 episodes offline'),
            _settingsTile(Icons.favorite_border, 'Favorites', '${state.favorites.length} titles'),
            _settingsTile(Icons.language, 'Language', 'English'),
            _settingsTile(Icons.help_outline, 'Help & Feedback', ''),
            _settingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', ''),
            _settingsTile(Icons.logout, 'Log Out', '', isDestructive: true),
            const SizedBox(height: 12),
            Center(child: Text('Short Drama v1.0.0 • Made with ♥', style: GoogleFonts.inter(color: AppColors.textDim, fontSize: 11))),
          ]),
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: isDestructive ? AppColors.rose.withOpacity(0.12) : Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: isDestructive ? AppColors.rose : Colors.white70, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(color: isDestructive ? AppColors.rose : Colors.white, fontWeight: FontWeight.w600, fontSize: 14)), if (subtitle.isNotEmpty) Text(subtitle, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12))])),
        const Icon(Icons.chevron_right, color: AppColors.textDim, size: 20),
      ]),
    );
  }
}

// ---------------- PLAYER DETAIL ----------------
class PlayerScreen extends StatefulWidget {
  final Drama drama;
  const PlayerScreen({super.key, required this.drama});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int selectedEp = 1;
  bool isPlaying = true;

  @override
  Widget build(BuildContext context) {
    final d = widget.drama;
    final state = context.watch<AppState>();
    final unlocked = state.isUnlocked(d.id, selectedEp);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: AppColors.bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.12))), child: const Icon(Icons.arrow_back, color: Colors.white, size: 20)),
            ),
            actions: [
              Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.12))), child: const Icon(Icons.share_outlined, color: Colors.white, size: 18)),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: d.gradient))),
                Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xAA0A0A12), Color(0xFF0A0A12)]))),
                // video placeholder
                Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () => setState(() => isPlaying = !isPlaying),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(color: unlocked ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.55), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))),
                        child: Icon(unlocked ? (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded) : Icons.lock_rounded, color: Colors.white, size: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!unlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.lock, color: Colors.black, size: 14),
                          const SizedBox(width: 6),
                          Text('Unlock for 10 coins', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)),
                        ]),
                      )
                    else
                      Text(isPlaying ? 'Playing  EP $selectedEp' : 'Paused  EP $selectedEp', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('EP $selectedEp / ${d.episodes}  •  ${d.rating} ★', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                // top episodes badge
                SafeArea(child: Padding(padding: const EdgeInsets.only(top: 56), child: Align(alignment: Alignment.topCenter, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.12))), child: Text('DRAMA • ${d.episodes} EPISODES', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.1)))))),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.gold.withOpacity(0.3))), child: Text(d.category.toUpperCase(), style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.8))),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Text('BINGE-WORTHY', style: GoogleFonts.inter(color: AppColors.rose, fontWeight: FontWeight.w700, fontSize: 10))),
                  const Spacer(),
                  Consumer<AppState>(builder: (_, s, __) {
                    final fav = s.isFav(d.id);
                    return GestureDetector(
                      onTap: () => s.toggleFav(d.id),
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: fav ? AppColors.rose : AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: fav ? AppColors.rose : Colors.white.withOpacity(0.08))), child: Row(children: [Icon(fav ? Icons.bookmark : Icons.bookmark_border, color: Colors.white, size: 16), const SizedBox(width: 6), Text(fav ? 'Saved' : 'Save', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))])),
                    );
                  }),
                ]),
                const SizedBox(height: 12),
                Text(d.title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, height: 1.2)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, color: AppColors.gold, size: 16),
                  const SizedBox(width: 4),
                  Text('${d.rating}', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 6),
                  Text('• ${d.views}K views', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(width: 6),
                  Text('• ${d.episodes} episodes', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                Text(d.description, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.78), fontSize: 13, height: 1.5)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: d.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))), child: Text('# $t', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)))).toList()),
                const SizedBox(height: 20),
                Row(children: [
                  Text('Episodes', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(width: 8),
                  Text('${d.episodes} episodes', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))), child: Row(children: [const Icon(Icons.monetization_on, color: AppColors.gold, size: 14), const SizedBox(width: 4), Text('${state.coins} coins', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12))])),
                ]),
                const SizedBox(height: 4),
                Text('First 3 episodes free • 10 coins per episode after', style: GoogleFonts.inter(color: AppColors.textDim, fontSize: 11)),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.05),
                  itemCount: d.episodes,
                  itemBuilder: (_, idx) {
                    final ep = idx + 1;
                    final isUnlocked = state.isUnlocked(d.id, ep);
                    final isSelected = selectedEp == ep;
                    return GestureDetector(
                      onTap: () {
                        if (isUnlocked) {
                          setState(() => selectedEp = ep);
                          state.addHistory(d.id);
                        } else {
                          _showUnlockSheet(context, d, ep);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.gold : (isUnlocked ? AppColors.card : AppColors.card.withOpacity(0.55)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSelected ? AppColors.gold : (isUnlocked ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.04)), width: isSelected ? 2 : 1),
                        ),
                        child: Stack(alignment: Alignment.center, children: [
                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('$ep', style: GoogleFonts.inter(color: isSelected ? Colors.black : (isUnlocked ? Colors.white : Colors.white38), fontWeight: FontWeight.w800, fontSize: 16)),
                            if (!isUnlocked) const SizedBox(height: 2),
                            if (!isUnlocked) const Icon(Icons.lock, color: Colors.white38, size: 12),
                          ]),
                          if (isUnlocked && ep <= 3)
                            Positioned(top: 4, right: 4, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)), child: Text('FREE', style: GoogleFonts.inter(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800)))),
                          if (!isUnlocked)
                            Positioned(top: 4, right: 4, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.9), shape: BoxShape.circle), child: Center(child: Text('10', style: GoogleFonts.inter(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w800))))),
                        ]),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // bottom action bar
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!state.isUnlocked(d.id, selectedEp)) {
                          _showUnlockSheet(context, d, selectedEp);
                          return;
                        }
                        setState(() => isPlaying = true);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Now playing EP $selectedEp', style: GoogleFonts.inter()), backgroundColor: AppColors.card, duration: const Duration(seconds: 1)));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: state.isUnlocked(d.id, selectedEp) ? [AppColors.gold, const Color(0xFFF59E0B)] : [AppColors.card, AppColors.card]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: state.isUnlocked(d.id, selectedEp) ? Colors.transparent : Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(state.isUnlocked(d.id, selectedEp) ? Icons.play_arrow_rounded : Icons.lock_rounded, color: state.isUnlocked(d.id, selectedEp) ? Colors.black : Colors.white38, size: 20),
                          const SizedBox(width: 6),
                          Text(state.isUnlocked(d.id, selectedEp) ? 'Play EP $selectedEp' : 'Locked  •  10 coins', style: GoogleFonts.inter(color: state.isUnlocked(d.id, selectedEp) ? Colors.black : Colors.white38, fontWeight: FontWeight.w700, fontSize: 14)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link copied!', style: GoogleFonts.inter()), backgroundColor: AppColors.card, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 1)));
                    },
                    child: Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.08))), child: const Icon(Icons.share_rounded, color: Colors.white70, size: 20)),
                  ),
                  const SizedBox(width: 10),
                  Consumer<AppState>(builder: (_, s, __) {
                    final liked = s.isLiked(d.id);
                    return GestureDetector(
                      onTap: () => s.toggleLike(d.id),
                      child: Container(width: 52, height: 52, decoration: BoxDecoration(color: liked ? AppColors.rose : AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: liked ? AppColors.rose : Colors.white.withOpacity(0.08))), child: Icon(liked ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 20)),
                    );
                  }),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnlockSheet(BuildContext context, Drama d, int ep) {
    final state = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: AppColors.gold.withOpacity(0.3))), child: const Icon(Icons.lock_rounded, color: AppColors.gold, size: 28)),
          const SizedBox(height: 12),
          Text('Unlock Episode $ep', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          Text('Watch the next episode for 10 coins', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.08))),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: d.gradient)), child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)), Text('Episode $ep  •  6:20', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gold.withOpacity(0.3))), child: Row(children: [const Icon(Icons.monetization_on, color: AppColors.gold, size: 16), const SizedBox(width: 4), Text('10', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w800))])),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Text('Your coins: ${state.coins}', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13))),
            Text(state.coins >= 10 ? 'Enough coins' : 'Not enough', style: GoogleFonts.inter(color: state.coins >= 10 ? const Color(0xFF10B981) : AppColors.rose, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16)), child: Center(child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)))))),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final ok = state.unlockEpisode(d.id, ep);
                  Navigator.pop(context);
                  if (ok) {
                    setState(() => selectedEp = ep);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Episode $ep unlocked! -10 coins', style: GoogleFonts.inter()), backgroundColor: const Color(0xFF10B981), duration: const Duration(seconds: 1)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not enough coins! Get more coins.', style: GoogleFonts.inter()), backgroundColor: AppColors.rose, duration: const Duration(seconds: 1)));
                  }
                },
                child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(gradient: LinearGradient(colors: state.coins >= 10 ? [AppColors.gold, const Color(0xFFF59E0B)] : [Colors.white10, Colors.white10]), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(state.coins >= 10 ? 'Unlock for 10' : 'Get Coins', style: GoogleFonts.inter(color: state.coins >= 10 ? Colors.black : Colors.white54, fontWeight: FontWeight.w700)))),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
