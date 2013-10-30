class StockAchievements extends AchievementPackPartImpl
    abstract;

function bool checkCounter(int counter, byte achvIndex) {
    if (counter <= 0) {
        achievementCompleted(achvIndex);
    }
    return true;
}

function updateKillTypes(out array<byte> killedTypes, Class<Pawn> targetClass) {
    local int i;

    if (ClassIsChildOf(targetClass, class'ZombieBoss')) {
        killedTypes[KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length]= 1;
    } else {
        for(i= 0; i < KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length; i++) {
            if (string(targetClass) ~= KFGameType(Level.Game).MonsterCollection.default.MonsterClasses[i].MClassName) {
                killedTypes[i]= 1;
                break;
            }
        }
    }
}

function bool allSpeciesKilled(array<byte> killedTypes) {
    local int i;

    if (killedTypes.Length == KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length + 1) {
        for(i= 0; i < killedTypes.Length; i++) {
            if (killedTypes[i] != 1) {
                return false;
            }
        }
        return true;
    }
    return false;
}
