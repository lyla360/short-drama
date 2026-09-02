import 'package:flutter/material.dart';

class Drama {
  final String id;
  final String title;
  final String description;
  final List<Color> gradient;
  final int episodes;
  final double rating;
  final List<String> tags;
  final String category; // For You / Trending / Romance
  final int views; // in K
  final bool isTrending;
  Drama({
    required this.id,
    required this.title,
    required this.description,
    required this.gradient,
    required this.episodes,
    required this.rating,
    required this.tags,
    required this.category,
    required this.views,
    this.isTrending = false,
  });
}

final mockDramas = <Drama>[
  Drama(
    id: '1',
    title: 'The Billionaire\'s Secret',
    description: 'A waitress discovers her boss is a hidden billionaire who will change her fate forever.',
    gradient: [const Color(0xFF7C3AED), const Color(0xFFEAB308)],
    episodes: 16,
    rating: 4.8,
    tags: ['Billionaire', 'Romance', 'Drama'],
    category: 'For You',
    views: 3420,
    isTrending: true,
  ),
  Drama(
    id: '2',
    title: 'Revenge of the Queen',
    description: 'Betrayed by her family, she returns 5 years later as a powerful CEO for vengeance.',
    gradient: [const Color(0xFFF43F5E), const Color(0xFF7C3AED)],
    episodes: 20,
    rating: 4.9,
    tags: ['Revenge', 'Power', 'CEO'],
    category: 'Trending',
    views: 5210,
    isTrending: true,
  ),
  Drama(
    id: '3',
    title: 'Love After Divorce',
    description: 'After a painful divorce, she finds unexpected love in her new neighbor.',
    gradient: [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
    episodes: 12,
    rating: 4.6,
    tags: ['Romance', 'Divorce', 'Healing'],
    category: 'For You',
    views: 2100,
  ),
  Drama(
    id: '4',
    title: 'My Cold Bodyguard',
    description: 'A spoiled heiress forced to live with a cold but handsome bodyguard.',
    gradient: [const Color(0xFF10B981), const Color(0xFF06B6D4)],
    episodes: 14,
    rating: 4.7,
    tags: ['Bodyguard', 'Romance', 'Action'],
    category: 'Trending',
    views: 3890,
    isTrending: true,
  ),
  Drama(
    id: '5',
    title: 'The Lost Heiress',
    description: 'An orphan discovers she is the lost heiress of a trillion-dollar empire.',
    gradient: [const Color(0xFFEAB308), const Color(0xFFF97316)],
    episodes: 18,
    rating: 4.8,
    tags: ['Heiress', 'Revenge', 'Family'],
    category: 'For You',
    views: 4100,
  ),
  Drama(
    id: '6',
    title: 'Contract Marriage Trap',
    description: 'A contract marriage for money turns into real love and deadly secrets.',
    gradient: [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
    episodes: 10,
    rating: 4.5,
    tags: ['Contract', 'Marriage', 'Billionaire'],
    category: 'Trending',
    views: 2980,
  ),
  Drama(
    id: '7',
    title: 'Flash Marriage, Deep Love',
    description: 'She marries a stranger to pay her mother\'s debt, not knowing he\'s a tycoon.',
    gradient: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
    episodes: 15,
    rating: 4.7,
    tags: ['Flash Marriage', 'Romance', 'Billionaire'],
    category: 'For You',
    views: 3670,
  ),
  Drama(
    id: '8',
    title: 'Alpha\'s Regret',
    description: 'Rejected by her Alpha mate, she returns stronger and he begs for forgiveness.',
    gradient: [const Color(0xFF1E293B), const Color(0xFF475569)],
    episodes: 20,
    rating: 4.9,
    tags: ['Werewolf', 'Alpha', 'Revenge'],
    category: 'Trending',
    views: 6120,
    isTrending: true,
  ),
  Drama(
    id: '9',
    title: 'CEO\'s Hidden Wife',
    description: 'A secret marriage with the CEO — will love survive the spotlight?',
    gradient: [const Color(0xFF0EA5E9), const Color(0xFF6366F1)],
    episodes: 12,
    rating: 4.6,
    tags: ['CEO', 'Hidden Marriage', 'Romance'],
    category: 'For You',
    views: 2750,
  ),
  Drama(
    id: '10',
    title: 'Mafia\'s Tender Love',
    description: 'Kidnapped by a mafia boss, she slowly melts his frozen heart.',
    gradient: [const Color(0xFF991B1B), const Color(0xFFDC2626)],
    episodes: 16,
    rating: 4.8,
    tags: ['Mafia', 'Kidnap', 'Romance'],
    category: 'Trending',
    views: 4450,
    isTrending: true,
  ),
  Drama(
    id: '11',
    title: 'Reborn as a Genius',
    description: 'After failing the exam, she is reborn and becomes the top student with a genius mind.',
    gradient: [const Color(0xFF059669), const Color(0xFF10B981)],
    episodes: 8,
    rating: 4.4,
    tags: ['Rebirth', 'School', 'Genius'],
    category: 'For You',
    views: 1890,
  ),
  Drama(
    id: '12',
    title: 'The Double Life',
    description: 'By day a clerk, by night a secret assassin — his two lives collide.',
    gradient: [const Color(0xFF312E81), const Color(0xFF4338CA)],
    episodes: 14,
    rating: 4.7,
    tags: ['Double Life', 'Assassin', 'Action'],
    category: 'Trending',
    views: 3320,
  ),
];

List<String> categories = ['For You', 'Trending', 'Romance'];
