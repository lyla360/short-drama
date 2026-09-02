import 'package:flutter/material.dart';
import '../data/mock_dramas.dart';

class AppState extends ChangeNotifier {
  int coins = 100;
  Set<String> favorites = {};
  Set<String> liked = {};
  Map<String, Set<int>> unlockedEpisodes = {}; // dramaId -> set of unlocked ep numbers (1-indexed)
  List<String> history = []; // dramaIds in order
  int currentTab = 0; // 0 home, 1 search, 2 mylist, 3 profile

  AppState() {
    // init: first 3 episodes free for all
    for (var d in mockDramas) {
      unlockedEpisodes[d.id] = {1, 2, 3};
    }
  }

  bool isFav(String id) => favorites.contains(id);
  bool isLiked(String id) => liked.contains(id);
  bool isUnlocked(String dramaId, int ep) => unlockedEpisodes[dramaId]?.contains(ep) ?? false;

  void toggleFav(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    notifyListeners();
  }

  void toggleLike(String id) {
    if (liked.contains(id)) {
      liked.remove(id);
    } else {
      liked.add(id);
    }
    notifyListeners();
  }

  void addHistory(String id) {
    history.remove(id);
    history.insert(0, id);
    if (history.length > 20) history = history.sublist(0, 20);
    notifyListeners();
  }

  bool unlockEpisode(String dramaId, int ep, {int cost = 10}) {
    if (isUnlocked(dramaId, ep)) return true;
    if (coins < cost) return false;
    coins -= cost;
    unlockedEpisodes.putIfAbsent(dramaId, () => {1, 2, 3});
    unlockedEpisodes[dramaId]!.add(ep);
    notifyListeners();
    return true;
  }

  void addCoins(int n) {
    coins += n;
    notifyListeners();
  }

  void setTab(int i) {
    currentTab = i;
    notifyListeners();
  }

  List<Drama> get favoriteDramas =>
      mockDramas.where((d) => favorites.contains(d.id)).toList();
  List<Drama> get historyDramas =>
      history.map((id) => mockDramas.firstWhere((d) => d.id == id)).toList();
}
