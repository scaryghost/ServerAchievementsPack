class StockEventAchievements extends StockAchievements;

enum AchvIndex {
    MERRY_CHRISTMAS, NUTCRACKER, CANT_CATCH_ME, JACK_FROST, NOT_SANTA,
    BACK_TO_WORK, RUDOLPH, SILENT_NIGHT, MRS_CLAWS, SNOW_BALL_FIGHT,
    BUCKETS_O_BLOOD, BETTER_TO_GIVE, EGGNOG,

    UBER_TUBER, GOLDEN_POTATOE,

    RINGMASTER, SPARRING_WITH_MASTER, ASSISTANT_HOMICIDE, SEEING_DOUBLE, CLOWN_ALLEY,
    BIG_HUNT, LIFTING_A_DUMBELL, SMALL_HANDS, ELEPHANT_GUN, JUGGLING_ACT, 
    WINDJAMMER, BIG_TOP, BURNING_MIDWAY,

    SPARKLING_TWILIGHT, CARVING_JACK_O_LANTERN, SCENE_IS_ZED, ZED_OCTOBER, ORDINARY_RABBIT, TRICK_NOT_TREAT,

    BLOODY_CHRISTMAS_CAROL,

    SOUL_COLLECTOR, MEET_YOUR_MAKER, CREEPY_CRAWLIES, RIPPIN_IT_UP,
    I_AM_DEATH, FIERY_PERSONALITY,

    HIDE_AND_PUKE, ARCADE_GAMER,
    FULL_CHARGE, MOTION_PROTECTOR, ASSAULT_PROTECTOR, CROWN_NOTE, 

    FIRE_AND_FORGET, UNDER_THE_WEATHER, BANG_FOR_THE_BUCK,

    ALL_RED
};

var bool failedEscort, failedDefense, damagedWithBars, goldBarsObjective, 
        killedHillbillyHuskWithM99, killedOtherHillbillyWithM99, isBedlam, killedScWithLaw, killedFpWithLaw;
var byte survivedSiren, survivedBloat;
var int screamedTime, vomitTime, axeStartTime, xmasClot, xmasStalker, xmasCrawler, xmasSiren, xmasBloat, m32KillStart;
var BEResettableCounter miniGamesCounter, clownCounter, gnomeSoulsCounter, zedGunCounter;
var array<KF_BreakerBoxNPC> breakerBoxes;
var KF_RingMasterNPC ringMaster;
var name prevObjName;
var KFUseTrigger gladosDoorTrigger;
var array<byte> ftKills;

function resetWaveCounters() {
    achievements[AchvIndex.MRS_CLAWS].progress= 0;
    achievements[AchvIndex.NOT_SANTA].progress= 0;
    achievements[AchvIndex.BACK_TO_WORK].progress= 0;
    achievements[AchvIndex.ASSISTANT_HOMICIDE].progress= 0;
    achievements[AchvIndex.SEEING_DOUBLE].progress= 0;
    achievements[AchvIndex.BACK_TO_WORK].progress= 0;
    achievements[AchvIndex.SMALL_HANDS].progress= 0;
    achievements[AchvIndex.JUGGLING_ACT].progress= 0;
}

function PostBeginPlay() {
    local BEResettableCounter achvCounter;
    local KF_BreakerBoxNPC breakerBox;
    local KFUseTrigger trigger;

    foreach DynamicActors(class'BEResettableCounter', achvCounter) {
        if (achvCounter.NumToCount > 0) {
            if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.SteamLandGamesEventName) {
                miniGamesCounter= achvCounter;
            } else if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.SteamLandClownsEventName) {
                clownCounter= achvCounter;
            } else if (achvCounter.Event == class'KFSteamStatsAndAchievements'.default.HillBillyGnomesEventName) {
                gnomeSoulsCounter= achvCounter;
            } else if (achvCounter.Event == 'ZEDWeaponCompleted') {
                zedGunCounter= achvCounter;
            }
        }
    }
    foreach DynamicActors(class'KF_BreakerBoxNPC', breakerBox) {
        breakerBoxes[breakerBoxes.Length]= breakerBox;
    }
    foreach DynamicActors(class'KFUseTrigger', trigger) {
        if (trigger.WeldStrength > 0 && trigger.event == 'goldenpd01') {
            gladosDoorTrigger= trigger;
        }
    }
    SetTimer(1.0, true);
    isBedlam= Locs(class'KFGameType'.static.GetCurrentMapName(Level)) == "kf-bedlam";
}

function StockEventAchievements getEventAchievementsObj(PlayerReplicationInfo playerRepInfo) {
    local SAReplicationInfo saRepInfo;
    local int i;

    saRepInfo= class'SAReplicationInfo'.static.findSAri(playerRepInfo);
    for(i= 0; i < saRepInfo.achievementPacks.Length; i++) {
        if (saRepInfo.achievementPacks[i].class == Self.class) {
            return StockEventAchievements(saRepInfo.achievementPacks[i]);
        }
    }
    return none;
}

event playerDamaged(int damage, Pawn instigator, class<DamageType> damageType) {
    if (KFStoryGameInfo(Level.Game) != none && goldBarsObjective && KFHumanPawn_Story(ownerController.Pawn).bHasStoryItem) {
        damagedWithBars= true;
    }
}

event objectiveChanged(KF_StoryObjective newObjective) {
    local StockEventAchievements eventAchvObj;
    local KF_RingMasterNPC iterator;
    local bool noCarriersDamaged;
    local Controller C;

    if (!failedEscort) {
        achievementCompleted(AchvIndex.MOTION_PROTECTOR);
    } else if (!failedDefense) {
        achievementCompleted(AchvIndex.ASSAULT_PROTECTOR);
    }

    noCarriersDamaged= true;
    for(C= Level.ControllerList; C != none; C= C.NextController) {
        if (PlayerController(C) != none && !C.PlayerReplicationInfo.bOnlySpectator) {
            eventAchvObj= getEventAchievementsObj(C.PlayerReplicationInfo);
            noCarriersDamaged= noCarriersDamaged && !eventAchvObj.damagedWithBars;
        }
    }
    if (noCarriersDamaged) {
        achievementCompleted(AchvIndex.CROWN_NOTE);
    }
    if (newObjective.ObjectiveName == class'KFSteamStatsAndAchievements'.default.SteamLandEscortObjName) {
        failedEscort= false;
        failedDefense= true; 
        foreach DynamicActors(class'KF_RingMasterNPC', iterator) {
            ringMaster= iterator;
            break;
        }
    } else if (newObjective.ObjectiveName == class'KFSteamStatsAndAchievements'.default.SteamLandDefendObjName) {
        failedEscort= true;
        failedDefense= false;
    }
    goldBarsObjective= newObjective.ObjectiveName == class'KFSteamStatsAndAchievements'.default.SteamLandGoldObjName;
    damagedWithBars= !goldBarsObjective;

    resetWaveCounters();
}

function bool checkTimeAchievement(out byte actionState, out int triggerTime, bool controllerState, byte achvIndex) {
    if ((controllerState || triggerTime != 0) && Level.Game.GameDifficulty >= 4.0) {
        if (triggerTime == 0) {
            triggerTime= Level.TimeSeconds;
            actionState= 1;
        } else if (Level.TimeSeconds - triggerTime >= 10.0) {
            if (actionState == 1) {
                achievementCompleted(achvIndex);
            } else {
                triggerTime= 0;
            }
        }
    }
    return true;
}

function Timer() {
    local int i, numBreakersFull;
    local Controller C;


    ownerController != none && checkTimeAchievement(survivedSiren, screamedTime, ownerController.bScreamedAt, AchvIndex.WINDJAMMER);
    ownerController != none && checkTimeAchievement(survivedBloat, vomitTime, ownerController.bVomittedOn, AchvIndex.EGGNOG);

    miniGamesCounter != none && checkCounter(miniGamesCounter.NumToCount, AchvIndex.ARCADE_GAMER);
    clownCounter != none && checkCounter(clownCounter.NumToCount, AchvIndex.HIDE_AND_PUKE);
    gladosDoorTrigger != none && checkCounter(gladosDoorTrigger.WeldStrength, AchvIndex.GOLDEN_POTATOE);
    gnomeSoulsCounter != none && checkCounter(gnomeSoulsCounter.NumToCount, AchvIndex.SOUL_COLLECTOR);
    zedGunCounter != none && checkCounter(zedGunCounter.NumToCount, AchvIndex.ALL_RED);

    for(i= 0; i < breakerBoxes.Length; i++) {
        if (breakerBoxes[i].Health >= breakerBoxes[i].NPCHealth) {
            numBreakersFull++;
        }
    }
    if (numBreakersFull >= 5) {
        achievementCompleted(AchvIndex.FULL_CHARGE);
    }
    failedEscort= failedEscort || ringMaster == none || (ringMaster != none && ringMaster.bFailedAchievement);
    failedDefense= failedDefense || ringMaster == none || (ringMaster != none && ringMaster.bFailedAchievement);

    if (ownerController != none && ownerController.PlayerReplicationInfo.Score >= 70000) {
        for(C= Level.ControllerList; C != none; C= C.NextController) {
            if (PlayerController(C) != none && !C.PlayerReplicationInfo.bOnlySpectator) {
                getEventAchievementsObj(C.PlayerReplicationInfo).achievementCompleted(AchvIndex.UBER_TUBER);
            }
        }
    }

    ///< TODO: Should collapse these identical if statements
    if (M32KillStart != 0 && Level.TimeSeconds - m32KillStart >= 5.0) {
        achievements[AchvIndex.BANG_FOR_THE_BUCK].progress= 0;
        m32KillStart= 0;
    }
    if (axeStartTime != 0 && Level.TimeSeconds - axeStartTime >= 10) {
        achievements[AchvIndex.I_AM_DEATH].progress= 0;
        axeStartTime= 0;
    }
}

event playerDied(Controller killer, class<DamageType> damageType, int waveNum) {
    survivedSiren= 0;
    survivedBloat= 0;
}

event droppedWeapon(KFWeaponPickup weaponPickup) {
    //User bIsTier2Weapon from the inventory type class
    //No way to use bPreviouslyDropped variable because KFWeaponPickup doesn't assign it if the weapon was a tier 2
    if (class<KFWeapon>(weaponPickup.InventoryType) != none && 
            class<KFWeapon>(weaponPickup.InventoryType).default.bIsTier2Weapon) {
        addProgress(AchvIndex.JUGGLING_ACT, 1);
    }
}

event waveStart(int waveNum) {
    resetWaveCounters();
}

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum) {
    if (isBedlam && length == KFGameType(Level.Game).GL_Long && difficulty == 4.0) {
        achievementCompleted(AchvIndex.ZED_OCTOBER);
    } else if (allSpeciesKilled(ftKills)) {
        achievementCompleted(AchvIndex.UNDER_THE_WEATHER);
    }
}

function checkZEDTimeMeleeKill(class<DamageType> damageType, byte achvIndex) {
    if (ClassIsChildOf(damageType, class'DamTypeMelee') && KFGameType(Level.Game).bZEDTimeActive) {
        addProgress(achvIndex, 1);
    } else {
        achievements[achvIndex].progress= 0;
    }
}

function bool isPistolDamage(class<DamageType> damageType) {
    return ClassIsChildOf(damageType, class'DamTypeDualies') || ClassIsChildOf(damageType, class'DamTypeDeagle') || 
        ClassIsChildOf(damageType, class'DamTypeDualDeagle') || ClassIsChildOf(damageType, class'DamTypeMK23Pistol');
}

function bool isSniperDamage(class<DamageType> damageType) {
    return ClassIsChildOf(damageType, class'DamTypeCrossbuzzsaw') || ClassIsChildOf(damageType, class'DamTypeCrossbuzzsawHeadShot') || 
        ClassIsChildOf(damageType, class'DamTypeM99SniperRifle') || ClassIsChildOf(damageType, class'DamTypeM99HeadShot');
}

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot) {
    local String menuName;
    local bool isHalloween, isXmas, isCircus;

    if (KFMonster(target) != none) {
        menuName= Locs(KFMonster(target).MenuName);
        isHalloween= (InStr(menuName, "hillbilly") != -1) || (InStr(menuName, "halloween") != -1);
        isXmas= InStr(menuName, "christmas") != -1;
        isCircus= InStr(menuName, "circus") != -1;
    }

    if (target.IsA('ZombieBoss')) {
        if (target.IsA('ZombieBoss_XMAS')) {
            achievementCompleted(AchvIndex.MERRY_CHRISTMAS);
        } else if (target.IsA('ZombieBoss_CIRCUS')) {
            achievementCompleted(AchvIndex.RINGMASTER);
        } else if (target.IsA('ZombieBoss_HALLOWEEN') && isBedlam) {
            achievementCompleted(AchvIndex.SPARKLING_TWILIGHT);
        }
    } else if (target.IsA('ZombieFleshPound')) {
        if (target.IsA('ZombieFleshPound_XMAS') && ClassIsChildOf(damageType, class'DamTypeKnife')) {
            achievementCompleted(AchvIndex.NUTCRACKER);
        } else if (target.IsA('ZombieFleshPound_CIRCUS') && isPistolDamage(damageType)) {
            achievementCompleted(AchvIndex.ELEPHANT_GUN);
        } else if (target.IsA('ZombieFleshPound_HALLOWEEN')) {
            if (ClassIsChildOf(damageType, class'DamTypeLAW') || ClassIsChildOf(damageType, class'DamTypeSealSquealExplosion')) {
                killedFpWithLaw= true;
            }
        }
    } else if (target.IsA('ZombieGoreFast')) {
        if (target.IsA('ZombieGoreFast_XMAS') && ZombieGoreFast(target).bBackstabbed) {
            addProgress(AchvIndex.CANT_CATCH_ME, 1);
        } else if (target.IsA('ZombieGoreFast_CIRCUS') && ClassIsChildOf(damageType, class'DamTypeMelee')) {
            achievementCompleted(AchvIndex.SPARRING_WITH_MASTER);
        } else if (target.IsA('ZombieGoreFast_HALLOWEEN') && (ClassIsChildOf(damageType, class'DamTypeTrenchgun') || 
                ClassIsChildOf(damageType, class'DamTypeFlareRevolver') || ClassIsChildOf(damageType, class'DamTypeFlareProjectileImpact')) 
                && KFMonster(target).BurnDown == 10) {
            addProgress(AchvIndex.FIERY_PERSONALITY, 1);
        }
    } else if (target.IsA('ZombieScrake')) {
        if (target.IsA('ZombieScrake_XMAS') && class<KFWeaponDamageType>(damageType) != none && 
                class<KFWeaponDamageType>(damageType).default.bDealBurningDamage) {
            achievementCompleted(AchvIndex.JACK_FROST);
        } else if (target.IsA('ZombieScrake_CIRCUS') && (ClassIsChildOf(damageType, class'DamTypeCrossbow') || 
                ClassIsChildOf(damageType, class'DamTypeCrossbowHeadShot'))) {
            achievementCompleted(AchvIndex.BIG_HUNT);
        } else if (target.IsA('ZombieScrake_HALLOWEEN')) {
            if (isBedlam) {
                addProgress(AchvIndex.ORDINARY_RABBIT, 1);
            }
            if (ClassIsChildOf(damageType, class'DamTypeLAW') || ClassIsChildOf(damageType, class'DamTypeSealSquealExplosion')) {
                killedScWithLaw= true;
            }
        }
    } else if (target.IsA('ZombieBloat')) {
        if (target.IsA('ZombieBloat_XMAS')) {
            if (ClassIsChildOf(damageType, class'DamTypeBullpup')) {
                addProgress(AchvIndex.NOT_SANTA, 1);
            }
            xmasBloat++;
        } else if (target.IsA('ZombieBloat_CIRCUS')) {
            addProgress(AchvIndex.CLOWN_ALLEY, 1);
        }
    } else if (target.IsA('ZombieClot')) {
        if (target.IsA('ZombieClot_XMAS')) {
            addProgress(AchvIndex.BACK_TO_WORK, 1);
            xmasClot++;
        } else if (target.IsA('ZombieClot_CIRCUS')) {
            if (ClassIsChildOf(damageType, class'DamTypeWinchester')) {
                addProgress(AchvIndex.SMALL_HANDS, 1);
            } else if (class<KFWeaponDamageType>(damageType) != none && class<KFWeaponDamageType>(damageType).default.bDealBurningDamage) {
                addProgress(AchvIndex.BURNING_MIDWAY, 1);
            }
        }
    } else if (target.IsA('ZombieCrawler')) {
        if (target.IsA('ZombieCrawler_XMAS')) {
            if ((ClassIsChildOf(damageType, class'DamTypeCrossbow') || ClassIsChildOf(damageType, class'DamTypeCrossbowHeadShot'))) {
                achievementCompleted(AchvIndex.RUDOLPH);
            }
            xmasCrawler++;
        } else if (target.IsA('ZombieCrawler_CIRCUS') && ClassIsChildOf(damageType, class'DamTypeBullpup')) {
            addProgress(AchvIndex.SEEING_DOUBLE, 1);
        } else if (target.IsA('ZombieCrawler_HALLOWEEN') && (ClassIsChildOf(damageType, class'DamTypeThompson') || 
                ClassIsChildOf(damageType, class'DamTypeMKb42AssaultRifle'))) {
            addProgress(AchvIndex.CREEPY_CRAWLIES, 1);
        }
    } else if (target.IsA('ZombieSiren')) {
        if (target.IsA('ZombieSiren_XMAS')) {
            if (ClassIsChildOf(damageType, class'LAWProj'.default.ImpactDamageType)) {
                achievementCompleted(AchvIndex.SILENT_NIGHT);
            }
            xmasSiren++;
        }
    } else if (target.IsA('ZombieStalker')) {
        if (target.IsA('ZombieStalker_XMAS')) {
            if (ClassIsChildOf(damageType, class'DamTypeWinchester')) {
                addProgress(AchvIndex.MRS_CLAWS, 1);
            }
            xmasStalker++;
        } else if (target.IsA('ZombieStalker_CIRCUS') && KFMonster(target).bBackstabbed) {
            addProgress(AchvIndex.ASSISTANT_HOMICIDE, 1);
        }
    } else if (target.IsA('ZombieHusk')) {
        if (target.IsA('ZombieHusk_XMAS') && isPistolDamage(damageType)) {
            achievementCompleted(AchvIndex.SNOW_BALL_FIGHT);
        } else if (target.IsA('ZombieHusk_CIRCUS') && ClassIsChildOf(damageType, class'DamTypeLaw')) {
            achievementCompleted(AchvIndex.LIFTING_A_DUMBELL);
        } else if (target.IsA('ZombieHusk_HALLOWEEN') && isSniperDamage(damageType) ) {
            killedHillbillyHuskWithM99= true;
        }
    }    

    if (killedHillbillyHuskWithM99 && killedOtherHillbillyWithM99) {
        achievementCompleted(AchvIndex.RIPPIN_IT_UP);
    } else if (killedScWithLaw && killedFpWithLaw) {
        achievementCompleted(AchvIndex.FIRE_AND_FORGET);
    }

    if (isXmas) {
        //@TODO: find a better way to do this weapon check
        if (ownerController.Pawn != none && KFWeapon(ownerController.Pawn.Weapon) != none && KFWeapon(ownerController.Pawn.Weapon).Tier3WeaponGiver != none) {
            getEventAchievementsObj(KFWeapon(ownerController.Pawn.Weapon).Tier3WeaponGiver.PlayerReplicationInfo).addProgress(AchvIndex.BETTER_TO_GIVE, 1);
        }
        checkZEDTimeMeleeKill(damageType, AchvIndex.BUCKETS_O_BLOOD);
        if (xmasClot >= 15 && xmasStalker >= 5 && xmasCrawler >= 5 && xmasSiren >= 1 && xmasBloat >= 1) {
            achievementCompleted(AchvIndex.BLOODY_CHRISTMAS_CAROL);
        }
    } else if (isHalloween) {
        addProgress(AchvIndex.MEET_YOUR_MAKER, 1);
        if (isSniperDamage(damageType) && !target.IsA('ZombieHusk')) {
            killedOtherHillbillyWithM99= true;
        } else if (ClassIsChildOf(damageType, class'DamTypeAxe') || ClassIsChildOf(damageType, class'DamTypeScythe')) {
            if (achievements[AchvIndex.I_AM_DEATH].progress == 0) {
                axeStartTime= Level.TimeSeconds;
            }
            addProgress(AchvIndex.I_AM_DEATH, 1);
        } else if (ClassIsChildOf(damageType, class'DamTypeM32Grenade') || ClassIsChildOf(damageType, class'DamTypeSealSquealExplosion') || 
                ClassIsChildOf(damageType, class'DamTypeRocketImpact')) {
            if (achievements[AchvIndex.BANG_FOR_THE_BUCK].progress == 0) {
                m32KillStart= Level.TimeSeconds;
            }
            addProgress(AchvIndex.BANG_FOR_THE_BUCK, 1);
        } else if (ClassIsChildOf(damageType, class'DamTypeBurned') || ClassIsChildOf(damageType, class'DamTypeFlamethrower') || ClassIsChildOf(damageType, class'DamTypeBlowerThrower')) {
            updateKillTypes(ftKills, target.class);
        }
        if (isBedlam) {
            if (KFMonster(target).bDecapitated && KFMonster(target).bBurnified) {
                achievementCompleted(AchvIndex.CARVING_JACK_O_LANTERN);
            }
            addProgress(AchvIndex.SCENE_IS_ZED, 1);
            addProgress(AchvIndex.TRICK_NOT_TREAT, 1);
        }
    } else if (isCircus) {
        checkZEDTimeMeleeKill(damageType, AchvIndex.BIG_TOP);
    }
}

event reloadedWeapon(KFWeapon weapon) {
    if (Winchester(weapon) != none) {
        achievements[AchvIndex.MRS_CLAWS].progress= 0;
    }
    achievements[AchvIndex.TRICK_NOT_TREAT].progress= 0;
}

event firedWeapon(KFWeapon weapon) {
    if (M99SniperRifle(weapon) != none || Crossbuzzsaw(weapon) != none) {
        killedHillbillyHuskWithM99= false;
        killedOtherHillbillyWithM99= false;
    } else if (SealSquealHarpoonBomber(weapon) != none || LAW(weapon) != none) {
        killedScWithLaw= false;
        killedFpWithLaw= false;
    }
}

defaultproperties {
    failedEscort= true
    failedDefense= true
    damagedWithBars= true

    packName= "Stock Events"
    
    achievements(0)=(title="Merry Friggin Christmas",description="[2010 Xmas] Kill the Christmas Patriarch",image=Texture'KillingFloor2HUD.Achievements.Achievement_118')
    achievements(1)=(title="Cracked the Nutcracker!",description="[2010 Xmas] Land the killing blow on a Christmas Fleshpound with a Knife",image=Texture'KillingFloor2HUD.Achievements.Achievement_119')
    achievements(2)=(title="Can't Catch Me!",description="[2010 Xmas] Kill 2 Christmas Gorefasts with a Melee weapon from behind in one wave",maxProgress=2,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_120')
    achievements(3)=(title="Toasted Jack Frost",description="[2010 Xmas] Kill the Christmas Scrake with a Fire-based weapon",image=Texture'KillingFloor2HUD.Achievements.Achievement_121')
    achievements(4)=(title="That's not Santa!",description="[2010 Xmas] Kill 3 Christmas Bloats with the Bullpup in one wave",maxProgress=3,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_122')
    achievements(5)=(title="Back to Work",description="[2010 Xmas] Kill 20 Christmas Clots in one wave",maxProgress=20,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_123')
    achievements(6)=(title="Rudolph, the Bloody Nosed Reindeer",description="[2010 Xmas] Kill a Christmas Crawler with a Crossbow",image=Texture'KillingFloor2HUD.Achievements.Achievement_124')
    achievements(7)=(title="Not So Silent Night",description="[2010 Xmas] Kill a Christmas Siren with an undetonated LAW rocket",image=Texture'KillingFloor2HUD.Achievements.Achievement_125')
    achievements(8)=(title="Fending off Mrs. Claws",description="[2010 Xmas] Kill 3 Christmas Stalkers with a Lever Action Rifle without reloading",maxProgress=3,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_126')
    achievements(9)=(title="Who Brings a Gun to a Snow Ball Fight?",description="[2010 Xmas] Kill a Christmas Husk with any Pistol.",image=Texture'KillingFloor2HUD.Achievements.Achievement_127')
    achievements(10)=(title="Deck the Halls with Buckets o' Blood",description="[2010 Xmas] Kill 3 Christmas Zeds in 1 ZED time chain with a Melee weapon",maxProgress=3,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_128')
    achievements(11)=(title="Tis Better to Give than to Receive",description="[2010 Xmas] Drop 3 Tier 3 weapons for others (with which they kill at least one Christmas Zed)",maxProgress=3,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_129')
    achievements(12)=(title="Eggnog Anyone?",description="[2010 Xmas] Get covered in Christmas Bloat Bile and live for 10 seconds on Hard, Suicidal, or Hell on Earth",image=Texture'KillingFloor2HUD.Achievements.Achievement_130')

    achievements(13)=(title="Uber Tuber",description="Expensive but delicious! Brought to you by Dr. Dougley and Lord Ned.",image=Texture'KillingFloor2HUD.Achievements.Achievement_132')
    achievements(14)=(title="Golden Potato",description="Get into GLaDOS' core on Aperture",image=Texture'KillingFloor2HUD.Achievements.Achievement_137')

    achievements(15)=(title="Ringmaster",description="Kill the Ring Leader (Circus Patriarch)",image=Texture'KillingFloor2HUD.Achievements.Achievement_142')
    achievements(16)=(title="Sparring with a Master",description="Kill a Circus Gorefast with a Melee weapon",image=Texture'KillingFloor2HUD.Achievements.Achievement_143')
    achievements(17)=(title="Assistant Homicide",description="Kill 2 Circus Stalkers with a Melee weapon to the back in one wave",maxProgress=2,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_144')
    achievements(18)=(title="Seeing Double",description="Kill 5 Circus Crawlers with a Bullpup in one wave",maxProgress=5,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_145')
    achievements(19)=(title="Clearing Clown Alley",description="Kill 5 Circus Bloats in one game",maxProgress=5,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_146')
    achievements(20)=(title="The Big Hunt",description="Kill a Circus Scrake with a Crossbow",image=Texture'KillingFloor2HUD.Achievements.Achievement_147')
    achievements(21)=(title="Lifting a Dumbell",description="Kill a Circus Husk with a LAW",image=Texture'KillingFloor2HUD.Achievements.Achievement_148')
    achievements(22)=(title="Small Hands",description="Kill 3 Circus Clots in a wave with the Lever Action Rifle",maxProgress=3,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_149')
    achievements(23)=(title="Elephant Gun",description="Land the killing blow on a Circus Fleshpound with a Pistol",image=Texture'KillingFloor2HUD.Achievements.Achievement_150')
    achievements(24)=(title="Juggling Act",description="Drop 5 different Tier 2 weapons in one wave",maxProgress=5,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_151')
    achievements(25)=(title="Windjammer Enthusiast",description="Survive 10 seconds after being screamed at by at Circus Siren on Hard or above",image=Texture'KillingFloor2HUD.Achievements.Achievement_152')
    achievements(26)=(title="Taking Down the Big Top",description="Kill 4 Circus Zeds in 1 ZED time chain with a Melee weapon",maxProgress=4,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_153')
    achievements(27)=(title="Burning up the Midway",description="Kill 10 Circus Clots with a Fire-based weapon",maxProgress=10,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_154')

    achievements(28)=(title="Sparkling in the Twilight",description="Kill The Vampire Patriarch Ringmaster in Bedlam",image=Texture'KillingFloor2HUD.Achievements.Achievement_156')
    achievements(29)=(title="Carving The Jack O' Lantern",description="Decapitate a burning Halloween specimen in Bedlam",image=Texture'KillingFloor2HUD.Achievements.Achievement_157')
    achievements(30)=(title="The Scene is Zed",description="Kill 250 Halloween Specimens in Bedlam",maxProgress=250,notifyIncrement=0.5,image=Texture'KillingFloor2HUD.Achievements.Achievement_158')
    achievements(31)=(title="Zed October",description="Win a Long Bedlam Match During the Halloween Event on Hard",image=Texture'KillingFloor2HUD.Achievements.Achievement_159')
    achievements(32)=(title="This is No Ordinary Rabbit!",description="Kill 25 Halloween Scrakes in Bedlam",maxProgress=25,notifyIncrement=0.5,image=Texture'KillingFloor2HUD.Achievements.Achievement_160')
    achievements(33)=(title="Trick, not Treat",description="Kill 5 Halloween Specimens with any gun without reloading",maxProgress=5,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_161')

    achievements(34)=(title="A Bloody Christmas Carol",description="Kill 15 XMas Clots, 5 xmas Stalkers, 5 XMas Crawlers, 1 XMas Siren and 1 XMas Bloat",image=Texture'KillingFloor2HUD.Achievements.Achievement_175')

    achievements(35)=(title="Soul Collector",description="Free the souls of the 25 Gnomes hidden on Hillbilly Horror in 1 game",image=Texture'KillingFloor2HUD.Achievements.Achievement_194')
    achievements(36)=(title="Meet Your Maker!",description="Kill 1000 Hillbilly Zeds",maxProgress=1000,notifyIncrement=0.20,image=Texture'KillingFloor2HUD.Achievements.Achievement_195')
    achievements(37)=(title="Creepy Crawlies",description="Kill 15 Hillbilly Crawlers in 1 game with the Tommy Gun or MKb42",maxProgress=15,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_196')
    achievements(38)=(title="Rippin' It Up",description="Kill a Hillbilly Husk and another Hillbilly Zed in the same shot with the Buzzsaw Bow or M99",image=Texture'KillingFloor2HUD.Achievements.Achievement_197')
    achievements(39)=(title="I Am Become Death",description="Kill 5 Hillbilly Zeds in 10 seconds with the Scythe or Axe",maxProgress=5,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_198')
    achievements(40)=(title="Fiery Personality",description="Set 3 Hillbilly Gorefasts on fire with the Flare Pistol or Trench Gun",maxProgress=3,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_199')

    achievements(41)=(title="Hide and go Puke",description="[2013 Summer] Destroy all the Pukey the Clown dolls",image=Texture'KillingFloor2HUD.Achievements.Achievement_217')
    achievements(42)=(title="Arcade Gamer",description="[2013 Summer] Complete the Pop the Clot, the Strong Man and the Grenade Toss games",image=Texture'KillingFloor2HUD.Achievements.Achievement_218')
    achievements(43)=(title="Full Charge",description="[2013 Summer] Have 5 Breaker Boxes 100% repaired at the same time",image=Texture'KillingFloor2HUD.Achievements.Achievement_219')
    achievements(44)=(title="Extended Motion Protector",description="[2013 Summer] Protect the Ringmaster during the escort mission so that he does not get hit more than 15 times",image=Texture'KillingFloor2HUD.Achievements.Achievement_220')
    achievements(45)=(title="Guardian Assault Protector",description="[2013 Summer] Protect the ringmaster during the defense mission so that he does not get hit more than 15 times",image=Texture'KillingFloor2HUD.Achievements.Achievement_221')
    achievements(46)=(title="Golden 3 Crown Note",description="[2013 Summer] Get all 3 gold bars without the carriers taking damage while they have them",image=Texture'KillingFloor2HUD.Achievements.Achievement_222')

    achievements(47)=(title="Fire and Forget",description="Kill a Halloween Fleshpound and Scrake in the same explosion with the Seal Squeal Harpoon Bomber or the LAW",image=Texture'KillingFloor2HUD.Achievements.Achievement_240')
    achievements(48)=(title="Under The Weather",description="Use Bile or the Flamethrower to kill one of each Halloween Zed",image=Texture'KillingFloor2HUD.Achievements.Achievement_241')
    achievements(49)=(title="Most Bang for the Buck",description="Kill 10 Halloween zeds in explosions using the Seeker 6 or the M32 within 5 seconds",maxProgress=10,noSave=true,image=Texture'KillingFloor2HUD.Achievements.Achievement_242')
    achievements(50)=(title="But It's All Red!",description="Collect all 16 Z.E.D. Gun pieces",image=Texture'KillingFloor2HUD.Achievements.Achievement_202')
}
