class FunAchievements extends AchievementPackPartImpl;

enum FunIndex {
    MEDIC_GAME, GOOMBA_STOMP, BLUNT_TRAUMA, SHORYUKEN, IM_RICH,
    HADOKEN, WILD_WILD_WEST, I_AM_A_SPY, KAMIKAZE, BLUNTLY_STATED,
    NET_LOSS
};


var array<byte> speciesKilled;
var int scrakesUppercutted;
var int numTimesUnder200;
var int numtimesPinged;
var float PatKillTime, selfPipeKillTime;

function bool isPistolDamage(class<DamageType> damageType) {
    return class<DamTypeDualies>(damageType) != none || class<DamTypeMK23Pistol>(damageType) != none || class<DamTypeMagnum44Pistol>(damageType) != none || 
            class<DamTypeDeagle>(damageType) != none || class<DamTypeFlareProjectileImpact>(damageType) != none || class<DamTypeFlareRevolver>(damageType) != none;
}

function Timer() {
    super.Timer();

    if (KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill != class'KFVetFieldMedic') {
        achievements[FunIndex.MEDIC_GAME].canEarn= false;
    }
    if (PlayerController(Owner).PlayerReplicationInfo.Score > 10000) {
        achievementCompleted(FunIndex.IM_RICH);
    }
    if (achievements[FunIndex.NET_LOSS].canEarn) {
        numTimesPinged++;
        if (PlayerController(Owner).PlayerReplicationInfo.Ping * 4 < 200) {
            numTimesUnder200++;
        }
    }
}

function MatchStarting() {
    if (KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill == class'KFVetFieldMedic') {
        achievements[FunIndex.MEDIC_GAME].canEarn= true;
    }
    if (Level.GetLocalPlayerController() != PlayerController(Owner)) {
        achievements[FunIndex.NET_LOSS].canEarn= true;
    }
}

event matchEnd(string mapname, float difficulty, int length, byte result) {
    local int i;

    if (length == KFGameType(Level.Game).GL_Long && achievements[FunIndex.MEDIC_GAME].canEarn) {
        achievementCompleted(FunIndex.MEDIC_GAME);
    }
    if (achievements[FunIndex.NET_LOSS].canEarn && numTimesPinged * 0.95 <= numTimesUnder200) {
        achievementCompleted(FunIndex.NET_LOSS);
    }
    if (speciesKilled.Length == KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length + 1) {
        for(i= 0; i < speciesKilled.Length; i++) {
            if (speciesKilled[i] != 1) {
                break;
            }
        }
        if (i == speciesKilled.Length) {
            achievementCompleted(FunIndex.WILD_WILD_WEST);
        }
    }
    if (patKillTime != 0 && selfPipeKillTime != 0 && Abs(selfPipeKillTime - patKillTime) <= 5) {
        achievementCompleted(FunIndex.KAMIKAZE);
    }
}

event playerDied(Controller Killer, class<DamageType> damageType) {
    if (Killer == Controller(Owner) && damageType == class'PipebombProjectile'.default.MyDamageType) {
        selfPipeKillTime= Level.TimeSeconds;
    }
}

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot) {
    local int i;

    achievements[FunIndex.MEDIC_GAME].canEarn= false;
    if (ZombieCrawler(target) != none && damageType == class'Crushed') {
        achievementCompleted(FunIndex.GOOMBA_STOMP);
    }
    if (ZombieHusk(target) != none && damageType == class'KFMod.DamTypeRocketImpact' && headshot) {
        addProgress(FunIndex.BLUNT_TRAUMA, 1);
    }
    if (ZombieScrake(target) != none && ZombieScrake(target).LastMomentum.Z > 40000) {
        scrakesUppercutted++;
        if (scrakesUppercutted == 10) {
            achievementCompleted(FunIndex.SHORYUKEN);
        }
    }
    if (ZombieFleshpound(target) != none && damageType == class'HuskGunProjectile'.default.ImpactDamageType) {
        addProgress(FunIndex.HADOKEN, 1);
    }

    if (isPistolDamage(damageType)) {
        if (ZombieBoss(target) != none) {
            speciesKilled[KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length]= 1;
        }
        for(i= 0; i < KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length; i++) {
            if (string(target.class) ~= KFGameType(Level.Game).MonsterCollection.default.MonsterClasses[i].MClassName) {
                speciesKilled[i]= 1;
                break;
            }
        }
    }
    if (ZombieBoss(target) != none && damageType == class'PipeBombProjectile'.default.MyDamageType) {
        patKillTime= Level.TimeSeconds;
    }
}

event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot) {
    if (ZombieScrake(target) != none && damageType == class'DamTypeRocketImpact' && damage * 1.5 > target.default.HealthMax) {
        achievementCompleted(FunIndex.BLUNTLY_STATED);
    }
    if (ZombieFleshpound(target) != none && damageType == class'DamTypeKnife' && ZombieFleshpound(target).bBackstabbed) {
        achievementCompleted(FunIndex.I_AM_A_SPY);
    }
}

defaultproperties {
    packName= "Fun Pack"

    achievements(0)=(title="Medic Game",description="Play and win a long game as medic, without killing a single specimen")
    achievements(1)=(title="Goomba Stomp",description="Kill a crawler by jumping on it")
    achievements(2)=(title="Blunt Trauma",description="Kill 10 husks with impact head shots",maxProgress=20,notifyIncrement=0.25)
    achievements(3)=(title="Shoryuken",description="Uppercut 10 scrakes in a game")
    achievements(4)=(title="I'm Rich!",description="Hold over £10000")
    achievements(5)=(title="Hadoken",description="Kill 10 fleshpounds with the husk cannon impact damage",maxProgress=10,notifyIncrement=0.5)
    achievements(6)=(title="Wild Wild West",description="Kill one of every specimen with pistols")
    achievements(7)=(title="I am a Spy",description="Backstab a fleshpound with the knife")
    achievements(8)=(title="Kamikaze",description="Kill yourself and the patriarch with a pipebomb")
    achievements(9)=(title="Bluntly Stated",description="Stun a scrake with impact damage")
    achievements(10)=(title="Net Loss",description="Play a full match on a server with 200+ ping")
}
