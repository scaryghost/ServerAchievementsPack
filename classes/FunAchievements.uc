class FunAchievements extends AchievementPackPartImpl;

enum FunIndex {
    MEDIC_GAME, GOOMBA_STOMP, BLUNT_TRAUMA, SHORYUKEN, IM_RICH,
    HADOKEN, WILD_WILD_WEST, I_AM_A_SPY, KAMIKAZE, BLUNTLY_STATED,
    NET_LOSS, HIGH_PRIORITY_TARGET, MIND_READER
};


var array<byte> speciesKilled;
var int scrakesUppercutted, numTimesUnder200, numtimesPinged, jumpedOnCrawler;
var float PatKillTime, selfPipeKillTime;
var array<class<DamageType> > pistolDamage, bigGunsDamage;
var bool canEarnMedicGame, canEarnNetLoss;

function bool contains(array<class<DamageType> > list, class<DamageType> key) {
    local int i;

    for(i= 0; i < list.Length && list[i] != key; i++) {
    }
    return i < list.Length;
}
    
function bool isPistolDamage(class<DamageType> damageType) {
    return contains(pistolDamage, damageType);
}

function bool isBigWeaponDamage(class<DamageType> damageType) {
    return contains(bigGunsDamage, damageType);
}

function PostBeginPlay() {
    super.PostBeginPlay();

    pistolDamage[0]= class'SingleFire'.default.DamageType;
    pistolDamage[1]= class'DualiesFire'.default.DamageType;
    pistolDamage[2]= class'MK23Fire'.default.DamageType;
    pistolDamage[3]= class'DualMK23Fire'.default.DamageType;
    pistolDamage[4]= class'Magnum44Fire'.default.DamageType;
    pistolDamage[5]= class'Dual44MagnumFire'.default.DamageType;
    pistolDamage[6]= class'DeagleFire'.default.DamageType;
    pistolDamage[7]= class'DualDeagleFire'.default.DamageType;
    pistolDamage[8]= class'FlareRevolverProjectile'.default.ImpactDamageType;
    pistolDamage[9]= class'FlareRevolverProjectile'.default.MyDamageType;

    bigGunsDamage[0]= class'LAWProj'.default.MyDamageType;
    bigGunsDamage[1]= class'M99Bullet'.default.MyDamageType;
    bigGunsDamage[2]= class'M99Bullet'.default.DamageTypeHeadShot;
    bigGunsDamage[3]= class'CrossbowArrow'.default.MyDamageType;
    bigGunsDamage[4]= class'CrossbowArrow'.default.DamageTypeHeadShot;
    bigGunsDamage[5]= class'BoomStickBullet'.default.MyDamageType;

    SetTimer(1.0, true);
}

function Timer() {
    super.Timer();

    if (Owner != none && KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill != class'KFVetFieldMedic') {
        canEarnMedicGame= false;
    }
    if (Owner != none && PlayerController(Owner).PlayerReplicationInfo.Score > 10000) {
        achievementCompleted(FunIndex.IM_RICH);
    }
    if (Owner != none && canEarnNetLoss) {
        numTimesPinged++;
        if (PlayerController(Owner).PlayerReplicationInfo.Ping * 4 < 200) {
            numTimesUnder200++;
        }
    }
}

function MatchStarting() {
    if (KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill == class'KFVetFieldMedic') {
        canEarnMedicGame= true;
    }
    if (Level.GetLocalPlayerController() != PlayerController(Owner)) {
        canEarnNetLoss= true;
    }
}

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum) {
    local int i;

    if (canEarnMedicGame) {
        achievementCompleted(FunIndex.MEDIC_GAME);
    }
    if (canEarnNetLoss && numTimesPinged > 600 && numTimesPinged * 0.05 >= numTimesUnder200) {
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

event waveStart(int waveNum) {
    jumpedOnCrawler= 0;
}

event playerDied(Controller Killer, class<DamageType> damageType, int waveNum) {
    if (Killer == Controller(Owner) && damageType == class'PipebombProjectile'.default.MyDamageType) {
        selfPipeKillTime= Level.TimeSeconds;
    }
}

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot) {
    local int i;

    canEarnMedicGame= false;
    if (ZombieCrawler(target) != none && isBigWeaponDamage(damageType)) {
        addProgress(FunIndex.HIGH_PRIORITY_TARGET, 1);
    } else if (ZombieHusk(target) != none && damageType == class'DamTypeRocketImpact' && headshot) {
        addProgress(FunIndex.BLUNT_TRAUMA, 1);
    } else if (ZombieScrake(target) != none && ZombieScrake(target).LastMomentum.Z > 40000) {
        scrakesUppercutted++;
        if (scrakesUppercutted == 10) {
            achievementCompleted(FunIndex.SHORYUKEN);
        }
    } else if (ZombieFleshpound(target) != none && damageType == class'HuskGunProjectile'.default.ImpactDamageType) {
        addProgress(FunIndex.HADOKEN, 1);
    } else if (ZombieBoss(target) != none && damageType == class'PipeBombProjectile'.default.MyDamageType) {
        patKillTime= Level.TimeSeconds;
    }

    if (isPistolDamage(damageType)) {
        if (ZombieBoss(target) != none) {
            speciesKilled[KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length]= 1;
        } else {
            for(i= 0; i < KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length; i++) {
                if (string(target.class) ~= KFGameType(Level.Game).MonsterCollection.default.MonsterClasses[i].MClassName) {
                    speciesKilled[i]= 1;
                    break;
                }
            }
        }
    }
}

event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot) {
    if (ZombieScrake(target) != none && damageType == class'DamTypeRocketImpact' && damage * 1.5 > target.default.HealthMax) {
        achievementCompleted(FunIndex.BLUNTLY_STATED);
    } else if (ZombieFleshpound(target) != none && damageType == class'DamTypeKnife' && ZombieFleshpound(target).bBackstabbed) {
        achievementCompleted(FunIndex.I_AM_A_SPY);
    } else if (ZombieCrawler(target) != none && damageType == class'Crushed') {
        jumpedOnCrawler++;
        if (jumpedOnCrawler == 8) {
            achievementCompleted(FunIndex.GOOMBA_STOMP);
        }
    } else if (ZombieBoss(target) != none && damageType == class'PipeBombProjectile'.default.MyDamageType) {
        if (target.IsInState('MakingEntrance')) {
            achievementCompleted(FunIndex.MIND_READER);
        }
    }
}

defaultproperties {
    packName= "Fun Pack"

    achievements(0)=(title="Medic Game",description="Play a full game as medic, without killing a single specimen")
    achievements(1)=(title="Goomba Stomp",description="Jump on a crawler 8 times in a wave")
    achievements(2)=(title="Blunt Trauma",description="Kill 20 husks with blunt grenade headshots",maxProgress=20,notifyIncrement=0.25)
    achievements(3)=(title="Shoryuken",description="Uppercut 10 scrakes in a game")
    achievements(4)=(title="I'm Rich!",description="Hold over £10000")
    achievements(5)=(title="Hadoken",description="Kill 10 fleshpounds with husk cannon impact damage",maxProgress=10,notifyIncrement=0.5)
    achievements(6)=(title="Wild Wild West",description="Kill one of every specimen with pistols")
    achievements(7)=(title="I am a Spy",description="Backstab a fleshpound with the knife")
    achievements(8)=(title="Kamikaze",description="Kill yourself and the patriarch with a pipebomb")
    achievements(9)=(title="Bluntly Stated",description="Stun a scrake with a blunt grenade")
    achievements(10)=(title="Net Loss",description="Play a full game on a server with 200+ ping")
    achievements(11)=(title="High Priority Target",description="Kill 50 crawlers with big guns",maxProgress=50,notifyIncrement=0.1)
    achievements(12)=(title="Mind Reader",description="Damage the Patriarch with a pipe bomb during the cut scene")
}
