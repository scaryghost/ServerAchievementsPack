class MapAchievementsBase extends AchievementPackPartImpl
    abstract;

struct MapIndex {
    var string mapname;
    var int achvIndex;
};

var array<MapIndex> mapIndexes;
var float requiredDifficulty;

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum) {
    local int i;
    local string lowerMapName;

    if (result == 2 && requiredDifficulty == difficulty && (length == KFGameType(Level.Game).GL_Normal || length == KFGameType(Level.Game).GL_Long)) {
        lowerMapName= Locs(mapname);
        for(i= 0; i < mapIndexes.Length && mapIndexes[i].mapname != lowerMapName; i++) {
        }
        if (i < mapIndexes.Length) {
            achievementCompleted(mapIndexes[i].achvIndex);
        }
    }
}
