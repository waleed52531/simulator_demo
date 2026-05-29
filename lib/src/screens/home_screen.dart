import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/game_controller.dart';
import '../models/game_content.dart';
import '../widgets/choice_card.dart';
import '../widgets/tip_meter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(shiftContentProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Great Tips Game'),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(gameControllerProvider.notifier).restart(),
            icon: const Icon(Icons.replay),
            label: const Text('Replay'),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_esports), label: 'Game'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Manager'),
        ],
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Content error: $error')),
        data: (content) => _tabIndex == 0
            ? GameTab(content: content)
            : ManagerDashboard(content: content),
      ),
    );
  }
}

class GameTab extends ConsumerWidget {
  const GameTab({required this.content, super.key});

  final ShiftContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    if (session.isComplete) {
      return CompletionView(content: content, session: session);
    }

    final scene = content.scenes[session.currentSceneIndex];
    final selectedChoice = session.answerFor(scene);
    final hasAnswered = selectedChoice != null;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        IntroPanel(content: content),
        const SizedBox(height: 12),
        TipMeter(value: session.tipMeter),
        const SizedBox(height: 12),
        SceneHeader(scene: scene, totalScenes: content.scenes.length),
        const SizedBox(height: 12),
        if (scene.isTimed)
          TimerBanner(secondsRemaining: session.secondsRemaining ?? 0),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scene.scenario,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Text(scene.prompt),
                const SizedBox(height: 20),
                ...scene.choices
                    .where((choice) => choice.id != scene.timeoutChoice)
                    .map(
                      (choice) => ChoiceCard(
                        choice: choice,
                        isSelected: selectedChoice?.id == choice.id,
                        hasAnswered: hasAnswered,
                        onTap: () => controller.submitChoice(choice.id),
                      ),
                    ),
              ],
            ),
          ),
        ),
        if (hasAnswered) ...[
          const SizedBox(height: 12),
          FeedbackPanel(choice: selectedChoice, mechanic: scene.mechanic),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: controller.continueToNextScene,
            child: Text(
              scene.sceneNumber == content.scenes.length
                  ? 'Complete Shift'
                  : 'Continue',
            ),
          ),
        ],
      ],
    );
  }
}

class IntroPanel extends StatelessWidget {
  const IntroPanel({required this.content, super.key});

  final ShiftContent content;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            Text(content.onScreenMessage),
          ],
        ),
      ),
    );
  }
}

class SceneHeader extends StatelessWidget {
  const SceneHeader({
    required this.scene,
    required this.totalScenes,
    super.key,
  });

  final SceneContent scene;
  final int totalScenes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Scene ${scene.sceneNumber}/$totalScenes · ${scene.sceneTitle}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ],
    );
  }
}

class TimerBanner extends StatelessWidget {
  const TimerBanner({required this.secondsRemaining, super.key});

  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: secondsRemaining <= 10 ? Colors.red.shade50 : Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.timer),
            const SizedBox(width: 10),
            Text(
              '$secondsRemaining seconds remaining',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({required this.choice, required this.mechanic, super.key});

  final ChoiceContent choice;
  final SceneMechanic? mechanic;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              choice.isBestChoice ? 'Strong Choice' : 'Coaching Moment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: choice.isBestChoice ? Colors.green : Colors.red,
                  ),
            ),
            const SizedBox(height: 10),
            Text(choice.feedback),
            if (choice.reinforcement != null) ...[
              const SizedBox(height: 10),
              Text(
                choice.reinforcement!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            if (choice.notebookUnlock != null) ...[
              const SizedBox(height: 12),
              Chip(
                avatar: const Icon(Icons.menu_book),
                label: Text('Notebook Unlock: ${choice.notebookUnlock!}'),
              ),
            ],
            if (mechanic != null) ...[
              const Divider(height: 28),
              Text(
                'What you do → ${mechanic!.whatYouDo} → ${mechanic!.guestFeels} → ${mechanic!.result}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CompletionView extends ConsumerWidget {
  const CompletionView({required this.content, required this.session, super.key});

  final ShiftContent content;
  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scorePercent = (session.bestChoices / content.scenes.length * 100).round();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        TipMeter(value: session.tipMeter),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift Complete',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                Text('Best-choice accuracy: $scorePercent%'),
                Text('Notebook unlocks: ${session.notebookUnlocks.length}'),
                Text('Coaching flags: ${session.coachingFlags.length}'),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => ref.read(gameControllerProvider.notifier).restart(),
                  child: const Text('Replay Shift'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({required this.content, super.key});

  final ShiftContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameControllerProvider);
    final progress = session.completedScenes / content.scenes.length;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Manager Dashboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        TipMeter(value: session.tipMeter),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shift progress: ${(progress * 100).round()}%'),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 16),
                Text('Best choices: ${session.bestChoices}/${content.scenes.length}'),
                Text('Scenes completed: ${session.completedScenes}/${content.scenes.length}'),
              ],
            ),
          ),
        ),
        DashboardList(
          title: 'Notebook Unlocks',
          emptyText: 'No notebook unlocks yet.',
          items: session.notebookUnlocks,
        ),
        DashboardList(
          title: 'Coaching Flags',
          emptyText: 'No coaching flags yet.',
          items: session.coachingFlags,
        ),
      ],
    );
  }
}

class DashboardList extends StatelessWidget {
  const DashboardList({
    required this.title,
    required this.emptyText,
    required this.items,
    super.key,
  });

  final String title;
  final String emptyText;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(emptyText)
            else
              ...items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.chevron_right),
                  title: Text(item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
