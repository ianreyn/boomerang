class SettingsObj
{
  double? maxMon;
  double? maxTues;
  double? maxWed;
  double? maxThurs;
  double? maxFri;
  double? maxSat;
  double? maxSun;
  bool? showFinished;
  bool? showPlanned;

  SettingsObj(this.maxMon, this.maxTues, this.maxWed, this.maxThurs, this.maxFri, this.maxSat, this.maxSun, this.showFinished, this.showPlanned);

  SettingsObj.fromMap(Map map)
  {
    maxMon = map['maxMon'].toDouble();
    maxTues = map['maxTues'].toDouble();
    maxWed = map['maxWed'].toDouble();
    maxThurs = map['maxThurs'].toDouble();
    maxFri = map['maxFri'].toDouble();
    maxSat = map['maxSat'].toDouble();
    maxSun = map['maxSun'].toDouble();
    showPlanned = map['showPlanned'];
    showFinished = map['showFinished'];
  }

  Map<String, Object?> toMap()
  {
    return {
      'maxMon': maxMon!,
      'maxTues': maxTues,
      'maxWed': maxWed,
      'maxThurs': maxThurs,
      'maxFri': maxFri,
      'maxSat': maxSat,
      'maxSun': maxSun,
      'showPlanned': showPlanned,
      'showFinished': showFinished
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "$maxMon, $maxTues, $maxWed, $maxThurs, $maxFri, $maxSat, $maxSun, Show planned: $showPlanned, Show Finished: $showFinished";
  }

}