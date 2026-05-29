import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_content.dart';
import '../repositories/content_repository.dart';

final shiftContentProvider = FutureProvider<ShiftContent>((ref) {
  return ref.watch(contentRepositoryProvider).loadShift(1);
});

final gameControllerProvider =
    StateNotifierProvider<GameController, GameSession>((ref) {
  final content = ref.watch(shiftContentProvider).valueOrNull;
  return GameController(content);
});

class GameSession {
  const GameSession({
    required this.tipMeter,
    required this.currentSceneIndex,
    required this.answers,
    required this.notebookUnlocks,
    required this.coachingFlags,
    required this.secondsRemaining,
    required this.isComplete,
  });

  factory GameSession.initial([ShiftContent? content]) {
    return GameSession(
      tipMeter: content?.startingTipMeter ?? 50,
      currentSceneIndex: 0,
      answers: const {},
      notebookUnlocks: const [],
      coachingFlags: const [],
      secondsRemaining: content == null || content.scenes.isEmpty
          ? null
          : content.scenes.first.timerSeconds,
      isComplete: false,
    );
  }

  final int tipMeter;
  final int currentSceneIndex;
  final Map<String, ChoiceContent> answers;
  final List<String> notebookUnlocks;
  final List<String> coachingFlags;
  final int? secondsRemaining;
  final bool isComplete;

  GameSession copyWith({
    int? tipMeter,
    int? currentSceneIndex,
    Map<String, ChoiceContent>? answers,
    List<String>? notebookUnlocks,
    List<String>? coachingFlags,
    int? secondsRemaining,
    bool clearTimer = false,
    bool? isComplete,
  }) {
    return GameSession(
      tipMeter: tipMeter ?? this.tipMeter,
      currentSceneIndex: currentSceneIndex ?? this.currentSceneIndex,
      answers: answers ?? this.answers,
      notebookUnlocks: notebookUnlocks ?? this.notebookUnlocks,
      coachingFlags: coachingFlags ?? this.coachingFlags,
      secondsRemaining: clearTimer ? null : secondsRemaining ?? this.secondsRemaining,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  ChoiceContent? answerFor(SceneContent scene) => answers[scene.id];

  int get completedScenes => answers.length;

  int get bestChoices => answers.values.where((choice) => choice.isBestChoice).length;
}

class GameController extends StateNotifier<GameSession> {
  GameController(this._content) : super(GameSession.initial(_content)) {
    _startTimerIfNeeded();
  }

  final ShiftContent? _content;
  Timer? _timer;

  SceneContent? get currentScene {
    final content = _content;
    if (content == null || state.isComplete) {
      return null;
    }
    return content.scenes[state.currentSceneIndex];
  }

  void submitChoice(String choiceId) {
    final scene = currentScene;
    if (scene == null || state.answers.containsKey(scene.id)) {
      return;
    }

    final choice = scene.choiceById(choiceId);
    if (choice == null) {
      return;
    }

    _timer?.cancel();
    final nextAnswers = Map<String, ChoiceContent>.from(state.answers);
    nextAnswers[scene.id] = choice;

    final nextUnlocks = [...state.notebookUnlocks];
    if (choice.notebookUnlock != null &&
        !nextUnlocks.contains(choice.notebookUnlock)) {
      nextUnlocks.add(choice.notebookUnlock!);
    }

    final nextFlags = [...state.coachingFlags];
    if (choice.coachingFlag != null) {
      nextFlags.add('Scene ${scene.sceneNumber}: ${choice.coachingFlag!}');
    }

    state = state.copyWith(
      tipMeter: _boundedTipMeter(state.tipMeter + choice.tipMeterChange),
      answers: nextAnswers,
      notebookUnlocks: nextUnlocks,
      coachingFlags: nextFlags,
      clearTimer: true,
    );
  }

  void continueToNextScene() {
    final content = _content;
    if (content == null) {
      return;
    }

    final nextIndex = state.currentSceneIndex + 1;
    if (nextIndex >= content.scenes.length) {
      _timer?.cancel();
      state = state.copyWith(isComplete: true, clearTimer: true);
      return;
    }

    final nextScene = content.scenes[nextIndex];
    state = state.copyWith(
      currentSceneIndex: nextIndex,
      secondsRemaining: nextScene.timerSeconds,
      clearTimer: !nextScene.isTimed,
    );
    _startTimerIfNeeded();
  }

  void restart() {
    _timer?.cancel();
    state = GameSession.initial(_content);
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    final scene = currentScene;
    if (scene == null || !scene.isTimed || scene.timerSeconds == null) {
      return;
    }

    _timer?.cancel();
    state = state.copyWith(secondsRemaining: scene.timerSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.secondsRemaining;
      if (remaining == null) {
        timer.cancel();
        return;
      }
      if (remaining <= 1) {
        timer.cancel();
        submitChoice(scene.timeoutChoice ?? scene.choices.last.id);
        return;
      }
      state = state.copyWith(secondsRemaining: remaining - 1);
    });
  }

  int _boundedTipMeter(int value) => value.clamp(0, 100).toInt();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
