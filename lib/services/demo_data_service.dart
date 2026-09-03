import 'dart:ui';
import '../models/dream_entry.dart';
import '../widgets/sketch_canvas.dart';

class DemoDataService {
  static List<DreamEntry> getDemoDreams() {
    final now = DateTime.now();

    // Generate sketch vector data for Dream 3 (Flight over water)
    final flightSketch = DrawnLine.serializeList([
      DrawnLine(
        points: const [
          Offset(40, 140), Offset(80, 110), Offset(120, 90),
          Offset(160, 100), Offset(200, 130), Offset(240, 170),
        ],
        color: const Color(0xFF06B6D4), // Cyan wave
        strokeWidth: 3.0,
      ),
      DrawnLine(
        points: const [
          Offset(30, 160), Offset(70, 130), Offset(110, 110),
          Offset(150, 120), Offset(190, 150), Offset(230, 190),
        ],
        color: const Color(0xFF06B6D4),
        strokeWidth: 2.0,
      ),
      // Wings / Flying silhouette
      DrawnLine(
        points: const [
          Offset(90, 70), Offset(120, 50), Offset(140, 65), Offset(160, 50), Offset(190, 70),
        ],
        color: const Color(0xFFF59E0B), // Gold
        strokeWidth: 2.5,
      ),
      DrawnLine(
        points: const [
          Offset(140, 65), Offset(140, 85),
        ],
        color: const Color(0xFFF59E0B),
        strokeWidth: 2.5,
      ),
    ]);

    // Generate sketch for Dream 6 (Owl & Starlight)
    final owlSketch = DrawnLine.serializeList([
      DrawnLine(
        points: const [
          Offset(140, 60), Offset(125, 80), Offset(125, 120), Offset(140, 140),
          Offset(155, 120), Offset(155, 80), Offset(140, 60),
        ],
        color: const Color(0xFFF8FAFC), // White owl body
        strokeWidth: 2.5,
      ),
      DrawnLine(
        points: const [
          Offset(125, 85), Offset(80, 70), Offset(60, 95), Offset(125, 110),
        ],
        color: const Color(0xFFA855F7), // Left wing
        strokeWidth: 2.0,
      ),
      DrawnLine(
        points: const [
          Offset(155, 85), Offset(200, 70), Offset(220, 95), Offset(155, 110),
        ],
        color: const Color(0xFFA855F7), // Right wing
        strokeWidth: 2.0,
      ),
      DrawnLine(
        points: const [
          Offset(140, 30), Offset(140, 42),
        ],
        color: const Color(0xFFF59E0B), // North star
        strokeWidth: 3.0,
      ),
      DrawnLine(
        points: const [
          Offset(134, 36), Offset(146, 36),
        ],
        color: const Color(0xFFF59E0B),
        strokeWidth: 3.0,
      ),
    ]);

    return [
      // 1. 13 days ago
      DreamEntry(
        id: 'demo-1',
        date: now.subtract(const Duration(days: 13, hours: 2)),
        title: 'The Shoreline of Whispering Water',
        description: 'I was walking barefoot along an expansive indigo coastline. The water glowed with faint bioluminescent cyan tides. Alex appeared on the dune and pointed out toward a distant silhouette rising from the horizon.',
        isNoRecall: false,
        emotionsDuring: ['Peaceful', 'Curious'],
        people: ['Alex'],
        symbols: ['Ocean', 'Bioluminescence'],
        actionsEvents: '1. Walked the sandy tide line\n2. Watched glowing cyan foam\n3. Met Alex near the dune',
        meaningsAssociations: 'Feels connected to slowing down and listening to intuition.',
        emotionsUponWaking: ['Calm'],
        isLucid: false,
        recallContext: 'Immediately upon waking in bed',
        notes: 'The sound of the ocean was crystal clear.',
      ),

      // 2. 10 days ago
      DreamEntry(
        id: 'demo-2',
        date: now.subtract(const Duration(days: 10, hours: 3)),
        title: 'Clock Tower at Sunset',
        description: 'A tall stone clock tower rose straight out of the ocean. Its brass hands were spinning backwards against a violet sky. Alex stood on the winding steps holding an antique lantern, waving me up.',
        isNoRecall: false,
        emotionsDuring: ['Confused', 'Excited'],
        people: ['Alex'],
        symbols: ['Clock Tower', 'Ocean', 'Brass Lantern'],
        actionsEvents: '1. Approached the tower by water\n2. Saw the hands moving backwards\n3. Climbed toward the lantern',
        meaningsAssociations: 'Feeling time slipping away recently; a reminder to stay present.',
        emotionsUponWaking: ['Inspired', 'Calm'],
        isLucid: false,
        recallContext: 'While sitting still with eyes closed',
        notes: 'The clock tower is becoming a recurring landmark.',
      ),

      // 3. 7 days ago - Lucid!
      DreamEntry(
        id: 'demo-3',
        date: now.subtract(const Duration(days: 7, hours: 1)),
        title: 'Lucid Flight Above the Waves',
        description: 'I was standing at the edge of the stone clock tower again. Recognizing the tower from my journal, I performed a reality check—I examined my hands and saw my fingers were made of soft light! Lucidity struck instantly. Knowing I was dreaming, I leaped off the parapet and soared effortlessly over the glowing ocean.',
        isNoRecall: false,
        emotionsDuring: ['Excited', 'Happy', 'Peaceful'],
        people: [],
        symbols: ['Clock Tower', 'Ocean', 'Flying', 'Light Hands'],
        actionsEvents: '1. Recognized recurring clock tower\n2. Checked hands & confirmed dream state\n3. Took flight into the starry night sky',
        meaningsAssociations: 'Direct proof that journal dream signs trigger lucidity!',
        emotionsUponWaking: ['Inspired'],
        isLucid: true,
        recallContext: 'Eyes closed, remembered the flight euphoria immediately',
        notes: 'Wind temperature felt warm. Flight control was effortless by leaning forward.',
        sketchData: flightSketch,
      ),

      // 4. 5 days ago - Habit keeper
      DreamEntry(
        id: 'demo-4',
        date: now.subtract(const Duration(days: 5, hours: 4)),
        title: 'No Recall',
        description: 'Woke up without conscious dream memory. Logged to keep the recall habit alive.',
        isNoRecall: true,
        emotionsDuring: [],
        people: [],
        symbols: [],
        actionsEvents: '',
        meaningsAssociations: '',
        emotionsUponWaking: ['Calm'],
        isLucid: false,
        recallContext: 'Promptly upon alarm',
        notes: 'Reinforced intention before sleep tonight.',
      ),

      // 5. 3 days ago
      DreamEntry(
        id: 'demo-5',
        date: now.subtract(const Duration(days: 3, hours: 2)),
        title: 'The Celestial Labyrinth and the White Owl',
        description: 'Walking through a labyrinth of carved Obsidian walls under a canopy of stars. A majestic White Owl perched atop a stone archway, turning its head toward me. An Alchemist character approached holding a celestial star map and pointed north.',
        isNoRecall: false,
        emotionsDuring: ['Curious', 'Peaceful'],
        people: ['The Alchemist'],
        symbols: ['Labyrinth', 'White Owl', 'Star Map'],
        actionsEvents: '1. Entered labyrinth\n2. Owl gave direction\n3. Examined star map with the Alchemist',
        meaningsAssociations: 'Navigating life decisions; trusting guidance.',
        emotionsUponWaking: ['Calm', 'Inspired'],
        isLucid: false,
        recallContext: 'Recalled while still half-asleep',
        notes: 'The owl feathers had an ethereal shimmer.',
      ),

      // 6. 1 day ago - Lucid!
      DreamEntry(
        id: 'demo-6',
        date: now.subtract(const Duration(days: 1, hours: 2)),
        title: 'Lucid Ascendance with the White Owl',
        description: 'Saw the White Owl perched on a marble pillar. The moment I saw it, I remembered my dream sign from two nights ago. "I am dreaming!" I declared out loud. The owl spread its wings and we ascended together through silver clouds into a grand cosmic amphitheater.',
        isNoRecall: false,
        emotionsDuring: ['Happy', 'Excited', 'Peaceful'],
        people: [],
        symbols: ['White Owl', 'Flying', 'Starlight'],
        actionsEvents: '1. Identified White Owl dream sign\n2. Triggered lucidity verbally\n3. Ascended through clouds into cosmic sphere',
        meaningsAssociations: 'The dream signs method works remarkably well.',
        emotionsUponWaking: ['Inspired'],
        isLucid: true,
        recallContext: 'Woke up smiling with memory completely intact',
        notes: 'The sense of speed and freedom was extraordinary.',
        sketchData: owlSketch,
      ),

      // 7. Today
      DreamEntry(
        id: 'demo-7',
        date: now.subtract(const Duration(minutes: 90)),
        title: "The Alchemist's Floating Library",
        description: 'Alex and The Alchemist were organizing ancient manuscripts inside a glass cathedral floating suspended over the ocean. Each manuscript opened to reveal a rotating holographic constellation map.',
        isNoRecall: false,
        emotionsDuring: ['Peaceful', 'Happy'],
        people: ['Alex', 'The Alchemist'],
        symbols: ['Ocean', 'Floating Library', 'Star Map'],
        actionsEvents: '1. Floated up into glass cathedral\n2. Browsed constellation books with Alex\n3. The Alchemist smiled and shared wisdom',
        meaningsAssociations: 'Knowledge, creative synthesis, and friendship.',
        emotionsUponWaking: ['Inspired', 'Calm'],
        isLucid: false,
        recallContext: 'Retraced immediately before opening eyes',
        notes: 'A perfect synthesis of ocean, sky, and constellation signs.',
      ),
    ];
  }
}
