import 'package:flutter_test/flutter_test.dart';
import 'package:great_tips_game_sample/src/controllers/game_controller.dart';
import 'package:great_tips_game_sample/src/models/game_content.dart';

void main() {
  test('tip meter is capped at 100 after a high-value choice', () {
    final content = _content(startingTipMeter: 98, tipMeterChange: 10);
    final controller = GameController(content);

    controller.submitChoice('A');

    expect(controller.state.tipMeter, 100);
  });

  test('tip meter is floored at 0 after a loss choice', () {
    final content = _content(startingTipMeter: 4, tipMeterChange: -10);
    final controller = GameController(content);

    controller.submitChoice('A');

    expect(controller.state.tipMeter, 0);
  });

  test('notebook unlocks and coaching flags are recorded from choices', () {
    final content = _content(
      startingTipMeter: 50,
      tipMeterChange: -4,
      notebookUnlock: 'Unlock copy',
      coachingFlag: 'Coach copy',
    );
    final controller = GameController(content);

    controller.submitChoice('A');

    expect(controller.state.notebookUnlocks, ['Unlock copy']);
    expect(controller.state.coachingFlags, ['Scene 1: Coach copy']);
  });
}

ShiftContent _content({
  required int startingTipMeter,
  required int tipMeterChange,
  String? notebookUnlock,
  String? coachingFlag,
}) {
  return ShiftContent(
    id: 'test-shift',
    shiftNumber: 1,
    title: 'Test Shift',
    onScreenMessage: 'Message',
    startingTipMeter: startingTipMeter,
    scenes: [
      SceneContent(
        id: 'scene-1',
        shiftNumber: 1,
        sceneNumber: 1,
        sceneTitle: 'Scene',
        sceneType: 'multiple_choice',
        isTimed: false,
        scenario: 'Scenario',
        prompt: 'Prompt',
        choices: [
          ChoiceContent(
            id: 'A',
            text: 'Choice',
            tipMeterChange: tipMeterChange,
            tipMeterLabel: 'LABEL',
            isBestChoice: true,
            feedback: 'Feedback',
            notebookUnlock: notebookUnlock,
            coachingFlag: coachingFlag,
          ),
        ],
        bestChoice: 'A',
      ),
    ],
  );
}
