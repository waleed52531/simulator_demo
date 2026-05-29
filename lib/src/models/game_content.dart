class ShiftContent {
  const ShiftContent({
    required this.id,
    required this.shiftNumber,
    required this.title,
    required this.onScreenMessage,
    required this.startingTipMeter,
    required this.scenes,
  });

  final String id;
  final int shiftNumber;
  final String title;
  final String onScreenMessage;
  final int startingTipMeter;
  final List<SceneContent> scenes;

  factory ShiftContent.fromJson(Map<String, dynamic> json) {
    return ShiftContent(
      id: json['id'] as String,
      shiftNumber: json['shiftNumber'] as int,
      title: json['title'] as String,
      onScreenMessage: json['onScreenMessage'] as String,
      startingTipMeter: json['startingTipMeter'] as int,
      scenes: (json['scenes'] as List<dynamic>)
          .map((scene) => SceneContent.fromJson(scene as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class SceneContent {
  const SceneContent({
    required this.id,
    required this.shiftNumber,
    required this.sceneNumber,
    required this.sceneTitle,
    required this.sceneType,
    required this.isTimed,
    required this.scenario,
    required this.prompt,
    required this.choices,
    required this.bestChoice,
    this.timerSeconds,
    this.timeoutChoice,
    this.mechanic,
  });

  final String id;
  final int shiftNumber;
  final int sceneNumber;
  final String sceneTitle;
  final String sceneType;
  final bool isTimed;
  final String scenario;
  final String prompt;
  final List<ChoiceContent> choices;
  final String bestChoice;
  final int? timerSeconds;
  final String? timeoutChoice;
  final SceneMechanic? mechanic;

  ChoiceContent? choiceById(String id) {
    for (final choice in choices) {
      if (choice.id == id) {
        return choice;
      }
    }
    return null;
  }

  factory SceneContent.fromJson(Map<String, dynamic> json) {
    return SceneContent(
      id: json['id'] as String,
      shiftNumber: json['shiftNumber'] as int,
      sceneNumber: json['sceneNumber'] as int,
      sceneTitle: json['sceneTitle'] as String,
      sceneType: json['sceneType'] as String,
      isTimed: json['isTimed'] as bool,
      scenario: json['scenario'] as String,
      prompt: json['prompt'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((choice) => ChoiceContent.fromJson(choice as Map<String, dynamic>))
          .toList(growable: false),
      bestChoice: json['bestChoice'] as String,
      timerSeconds: json['timerSeconds'] as int?,
      timeoutChoice: json['timeoutChoice'] as String?,
      mechanic: json['mechanic'] == null
          ? null
          : SceneMechanic.fromJson(json['mechanic'] as Map<String, dynamic>),
    );
  }
}

class ChoiceContent {
  const ChoiceContent({
    required this.id,
    required this.text,
    required this.tipMeterChange,
    required this.tipMeterLabel,
    required this.isBestChoice,
    required this.feedback,
    this.reinforcement,
    this.notebookUnlock,
    this.coachingFlag,
  });

  final String id;
  final String text;
  final int tipMeterChange;
  final String tipMeterLabel;
  final bool isBestChoice;
  final String feedback;
  final String? reinforcement;
  final String? notebookUnlock;
  final String? coachingFlag;

  factory ChoiceContent.fromJson(Map<String, dynamic> json) {
    return ChoiceContent(
      id: json['id'] as String,
      text: json['text'] as String,
      tipMeterChange: json['tipMeterChange'] as int,
      tipMeterLabel: json['tipMeterLabel'] as String,
      isBestChoice: json['isBestChoice'] as bool,
      feedback: json['feedback'] as String,
      reinforcement: json['reinforcement'] as String?,
      notebookUnlock: json['notebookUnlock'] as String?,
      coachingFlag: json['coachingFlag'] as String?,
    );
  }
}

class SceneMechanic {
  const SceneMechanic({
    required this.whatYouDo,
    required this.guestFeels,
    required this.result,
  });

  final String whatYouDo;
  final String guestFeels;
  final String result;

  factory SceneMechanic.fromJson(Map<String, dynamic> json) {
    return SceneMechanic(
      whatYouDo: json['whatYouDo'] as String,
      guestFeels: json['guestFeels'] as String,
      result: json['result'] as String,
    );
  }
}
