class StockKFAchievements extends StockAchievements;

enum StockIndex {
    EXPERIMENTICIDE, FACIST_DIETITIAN, HOMERS_HEROES, KEEP_THOSE_SNEAKERS, RANDOM_AXE,
    BITTER_IRONY, HOT_CROSS_FUN, DIGNITY_FOR_THE_DEAD, CAREFUL_SPENDER, TOO_CLOSE, MASTER_SURGEON,
    ITS_WHATS_INSIDE, QUARTER_POUNDER, SELF_MEDICATOR, THIN_ICE, PHILANTHROPIST, STRAIGHT_RUSH,
    BROKE_THE_CAMELS_BACK, DEATH_TO_THE_MAD_SCIENTIST, EXPERIMENTIMILLICIDE, EXPERIMENTILOTTACIDE, 
    EXPLOSIVE_PERSONALITY, FLAMING_HELL, MERRY_MEN, BLOOPER_REEL, DOT_OF_DOOM, SCARD, 
    HEALING_TOUCH, POUND_THIS, KILLER_JUNIOR, LET_THEM_BURN, BURNING_IRONY,
    HIGHLANDER, BLOODY_YANKS, FINISH_HIM, I_LOVE_ZE_HEALING, ITALIAN_MEAT_PASTA, FEELING_LUCKY,
    COWBOY, SPEC_OPS, COMBAT_MEDIC, FUGLY, BRITISH_SUPERIORITY, THE_BIG_ONE, HISTORICAL_REMNANTS,
    NAILD, TRENCH_WARFARE, HAVE_MY_AXE, ONE_SMALL_STEP, GAME_OVER_MAN, SINGLE_SHOT_EQUALIZER,
    FLAYER_ORDINANCE, DOOM_BOMBARDIER, TURBO_EXECUTIONER,
    CLAW_MACHINE_MASTER, EX_SCIENTIST, BLINDING_BIG_BROTHER, 
    DR_JONES,
    TOTALLY_METAL, NITRO_BOOST, MULTI_PASS, SCIENCE_HATER, RICH_EVIL_UNCLE, OKTOBERFEST_MASTER,
    SKULL_CRACKER, ALL_SHOOK_UP
};

struct CounterAchievement {
    var BEResettableCounter counter;
    var StockIndex achvIndex;
};

var int m4MagKills, benelliMagKills, revolverMagKills, mk23MagClotKills, mkb42Kills, clawMachineStart, 
        nitroBoostStart;
var bool survivedWave, canEarnThinIce, killedwithBullpup, killedWithFnFal;
var bool claymoreScKill, claymoreFpKill, claymoreBossKill, failedExScientist, canEarnBallHero, isKeyCardObj;
var array<byte> speciesKilled;
var array<Pawn> gibbedMonsters, m14MusketHeadShotKill;
var ObjCondition_Counter exScientist, totallyMetal;
var ObjCondition_Timed clawMachine, nitroBoost;
var array<CounterAchievement> counters;

function MatchStarting() {
    canEarnBallHero= true;
}

function insertCounter(BEResettableCounter counter, StockIndex index) {
    counters.Length= counters.Length + 1;
    counters[counters.Length - 1].counter= counter;
    counters[counters.Length - 1].achvIndex= index;
}

function PostBeginPlay() {
    local BEResettableCounter achvCounter;

    foreach DynamicActors(class'BEResettableCounter', achvCounter) {
        if (achvCounter.NumToCount > 0) {
            if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.FrightyardCamerasEventName) {
                insertCounter(achvCounter, StockIndex.BLINDING_BIG_BROTHER);
            } else if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.TransitDNAVialsEventName) {
                insertCounter(achvCounter, StockIndex.SCIENCE_HATER);
            } else if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.SirensBelchBeerSteinsEventName) {
                insertCounter(achvCounter, StockIndex.OKTOBERFEST_MASTER);
            } else if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.StrongholdGoldBagsEventName) {
                insertCounter(achvCounter, StockIndex.RICH_EVIL_UNCLE);
            } else if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.ClandestineSkullsEventName) {
                insertCounter(achvCounter, StockIndex.SKULL_CRACKER);
            } else if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.ThrillsChillsSnowglobeEventName) {
                insertCounter(achvCounter, StockIndex.ALL_SHOOK_UP);
            }
        }
    }

    SetTimer(1.0, true);
}

function Timer() {
    local int i;

    for(i= 0; i < counters.Length; i++) {
        checkCounter(counters[i].counter.NumToCount, counters[i].achvIndex);
    }
    if (exScientist != none && exScientist.NumCounted != 0) {
        failedExScientist= true;
    } else if (clawMachine != none && clawMachine.bActive && clawMachineStart == 0) {
        clawMachineStart= Level.TimeSeconds;
    } else if (isKeyCardObj && KFHumanPawn_Story(ownerController.Pawn).bHasStoryItem) {
        achievementCompleted(StockIndex.MULTI_PASS);
        isKeyCardObj= false;
    }
}

function resetCounters() {
    achievements[StockIndex.RANDOM_AXE].progress= 0;
    achievements[StockIndex.BITTER_IRONY].progress= 0;
    achievements[StockIndex.MASTER_SURGEON].progress= 0;
}

function addM14MusketHeadShotKill(Pawn monster) {
    local int i;
    for(i= 0; i < m14MusketHeadShotKill.Length && m14MusketHeadShotKill[i] != monster; i++) {
    }
    if (i >= m14MusketHeadShotKill.Length) {
        m14MusketHeadShotKill[m14MusketHeadShotKill.Length]= monster;
    }
}

function checkCowboy() {
    local bool hasDual9mm, hasDualHC, hasDualRevolver;
    local Inventory inv;

    for(inv= Controller(Owner).Pawn.Inventory; inv != none; inv= inv.Inventory) {
        if (Dual44Magnum(inv) != none) {
            hasDualRevolver= true;
        } else if (DualDeagle(inv) != none) {
            hasDualHc= true;
        } else if (Dualies(inv) != none) {
            hasDual9mm= true;
        }
    }
    if (hasDual9mm && hasDualHC && hasDualRevolver) {
        achievementCompleted(StockIndex.COWBOY);
    }

}

function bool isGibbed(Pawn monster) {
    local int i;
    for(i= 0; i < gibbedMonsters.Length && gibbedMonsters[i] != monster; i++) {
    }
    if (i < gibbedMonsters.Length) {
        gibbedMonsters.remove(i, 1);
        return true;
    }
    return false;
}

function StockKFAchievements getStockKFAchievementsObj(array<AchievementPack> achievementPacks) {
    local int i;

    for(i= 0; i < achievementPacks.Length; i++) {
        if (achievementPacks[i].class == Self.class) {
            return StockKFAchievements(achievementPacks[i]);
        }
    }
    return none;
}

event objectiveChanged(KF_StoryObjective newObjective) {
    local int i, j, k;

    if (exScientist != none && !failedExScientist) {
        achievementCompleted(StockIndex.EX_SCIENTIST);
        exScientist= None;
    } else if (clawMachine != none && Level.TimeSeconds - clawMachineStart <= clawMachine.Duration) {
        achievementCompleted(StockIndex.CLAW_MACHINE_MASTER);
        clawMachine= None;
    } else if (nitroBoost != none) {
        if (Level.TimeSeconds - nitroBoostStart <= nitroBoost.Duration) {
            achievementCompleted(StockIndex.NITRO_BOOST);
        }
        nitroBoost= None;
    } else if (totallyMetal != none) {
        if (totallyMetal.NumToCount <= 0) {
            achievementCompleted(StockIndex.TOTALLY_METAL);
        }
        totallyMetal= None;
    } else if (isKeyCardObj && KFHumanPawn_Story(ownerController.Pawn).bHasStoryItem) {
        achievementCompleted(StockIndex.MULTI_PASS);
    }

    checkCowboy();
    resetCounters();

    isKeyCardObj= false;

    for(i= 0; i < newObjective.OptionalConditions.Length; i++) {
        for(j= 0; j < newObjective.OptionalConditions[i].ProgressEvents.Length; j++) {
            if (newObjective.OptionalConditions[i].ProgressEvents[j].EventName == class'KFSteamStatsAndAchievements'.default.FrightyardClawMasterFailedEventName) {
                clawMachineStart= Level.TimeSeconds;
                for(k= 0; k < newObjective.OptionalConditions.Length; k++) {
                    if (ObjCondition_Timed(newObjective.OptionalConditions[k]) != none) {
                        clawMachine= ObjCondition_Timed(newObjective.OptionalConditions[k]);
                        break;
                    }
                }
            } else if (newObjective.OptionalConditions[i].ProgressEvents[j].EventName == class'KFSteamStatsAndAchievements'.default.FrightyardContaminationFailedEventName) {
                for(k= 0; k < newObjective.OptionalConditions.Length; k++) {
                    if (ObjCondition_Counter(newObjective.FailureConditions[k]) != none) {
                        exScientist= ObjCondition_Counter(newObjective.FailureConditions[k]);
                        break;
                    }
                }
            } else if (newObjective.OptionalConditions[i].ProgressEvents[j].EventName == class'KFSteamStatsAndAchievements'.default.TransitNitroInXSecondsFailedEventName) {
                nitroBoostStart= Level.TimeSeconds;
                for(k= 0; k < newObjective.OptionalConditions.Length; k++) {
                    if (ObjCondition_Timed(newObjective.OptionalConditions[k]) != none) {
                        nitroBoost= ObjCondition_Timed(newObjective.OptionalConditions[k]);
                        break;
                    }
                }
            }
        }
    }
    for(i= 0; i < newObjective.SuccessConditions.Length; i++) {
        for(j= 0; j < newObjective.SuccessConditions[i].ProgressEvents.Length; j++) {
            if (newObjective.SuccessConditions[i].ProgressEvents[j].EventName == class'KFSteamStatsAndAchievements'.default.TransitPickUpKeyEventName) {
                isKeyCardObj= true;
                break;
            } else if (newObjective.SuccessConditions[i].ProgressEvents[j].EventName == class'KFSteamStatsAndAchievements'.default.TransitKillXZedsDuringWeldEventName) {
                for(k= 0; k < newObjective.SuccessConditions.Length; k++) {
                    if (ObjCondition_Counter(newObjective.SuccessConditions[k]) != none) {
                        totallyMetal= ObjCondition_Counter(newObjective.SuccessConditions[k]);
                        break;
                    }
                }
            }
        }
    }
}

event waveEnd(int waveNum) {
    local SAReplicationInfo saRepInfo;
    local bool onlySurvivor;
    local Controller C;

    if (survivedWave && canEarnThinIce) {
        onlySurvivor= true;
        for(C= Level.ControllerList; C != none; C= C.NextController) {
            if (PlayerController(C) != none && C != Controller(Owner) && !C.PlayerReplicationInfo.bOnlySpectator) {
                saRepInfo= class'SAReplicationInfo'.static.findSARI(C.PlayerReplicationInfo);
                onlySurvivor= onlySurvivor && !getStockKFAchievementsObj(saRepInfo.achievementPacks).survivedWave;
            }
        }
        if (onlySurvivor) {
            addProgress(StockIndex.THIN_ICE, 1);
        }
    }
}

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum) {
    local Controller cIt;
    local PlayerController pc;

    if (result == 2 && difficulty >= 5.0) {
        achievementCompleted(StockIndex.DEATH_TO_THE_MAD_SCIENTIST);
    }
    if (claymoreScKill && claymoreFpKill && claymoreBossKill) {
        achievementCompleted(StockIndex.HIGHLANDER);
    } else if (allSpeciesKilled(speciesKilled)) {
        achievementCompleted(StockIndex.FUGLY);
    }

    if (canEarnBallHero && mapname ~= "kf-hell" && length == KFGameType(Level.Game).GL_Short) {
        for(cIt= Level.ControllerList; cIt != None; cIt= cIt.NextController) {
            pc= PlayerController(cIt);
            if (pc != none && (KFPawn(pc.Pawn).Species == class'KFMod.CivilianSpeciesBallHero' || KFPawn(pc.Pawn).Species == class'KFMod.CivilianSpeciesBallHeroII')) {
                achievementCompleted(StockIndex.DR_JONES);
            }
        }
    }
}

event waveStart(int waveNum) {
    survivedWave= true;
    canEarnThinIce= Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1;

    checkCowboy();
    resetCounters();
}

event playerDied(Controller killer, class<DamageType> damageType, int waveNum) {
    survivedWave= false;
}

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot) {
    local Controller C;
    local KFPlayerReplicationInfo kfRepInfo;
    local SAReplicationInfo saRepInfo;
    local StockKFAchievements stockKFAchievementObj;

    addProgress(StockIndex.EXPERIMENTICIDE, 1);
    addProgress(StockIndex.EXPERIMENTIMILLICIDE, 1);
    addProgress(StockIndex.EXPERIMENTILOTTACIDE, 1);
    kfRepInfo= KFPlayerReplicationInfo(ownerController.PlayerReplicationInfo);

    if (KFMonster(target) != none && KFMonster(target).bZapped) {
        saRepInfo= class'SAReplicationInfo'.static.findSARI(KFMonster(target).ZappedBy.PlayerReplicationInfo);
        getStockKFAchievementsObj(saRepInfo.achievementPacks).addProgress(StockIndex.GAME_OVER_MAN, 1);
    }

    if (isGibbed(target)) {
        addProgress(StockIndex.ITS_WHATS_INSIDE, 1);
        if (ZombieFleshpound(target) != none) {
            addProgress(StockIndex.QUARTER_POUNDER, 1);
        }
        if (damageType == class'DamTypeM79Grenade') {
            addProgress(StockIndex.BLOOPER_REEL, 1);
        }
    }

    if (target.IsA('ZombieBloat')) {
        addProgress(StockIndex.FACIST_DIETITIAN, 1);
    } else if (target.IsA('ZombieSiren')) {
        addProgress(StockIndex.HOMERS_HEROES, 1);
    } else if (target.IsA('ZombieStalker')) {
        if (ClassIsChildOf(damageType, class'DamTypeFrag')) {
            addProgress(StockIndex.KEEP_THOSE_SNEAKERS, 1);
        } else if (ClassIsChildOf(damageType, class'DamTypeNailGun')) {
            addProgress(StockIndex.NAILD, 1);
        }
    } else if (target.IsA('ZombieScrake')) {
        if (ClassIsChildOf(damageType, class'DamTypeChainsaw')) {
            addProgress(StockIndex.BITTER_IRONY, 1);
        } else if (ClassIsChildOf(damageType, class'DamTypeClaymoreSword')) {
            claymoreScKill= true;
        } else if (ClassIsChildOf(damageType, class'DamTypeM203Grenade')) {
            achievementCompleted(StockIndex.FINISH_HIM);
        } else if (ClassIsChildOf(damageType, class'DamTypeM99SniperRifle') || ClassIsChildOf(damageType, class'DamTypeM99HeadShot')) {
            addProgress(StockIndex.THE_BIG_ONE, 1);
        }
    } else if (target.IsA('ZombieFleshpound')) {
        if (ClassIsChildOf(damageType, class'DamTypeMelee')) {
            achievementCompleted(StockIndex.TOO_CLOSE);
        } else if (ClassIsChildOf(damageType, class'DamTypeAA12Shotgun')) {
            addProgress(StockIndex.POUND_THIS, 1);
        } else if (ClassIsChildOf(damageType, class'DamTypeClaymoreSword')) {
            claymoreFpKill= true;
        } else if (ClassIsChildOf(damageType, class'DamTypeDwarfAxe') && KFMonster(target).bBackstabbed) {
            addProgress(StockIndex.HAVE_MY_AXE, 1);
        }
    } else if (target.IsA('ZombieBoss')) {
        if (ClassIsChildOf(damageType, class'DamTypeLaw')) {
            achievementCompleted(StockIndex.BROKE_THE_CAMELS_BACK);
        } else if (ClassIsChildOf(damageType, class'DamTypeClaymoreSword')) {
            claymoreBossKill= true;
        }
        if (!ZombieBoss(target).bHealed) {
            for(C= Level.ControllerList; C != none; C= C.NextController) {
                if (PlayerController(C) != none && !C.PlayerReplicationInfo.bOnlySpectator) {
                    saRepInfo= class'SAReplicationInfo'.static.findSARI(C.PlayerReplicationInfo);
                    stockKFAchievementObj= getStockKFAchievementsObj(saRepInfo.achievementPacks);
                    stockKFAchievementObj.achievementCompleted(StockIndex.STRAIGHT_RUSH);
                }
            }
        }
        if (ZombieBoss(target).bOnlyDamagedByCrossbow) {
            achievementCompleted(StockIndex.MERRY_MEN);
        }
    } else if (target.IsA('ZombieCrawler') && target.Physics == PHYS_Falling && ClassIsChildOf(damageType, class'DamTypeM79Grenade')) {
        addProgress(StockIndex.KILLER_JUNIOR, 1);
    } else if (target.IsA('ZombieHusk')) {
        if (!ZombieHusk(target).bDamagedAPlayer && (ClassIsChildOf(damageType, class'DamTypeBurned') || ClassIsChildOf(damageType, class'DamTypeFlamethrower'))) {
            achievementCompleted(StockIndex.FLAMING_HELL);
        } else if (ClassIsChildOf(damageType, class'DamTypeHuskGun') || ClassIsChildOf(damageType, class'DamTypeHuskGunProjectileImpact')) {
            addProgress(StockIndex.BURNING_IRONY, 1);
        }
    } else if (target.IsA('ZombieClot') && ClassIsChildOf(damageType, class'DamTypeMK23Pistol')) {
        mk23MagClotKills++;
    }

    if (ClassIsChildOf(damageType, class'DamTypeAxe')) {
        addProgress(StockIndex.RANDOM_AXE, 1);
    } else if ((ClassIsChildOf(damageType, class'DamTypeCrossbow') || ClassIsChildOf(damageType, class'DamTypeCrossbowHeadShot')) 
            && target.IsA('KFMonster') && KFMonster(target).bBurnified) {
        addProgress(StockIndex.HOT_CROSS_FUN, 1);
    } else if (ClassIsChildOf(damageType, class'DamTypeKnife') && 
            class'VeterancyChecks'.static.isFieldMedic(KFPlayerReplicationInfo(ownerController.PlayerReplicationInfo))) {
        addProgress(StockIndex.MASTER_SURGEON, 1);
    } else if (ClassIsChildOf(damageType, class'DamTypePipebomb') && 
            kfRepInfo.ClientVeteranSkill.static.AddDamage(kfRepInfo, None, None, 1, class'DamTypePipeBomb') > 1.0) {
        addProgress(StockIndex.EXPLOSIVE_PERSONALITY, 1);
    } else if (ClassIsChildOf(damageType, class'DamTypeSCARMK17AssaultRifle')) {
        addProgress(StockIndex.SCARD, 1);
    } else if (ClassIsChildOf(damageType, class'DamTypeM4AssaultRifle')) {
        m4MagKills++;
    } else if (ClassIsChildOf(damageType, class'DamTypeBenelli')) {
        benelliMagKills++;
    } else if (ClassIsChildOf(damageType, class'DamTypeMagnum44Pistol')) {
        revolverMagKills++;
    } else if (ClassIsChildOf(damageType, class'DamTypeM7A3M') && KFMonster(target).bDamagedAPlayer) {
        achievementCompleted(StockIndex.COMBAT_MEDIC);
    } else if (ClassIsChildOf(damageType, class'DamTypeBullpup')) {
        killedWithBullpup= true;
    } else if (ClassIsChildOf(damageType, class'DamTypeFNFALAssaultRifle')) {
        killedWithFnFal= true;
    } else if (ClassIsChildOf(damageType, class'DamTypeMkb42AssaultRifle')) {
        mkb42Kills++;
    } else if (ClassIsChildOf(damageType, class'DamTypeTrenchgun')) {
        addProgress(StockIndex.TRENCH_WARFARE, 1);
    } else if (ClassIsChildOf(damageType, class'DamTypeKSGShotgun')) {
        updateKillTypes(speciesKilled, target.class);
    } else if (ClassIsChildOf(damageType, class'DamTypeDBShotgun')) {
        addProgress(StockIndex.CAREFUL_SPENDER, 1);
        if (ZombieScrake(target) != none && VSize(ZombieScrake(target).LastMomentum) > 5000) {
            achievementCompleted(StockIndex.FLAYER_ORDINANCE);
        }
    } else if (ClassIsChildOf(damageType, class'DamTypeKrissM') && ownerController.Pawn != none && 
            ownerController.Pawn.Physics == PHYS_Falling) {
        addProgress(StockIndex.ONE_SMALL_STEP, 1);
    } else if (headshot && (ClassIsChildOf(damageType, class'DamTypeM14EBR') || ClassIsChildOf(damageType, class'DamTypeSPSniper'))) {
        addM14MusketHeadShotKill(target);
        if (m14MusketHeadShotKill.Length == 4) {
            achievementCompleted(StockIndex.SINGLE_SHOT_EQUALIZER);
        }
    } else if (class<DamTypeRocketImpact>(damageType) != none && class<DamTypeLawRocketImpact>(damageType) == none) {
        achievementCompleted(StockIndex.DOOM_BOMBARDIER);
    } 

    if (KFGameType(Level.Game).bZEDTimeActive && (ClassIsChildOf(damageType, class'DamTypeBullpup') || 
            ClassIsChildOf(damageType, class'DamTypeSPThompson'))) {
        addProgress(StockIndex.TURBO_EXECUTIONER, 1);
    }
    if (killedWithBullpup && killedWithFnFal) {
        achievementCompleted(StockIndex.BRITISH_SUPERIORITY);
    }

    if (Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 && target.AnimAction == 'ZombieFeed') {
        addProgress(StockIndex.DIGNITY_FOR_THE_DEAD, 1);
    }
}

event pickedUpItem(Pickup item) {
    local SAReplicationInfo saRepInfo;

    if (CashPickup(item) != none && CashPickup(item).DroppedBy != none && 
            Controller(Owner).PlayerReplicationInfo != CashPickup(item).DroppedBy.PlayerReplicationInfo) {
        if ((CashPickup(item).DroppedBy.PlayerReplicationInfo.Score + float(CashPickup(item).CashAmount)) >= 
                0.50 * Controller(Owner).PlayerReplicationInfo.Score) {
            saRepInfo= class'SAReplicationInfo'.static.findSARI(CashPickup(item).DroppedBy.PlayerReplicationInfo);
            getStockKFAchievementsObj(saRepInfo.achievementPacks).addProgress(StockIndex.PHILANTHROPIST, CashPickup(item).CashAmount);
        }
    } else if (WeaponPickup(item) != none) {
        checkCowboy();
    }
}

event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot) {
    if (target.IsA('KFMonster')) {
        if (headshot && KFMonster(target).bDecapitated) {
            if (KFMonster(target).bLaserSightedEBRM14Headshotted) {
                addProgress(StockIndex.DOT_OF_DOOM, 1);
            } else {
                achievements[StockIndex.DOT_OF_DOOM].progress= 0;
            }
        }
        if ( target.Health - damage <= 0 && damage > damageType.default.HumanObliterationThreshhold && damage != 1000 && 
                (!KFMonster(target).bDecapitated || KFMonster(target).bPlayBrainSplash)) {
            gibbedMonsters[gibbedMonsters.Length]= target;
        }
    }
    if (ClassIsChildOf(damageType, class'DamTypeMAC10MPInc')) {
        addProgress(StockIndex.LET_THEM_BURN, min(damage, target.Health));
    }
}

event touchedHealDart(HealingProjectile healDart) {
    local SAReplicationInfo saRepInfo;
    local float healSum;
    local KFPlayerReplicationInfo kfRepInfo;
    local KFPawn target;

    target= KFPawn(Controller(Owner).Pawn);
    kfRepInfo= KFPlayerReplicationInfo(healDart.Instigator.PlayerReplicationInfo);
    healSum= kfRepInfo.ClientVeteranSkill.Static.GetHealPotency(kfRepInfo);
    healSum= max(target.HealthMax - (target.Health + target.HealthToGive + healSum), 0);
    if (healSum > 0) {
        if (MP5MHealinglProjectile(healDart) != none) {
            saRepInfo= class'SAReplicationInfo'.static.findSARI(kfRepInfo);
            getStockKFAchievementsObj(saRepInfo.achievementPacks).addProgress(StockIndex.I_LOVE_ZE_HEALING, healSum);
        } else if (MP7MHealinglProjectile(healDart) != none) {
            saRepInfo= class'SAReplicationInfo'.static.findSARI(kfRepInfo);
            getStockKFAchievementsObj(saRepInfo.achievementPacks).addProgress(StockIndex.HEALING_TOUCH, 1);
        }
    }
}

event reloadedWeapon(KFWeapon weapon) {
    if (M4AssaultRifle(weapon) != none) {
        if (weapon.MagAmmoRemaining == 0 && m4MagKills == 1) {
            achievementCompleted(StockIndex.BLOODY_YANKS);
        }
        m4MagKills= 0;
    } else if (BenelliShotgun(weapon) != none) {
        if (weapon.MagAmmoRemaining == 0 && benelliMagKills >= 12) {
            achievementCompleted(StockIndex.ITALIAN_MEAT_PASTA);
        }
        benelliMagKills= 0;
    } else if (Magnum44Pistol(weapon) != none) {
        if (weapon.MagAmmoRemaining == 0 && revolverMagKills >= weapon.MagCapacity) {
            achievementCompleted(StockIndex.FEELING_LUCKY);
        }
        revolverMagKills= 0;
    } else if (MK23Pistol(weapon) != none) {
        if (mk23MagClotKills >= 12) {
            achievementCompleted(StockIndex.SPEC_OPS);
        }
        mk23MagClotKills= 0;
    } else if (Mkb42AssaultRifle(weapon) != none) {
        if (mkb42Kills >= 6) {
            achievementCompleted(StockIndex.HISTORICAL_REMNANTS);
        }
        mkb42Kills= 0;
    } else if (M14EBRBattleRifle(weapon) != none || SPSniperRifle(weapon) != none) {
        m14MusketHeadShotKill.Length= 0;
    }
}

event firedWeapon(KFWeapon weapon) {
    if (M99SniperRifle(weapon) != none) {
        achievements[StockIndex.THE_BIG_ONE].progress= 0;
    } else if (BoomStick(weapon) != none) {
        achievements[StockIndex.CAREFUL_SPENDER].progress= 0;
    } else if (Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 && Syringe(weapon) != none && weapon.GetFireMode(1).bIsFiring) {
        addProgress(StockIndex.SELF_MEDICATOR, 1);
    } else if (achievements[StockIndex.FLAYER_ORDINANCE].completed == 0 && SPAutoShotgun(weapon) != none && weapon.GetFireMode(1).bIsFiring) {
        checkAltFireVictims(weapon);
    }
}

function checkAltFireVictims(KFWeapon weapon) {
    local ZombieScrake victim;
    local Vector startTrace;

    startTrace = weapon.Instigator.Location + weapon.Instigator.EyePosition();
    foreach Weapon.VisibleCollidingActors(class'ZombieScrake', Victim, (class'SPShotgunAltFire'.default.PushRange * 2), startTrace) {
        achievementCompleted(StockIndex.FLAYER_ORDINANCE);
        break;
    }
}

defaultproperties {
    packName= "Stock KF"

    achievements(0)=(title="Experimenticide",description="Kill 100 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_18',maxProgress=100,notifyIncrement=1.0)
    achievements(1)=(title="Fascist Dietitian",description="Kill 200 bloats",image=Texture'KillingFloorHUD.Achievements.Achievement_21',maxProgress=200,notifyIncrement=0.1)
    achievements(2)=(title="Homer's Heroes",description="Kill 100 sirens",image=Texture'KillingFloorHUD.Achievements.Achievement_22',maxProgress=100,notifyIncrement=0.2)
    achievements(3)=(title="Keep Those Sneakers Off the Floor!",description="Kill 20 stalkers with explosives",image=Texture'KillingFloorHUD.Achievements.Achievement_23',maxProgress=20,notifyIncrement=0.25)
    achievements(4)=(title="Random Axe of Kindness",description="Kill 15 specimens with a fire axe in a single wave",maxProgress=15,noSave=true,image=Texture'KillingFloorHUD.Achievements.Achievement_24')
    achievements(5)=(title="Bitter Irony",description="Kill 2 scrakes with a chainsaw in a single wave",maxProgress=2,noSave=true,image=Texture'KillingFloorHUD.Achievements.Achievement_25')
    achievements(6)=(title="Hot Cross Fun",description="Kill 25 burning specimens with a crossbow",image=Texture'KillingFloorHUD.Achievements.Achievement_26',maxProgress=25,notifyIncrement=0.2)
    achievements(7)=(title="Dignity for the Dead",description="Kill 10 specimens feeding on dead teammates' corpses",image=Texture'KillingFloorHUD.Achievements.Achievement_27',maxProgress=10,notifyIncrement=0.5)
    achievements(8)=(title="Careful Spender",description="Kill 4 specimens with a single shot from a hunting shotgun",maxProgress=4,noSave=true,image=Texture'KillingFloorHUD.Achievements.Achievement_29')
    achievements(9)=(title="Too Close For Comfort",description="Finish off a fleshpound using a melee attack",image=Texture'KillingFloorHUD.Achievements.Achievement_31')
    achievements(10)=(title="Master Surgeon",description="As a medic, kill 8 specimens using a knife in a single wave",maxProgress=8,noSave=true,image=Texture'KillingFloorHUD.Achievements.Achievement_32')
    achievements(11)=(title="It's What's Inside That Counts",description="Turn 500 specimens into giblets",image=Texture'KillingFloorHUD.Achievements.Achievement_33',maxProgress=500,notifyIncrement=0.25)
    achievements(12)=(title="Quarter Pounder With Ease",description="Turn 5 fleshpounds into giblets",image=Texture'KillingFloorHUD.Achievements.Achievement_34',maxProgress=5,notifyIncrement=1.0)
    achievements(13)=(title="Self Medicator",description="In co-op mode, use the syringe on yourself 100 times",image=Texture'KillingFloorHUD.Achievements.Achievement_35',maxProgress=100,notifyIncrement=0.2)
    achievements(14)=(title="Thin-Ice Pirouette",description="Complete 10 waves when the rest of your team has died",image=Texture'KillingFloorHUD.Achievements.Achievement_36',maxProgress=10,notifyIncrement=0.5)
    achievements(15)=(title="Philanthropist",description="Give 1,000 pounds to teamamtes who have 50% of your cash or less",image=Texture'KillingFloorHUD.Achievements.Achievement_37',maxProgress=1000,notifyIncrement=1.0)
    achievements(16)=(title="Straight Rush",description="Kill the patriarch before he has a chance to heal",image=Texture'KillingFloorHUD.Achievements.Achievement_40')
    achievements(17)=(title="The L.A.W. That Broke The Camel's Back",description="Deliver the Killing Blow to the Patriarch with a L.A.W. Rocket",image=Texture'KillingFloorHUD.Achievements.Achievement_41')
    achievements(18)=(title="Death To the Mad Scientist",description="Defeat the Patriarch on Suicidal",image=Texture'KillingFloorHUD.Achievements.Achievement_42')
    achievements(19)=(title="Experimentimillicide",description="Kill 1,000 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_19',maxProgress=1000,notifyIncrement=0.5)
    achievements(20)=(title="Experimentilottacide",description="Kill 10,000 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_20',maxProgress=10000,notifyIncrement=0.25)
    achievements(21)=(title="Explosive Personality",description="As Demolitions, kill 1000 specimens with the the pipebomb",image=Texture'KillingFloor2HUD.Achievements.Achievement_56',maxProgress=1000,notifyIncrement=0.1)
    achievements(22)=(title="Flaming Hell, That was Close",description="As Firebug, kill the husk with the flamethrower before he hurts anyone",image=Texture'KillingFloor2HUD.Achievements.Achievement_57')
    achievements(23)=(title="Merry Men",description="Kill the patriarch when everyone is ONLY using crossbows",image=Texture'KillingFloor2HUD.Achievements.Achievement_58')
    achievements(24)=(title="Blooper Reel",description="Turn 500 Zeds into giblets using the M79",image=Texture'KillingFloor2HUD.Achievements.Achievement_59',maxProgress=500,notifyIncrement=0.25)
    achievements(25)=(title="Dot of Doom",description="Get 25 headshots in a row with the EBR while using the laser sight",maxProgress=25,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_60')
    achievements(26)=(title="SCAR'd",description="Kill 1000 specimens with the SCAR",image=Texture'KillingFloor2HUD.Achievements.Achievement_62',maxProgress=1000,notifyIncrement=0.25)
    achievements(27)=(title="Healing Touch",description="Heal 200 teammates with the MP7's medication dart",image=Texture'KillingFloor2HUD.Achievements.Achievement_63',maxProgress=200,notifyIncrement=0.20)
    achievements(28)=(title="Pound This",description="Kill 100 fleshpounds with the AA12",image=Texture'KillingFloor2HUD.Achievements.Achievement_64',maxProgress=100,notifyIncrement=0.2)
    achievements(29)=(title="Killer Junior",description="Kill 20 crawlers in mid-air with the M79",image=Texture'KillingFloor2HUD.Achievements.Achievement_63',maxProgress=20,notifyIncrement=0.5)
    achievements(30)=(title="Let Them Burn",description="Get 1000 points of burn damage with the MAC-10",image=Texture'KillingFloor2HUD.Achievements.Achievement_113',maxProgress=1000,notifyIncrement=1.0)
    achievements(31)=(title="Burning Irony",description="Kill 15 husks with the Husk Cannon",image=Texture'KillingFloor2HUD.Achievements.Achievement_163',maxProgress=15,notifyIncrement=0.33333)
    achievements(32)=(title="Highlander",description="Kill a scrake, a fleshpound, and the patriarch with the Claymore sword within one map",image=Texture'KillingFloor2HUD.Achievements.Achievement_164')
    achievements(33)=(title="Bloody Yanks",description="Kill 1 specimen ONLY while expending a full M4 Assault Rifle magazine",image=Texture'KillingFloor2HUD.Achievements.Achievement_165')
    achievements(34)=(title="Finish Him",description="Hit a scrake with the M203 Rifle grenade to kill him",image=Texture'KillingFloor2HUD.Achievements.Achievement_166')
    achievements(35)=(title="I love ze Healing not ze Hurting",description="Heal others for 3000 points of health with the MP5 SMG",image=Texture'KillingFloor2HUD.Achievements.Achievement_167',maxProgress=3000,notifyIncrement=0.33333)
    achievements(36)=(title="Italian Meat Pasta",description="Kill 12 zeds with a full magazine from the Combat Shotgun",image=Texture'KillingFloor2HUD.Achievements.Achievement_168')
    achievements(37)=(title="Feeling Lucky?",description="Kill a specimen with every shot from your Revolver for one magazine",image=Texture'KillingFloor2HUD.Achievements.Achievement_169')
    achievements(38)=(title="We Have Ourselves a Cowboy",description="Hold Dual 9mm, Dual Hand Cannons, and Dual Revolvers",image=Texture'KillingFloor2HUD.Achievements.Achievement_170')
    achievements(39)=(title="Spec Ops",description="Kill 12 clots with one magazine without reloading (MK23)",image=Texture'KillingFloor2HUD.Achievements.Achievement_176')
    achievements(40)=(title="Combat Medic",description="Kill a zed that has injured a player (M7A3 rifle)",image=Texture'KillingFloor2HUD.Achievements.Achievement_177')
    achievements(41)=(title="Fugly",description="Kill one of each type of zed in one round (HSG Shotgun)",image=Texture'KillingFloor2HUD.Achievements.Achievement_178')
    achievements(42)=(title="British Superiority",description="Kill a zed each with both the Bullpup and FN-Fal",image=Texture'KillingFloor2HUD.Achievements.Achievement_179')
    achievements(43)=(title="The Big One",description="Kill 2 scrakes with one shot (M99)",image=Texture'KillingFloor2HUD.Achievements.Achievement_180')
    achievements(44)=(title="Historical Remnants",description="Kill 6 zeds with one magazine, without reloading (Mkb42)",image=Texture'KillingFloor2HUD.Achievements.Achievement_185')
    achievements(45)=(title="Nail'd!",description="Kill 4 stalkers in a game with the Nailgun",maxProgress=4,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_186')
    achievements(46)=(title="Trench Warfare",description="Set a total of 200 zeds on fire",image=Texture'KillingFloor2HUD.Achievements.Achievement_188',maxProgress=200,notifyIncrement=50)
    achievements(47)=(title="Have My Axe",description="Kill 30 fleshpounds with the Dwarfs!? axe with back attacks",image=Texture'KillingFloor2HUD.Achievements.Achievement_200',maxProgress=30,notifyIncrement=0.33333)
    achievements(48)=(title="One Small Step for Man",description="Kill 500 zeds with the Schneidzekk Medic Gun while you are falling",image=Texture'KillingFloor2HUD.Achievements.Achievement_201',maxProgress=500,notifyIncrement=0.1)
    achievements(49)=(title="Game Over, Man!",description="Have 20 zeds you slowed with the Z.E.D. gun killed",image=Texture'KillingFloor2HUD.Achievements.Achievement_203',maxProgress=20,notifyIncrement=1.0)
    achievements(50)=(title="Single-shot Equalizer",description="Kill 4 different types of Zeds with 4 headshots from the Long Musket or the M14 without reloading",image=Texture'KillingFloor2HUD.Achievements.Achievement_223')
    achievements(51)=(title="Assault Flayer Ordinance",description="Push a scrake back with the direct fire from a Hunting Shotgun or alt fire from the Multi-Chamber ZED Thrower",image=Texture'KillingFloor2HUD.Achievements.Achievement_224')
    achievements(52)=(title="Single-Load Doom Bombardier",description="Kill a ZED with an impact shot from the Orca Bomb Propeller or the M79/M32",image=Texture'KillingFloor2HUD.Achievements.Achievement_225')
    achievements(53)=(title="Turbo Executioner",description="Kill 5 zeds in ZED time without reloading with Dr. T's LDS or Bullpup",maxProgress=5,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_226')
    achievements(54)=(title="Claw Machine Master",description="Attach the crane hook within 125 seconds",image=Texture'KillingFloor2HUD.Achievements.Achievement_236')
    achievements(55)=(title="Ex-scientist",description="Collect all the bile without a contamination",image=Texture'KillingFloor2HUD.Achievements.Achievement_237')
    achievements(56)=(title="Blinding Big Brother",description="Destroy all 30 Cameras",image=Texture'KillingFloor2HUD.Achievements.Achievement_239')
    achievements(57)=(title="No Time for Love, Dr. Jones",description="Win a short round on KF-Hell playing as or with Harchier Spebbington",image=Texture'KillingFloor2HUD.Achievements.Achievement_251')
    achievements(58)=(title="Totally Metal",description="Transit - Kill 250 Zeds before completing the welding objective",image=Texture'KillingFloor2HUD.Achievements.Achievement_269')
    achievements(59)=(title="Nitro Boost!",description="Transit - Get the Nitro to the Objective in 135 seconds or less",image=Texture'KillingFloor2HUD.Achievements.Achievement_268')
    achievements(60)=(title="Multi-pass",description="Transit - Pick up the door key",image=Texture'KillingFloor2HUD.Achievements.Achievement_270')
    achievements(61)=(title="Science Hater",description="Transit - Destroy all the DNA vials",image=Texture'KillingFloor2HUD.Achievements.Achievement_271')
    achievements(62)=(title="Rich Evil Uncle",description="Collect all the Treasure Bags",image=Texture'KillingFloor2HUD.Achievements.Achievement_273')
    achievements(63)=(title="Oktoberfest Master",description="Collect all the Beer Steins",image=Texture'KillingFloor2HUD.Achievements.Achievement_274')
    achievements(64)=(title="Skull Cracker",description="Clandestine - Destroy 30 skulls",image=Texture'KillingFloor2HUD.Achievements.Achievement_279')
    achievements(65)=(title="All shook up",description="Destroy all (15) Snow Globes",image=Texture'KillingFloor2HUD.Achievements.Achievement_284')
}
