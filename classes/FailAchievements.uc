class FailAchievements extends AchievementPackPartImpl;

enum FailIndex {
    GORED_FAST, EXPLOSIVES_EXPERT
};

var bool diedCurrentWave;

function isScrakeRaged(ZombieScrake scrake, optional float healthOffset) {
    return Level.Game.GameDifficulty < 5.0 && (zsc.Health - healthOffset) < 0.5 * zsc.HealthMax 
        || (zsc.Health - healthOffset) < 0.75 * zsc.HealthMax
}

function MatchStarting() {
    achievements[].canEarn= true;
}

event matchEnd(string mapname, float difficulty, int length, byte result) {
    if (achievements[].canEarn) {
        achievementCompleted();
    }
}

event waveStart(int waveNum) {
    diedCurrentWave= false;
}

event waveEnd(int waveNum) {
    if (!diedCurrentWave) {
        achievements[].canEarn= false;
    }
}

event playerDied(Controller killer, class<DamageType> damageType) {
    if (KFMonster(Killer.Pawn) != none && KFMonster(Killer.Pawn).bDecapitated) {
        achievementCompleted(GORED_FAST);
    }
    if (KFPawn(PlayerController(Owner).Pawn).ShieldStrength == KFPawn(PlayerController(Owner).Pawn).ShieldStrengthMax) {
        achievementCompleted();
    }
    if ((class<DamTypeFrag>(damageType) != none || class<DamTypeM79Grenade>(damageType) != none || 
            class<DamTypeM203Grenade>(damageType) != none) && (ZombieBloat(Killer.Pawn) != none || ZombieHusk(Killer.Pawn) != none) {
        achievementCmpleted();
    }
    diedCurrentWave= true;
}

event killedMonster(Pawn target, class<DamageType> damageType) {
    if (ZombieBloat(target) != none && ZombieBloat(target).bDecapitated && damageType == class'PipeBombProjectile'.default.MyDamageType) {
        addProgress(EXPLOSIVES_EXPERT, 1);
    } else if (ZombieStalker(target) != none && damageType == class'KFMod.DamTypeRocketImpact') {
        addProgress(, 1);
    }
}

event playerDied(Controller killer, class<DamageType> damageType) {
    local Weapon currWpn;

    currWpn= PlayerController(Owner).Pawn.Weapon;
    if (Syringe(currWpn) != none || Welder(currWpn) != none || Knife(currWpn) != none) {
        addProgress(,1);
    }
    if (Level.Game.GameDifficulty <= 2) {
        achievementCompleted(LEVEL_6_PRO, 1);
    }
    if (damageType == class'KFBloatVomit'.default.MyDamageType && (KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill == class'KFVetBerserker' || KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill == class'KFVetFieldMedic')) {
        achievementCompleted(, 1);
    }
}

event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot) {
    if (ZombieFleshpound(target) != none && damageType != class'SingleFire'.default.DamageType && damage < target.Health && 
            (!target.IsInState('BeginRaging') && !target.IsInState('RageCharging')) && 
            ZombieFleshpound(target).TwoSecondDamageTotal + damage > ZombieFleshpound(target).RageDamageThreshold) {
        achievementCompleted(, 1);
    }
    if ((ZombieFleshpound(target) != none || ZombieScrake(target) != none) && KFMonster(target).BurnDown == 10) {
        addProgress(, 1);
    }
    if (ZombieScrake(target) != none && !isScrakeRaged(ZombieScrake(target), 0) && isScrakeRaged(ZombieScrake(target), damage) && 
            (class<DamTypeFrag>(damageType) != none || class<DamTypeM79Grenade>(damageType) != none || 
            class<DamTypeM203Grenade>(damageType) != none)) {
        addProgress(, 1);
    }
}

defaultproperties {
    packName= "Fail Pack"

    achievements(0)=(title="Gored Fast",description="Be killed by a headless gorefast")
    achievements(1)=(title="Explosives Expert",description="Kill 20 headless bloats with pipe bombs",maxProgress=20,notifyIncrement=0.20)
    achievements(2)=(title="",description="Die with your syringe, welder, or knife out 10 times",maxProgress=10,notifyIncrement=0.5)
    achievements(3)=(title="Level 6 Pro",description="Die on wave 1 with a level 6 perk on normal difficulty")
    achievements(4)=(title="",description="Kill 20 stalkers with impact damage from explosives",maxProgress=20,notifyIncrement=0.20)
    achievements(5)=(title="",description="Be killed while still having full armor")
    achievements(6)=(title="",description="Enrage a fleshpound with the 9mm or dual 9mm")
    achievements(7)=(title="",description="Light 20 scrakes or fleshpounds on fire",maxProgress=20,notifyIncrement=0.20)
    achievements(8)=(title="",description="Be killed by bloat bile as a berserker or medic")
    achievements(9)=(title="",description="Enrage 50 scrakes with explosives",maxProgress=50,notifyIncrement=0.1)
    achievements(10)=(title="",description="Be killed by your own explosive, detonated by bloat bile or a husk fireball")
    achievements(11)=(title="",description="Win a full match, having died every wave")
}
