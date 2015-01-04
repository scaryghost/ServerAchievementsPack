class MapAchievementsBase extends AchievementPackPartImpl
    abstract;

struct MapIndex {
    var string mapname;
    var int achvIndex;
};

var array<MapIndex> mapIndexes;
var float requiredDifficulty;
var int numWavesPlayed;
var bool playedBossWave;

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum) {
    local int i;
    local string lowerMapName;
    local bool lengthCheck;

    lengthCheck= KFStoryGameInfo(Level.Game) != none || (length == KFGameType(Level.Game).GL_Normal || length == KFGameType(Level.Game).GL_Long);
    if (numWavesPlayed >= KFGameType(Level.Game).FinalWave / 2 + 1 && playedBossWave && result == 2 && 
            requiredDifficulty == difficulty &&  lengthCheck) {
        lowerMapName= Locs(mapname);
        for(i= 0; i < mapIndexes.Length && mapIndexes[i].mapname != lowerMapName; i++) {
        }
        if (i < mapIndexes.Length) {
            achievementCompleted(mapIndexes[i].achvIndex);
        }
    }
}

event waveStart(int waveNum) {
    if (!ownerController.PlayerReplicationInfo.bOnlySpectator && !ownerController.IsDead()) {
        numWavesPlayed++;
        if (waveNum == KFGameType(Level.Game).FinalWave + 1) {
            playedBossWave= true;
        }
    }
}

defaultproperties {
    mapIndexes(0)=(mapname="kf-abusementpark",achvIndex=19)
    mapIndexes(1)=(mapname="kf-aperture",achvIndex=18)
    mapIndexes(2)=(mapname="kf-bedlam",achvIndex=6)
    mapIndexes(3)=(mapname="kf-biohazard",achvIndex=8)
    mapIndexes(4)=(mapname="kf-bioticslab",achvIndex=4)
    mapIndexes(5)=(mapname="kf-clandestine",achvIndex=34)
    mapIndexes(6)=(mapname="kf-crash",achvIndex=9)
    mapIndexes(7)=(mapname="kf-departed",achvIndex=10)
    mapIndexes(8)=(mapname="kf-evilsantaslair",achvIndex=17)
    mapIndexes(9)=(mapname="kf-farm",achvIndex=2)
    mapIndexes(10)=(mapname="kf-filthscross",achvIndex=11)
    mapIndexes(11)=(mapname="kf-foundry",achvIndex=5)
    mapIndexes(12)=(mapname="kf-forgotten",achvIndex=29)
    mapIndexes(13)=(mapname="kf-frightyard",achvIndex=26)
    mapIndexes(14)=(mapname="kf-hell",achvIndex=28)
    mapIndexes(15)=(mapname="kf-hellride",achvIndex=21)
    mapIndexes(16)=(mapname="kf-hillbillyhorror",achvIndex=22)
    mapIndexes(17)=(mapname="kf-hospitalhorrors",achvIndex=12)
    mapIndexes(18)=(mapname="kf-icebreaker",achvIndex=13)
    mapIndexes(19)=(mapname="kf-icecave",achvIndex=20)
    mapIndexes(20)=(mapname="kf-manor",achvIndex=1)
    mapIndexes(21)=(mapname="kf-moonbase",achvIndex=23)
    mapIndexes(22)=(mapname="kf-mountainpass",achvIndex=14)
    mapIndexes(23)=(mapname="kf-offices",achvIndex=3)
    mapIndexes(24)=(mapname="kf-sirensbelch",achvIndex=30)
    mapIndexes(25)=(mapname="kf-steamland",achvIndex=24)
    mapIndexes(26)=(mapname="kf-stronghold",achvIndex=31)
    mapIndexes(27)=(mapname="kf-suburbia",achvIndex=15)
    mapIndexes(28)=(mapname="kf-thrillschills",achvIndex=35)
    mapIndexes(29)=(mapname="kf-transit",achvIndex=32)
    mapIndexes(30)=(mapname="kf-waterworks",achvIndex=16)
    mapIndexes(31)=(mapname="kf-westlondon",achvIndex=0)
    mapIndexes(32)=(mapname="kf-wyre",achvIndex=7)    
    mapIndexes(33)=(mapname="kfo-steamland",achvIndex=25)
    mapIndexes(34)=(mapname="kfo-frightyard",achvIndex=27)
    mapIndexes(35)=(mapname="kfo-transit",achvIndex=33)
}
