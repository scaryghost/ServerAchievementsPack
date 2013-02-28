class FailAchievements extends AchievementPackPartImpl;

enum FailIndex {
    GORED_FAST, AMATEUR_DEMOLITIONS, LOST_BAGGAGE, LEVEL_6_PRO,
    PROFESSIONAL_DEMOLITIONS, WATCH_YOUR_STEP, PISTOL_PETE,
    MELTING_POINT, MASTER_DEMOLITIONS, DEMOLITIONS_GOD, USELESS_BAGGAGE, 
    SHARP_SHOOTER
};

var bool diedCurrentWave;
var bool canEarnUselessBaggage;

function bool isScrakeRaged(ZombieScrake scrake, optional float healthOffset) {
    return Level.Game.GameDifficulty < 5.0 && (scrake.Health - healthOffset) < 0.5 * scrake.HealthMax 
        || (scrake.Health - healthOffset) < 0.75 * scrake.HealthMax;
}

function MatchStarting() {
    canEarnUselessBaggage= true;
}

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum) {
    if (canEarnUselessBaggage && result == 2) {
        achievementCompleted(FailIndex.USELESS_BAGGAGE);
    }
}

event waveStart(int waveNum) {
    diedCurrentWave= false;
}

event waveEnd(int waveNum) {
    if (!diedCurrentWave) {
        canEarnUselessBaggage= false;
    }
}

event playerDied(Controller killer, class<DamageType> damageType, int waveNum) {
    local Weapon currWpn;
    local class<KFVeterancyTypes> selectedSkill;

    selectedSkill= KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill;
    currWpn= PlayerController(Owner).Pawn.Weapon;
    if (Syringe(currWpn) != none || Welder(currWpn) != none || Knife(currWpn) != none) {
        addProgress(FailIndex.LOST_BAGGAGE,1);
    }
    if (waveNum == 1 && Level.Game.GameDifficulty <= 2 && 
            KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkillLevel == 6) {
        achievementCompleted(FailIndex.LEVEL_6_PRO);
    }
    if (KFPawn(PlayerController(Owner).Pawn).ShieldStrength == KFPawn(PlayerController(Owner).Pawn).ShieldStrengthMax) {
        achievementCompleted(FailIndex.WATCH_YOUR_STEP);
    }
    if (Killer != none && ZombieGorefast(Killer.Pawn) != none && ZombieGorefast(Killer.Pawn).bDecapitated) {
        achievementCompleted(FailIndex.GORED_FAST);
    }
    if (damageType == class'KFBloatVomit'.default.MyDamageType && (selectedSkill == class'KFVetBerserker' || selectedSkill == class'KFVetFieldMedic')) {
        achievementCompleted(FailIndex.MELTING_POINT);
    } else if ((class<DamTypeFrag>(damageType) != none || class<DamTypeM79Grenade>(damageType) != none || 
            class<DamTypeM203Grenade>(damageType) != none) && Killer == Controller(Owner)) {
        addProgress(FailIndex.DEMOLITIONS_GOD, 1);
    }
    diedCurrentWave= true;
}

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot) {
    if (ZombieBloat(target) != none && ZombieBloat(target).bDecapitated && damageType == class'PipeBombProjectile'.default.MyDamageType) {
        addProgress(FailIndex.AMATEUR_DEMOLITIONS, 1);
    } else if (ZombieStalker(target) != none && damageType == class'KFMod.DamTypeRocketImpact') {
        addProgress(FailIndex.PROFESSIONAL_DEMOLITIONS, 1);
    }
}

event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot) {
    if (ZombieFleshpound(target) != none && damageType == class'SingleFire'.default.DamageType && damage < target.Health && 
            (!target.IsInState('BeginRaging') && !target.IsInState('RageCharging')) && 
            ZombieFleshpound(target).TwoSecondDamageTotal + damage > ZombieFleshpound(target).RageDamageThreshold) {
        achievementCompleted(FailIndex.PISTOL_PETE);
    } else if (ZombieScrake(target) != none) {
        if (damage < target.Health && !isScrakeRaged(ZombieScrake(target), 0) && isScrakeRaged(ZombieScrake(target), damage) && 
            (class<DamTypeFrag>(damageType) != none || class<DamTypeM79Grenade>(damageType) != none || class<DamTypeM203Grenade>(damageType) != none)) {
            addProgress(FailIndex.MASTER_DEMOLITIONS, 1);
        } else if (damageType == class'DamTypeM99SniperRifle' && !headshot) {
            addProgress(FailIndex.SHARP_SHOOTER, 1);
        }
    }
}

defaultproperties {
    packName= "Fail Pack"

    achievements(0)=(title="Gored Fast",description="Be killed by a headless gorefast")
    achievements(1)=(title="Amateur Demolitions",description="Kill 20 headless bloats with pipe bombs",maxProgress=20,notifyIncrement=0.20)
    achievements(2)=(title="Lost Baggage",description="Die with your syringe, welder, or knife out 10 times",maxProgress=10,notifyIncrement=0.5)
    achievements(3)=(title="Level 6 Pro",description="Die on wave 1 with a level 6 perk on normal or beginner difficulty")
    achievements(4)=(title="Professional Demolitions",description="Kill 15 stalkers with blunt grenades",maxProgress=20,notifyIncrement=0.3333)
    achievements(5)=(title="Watch Your Step",description="Be killed while still having full armor")
    achievements(6)=(title="Pistol Pete",description="Enrage a fleshpound with the 9mm or dual 9mm")
    achievements(7)=(title="Melting Point",description="Be killed by bloat bile as a berserker or medic")
    achievements(8)=(title="Master Demolitions",description="Enrage 10 scrakes with explosives",maxProgress=10,notifyIncrement=0.5)
    achievements(9)=(title="Demolitions God",description="Be killed by your own explosive 25 times",maxProgress=25,notifyIncrement=0.2)
    achievements(10)=(title="Useless Baggage",description="Win a match, having died every wave starting from wave 1")
    achievements(11)=(title="Sharp Shooter",description="Body shot scrakes 10 times with the M99",maxProgress=10,notifyIncrement=0.5)
}
