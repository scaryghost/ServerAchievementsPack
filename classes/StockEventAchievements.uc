class StockEventAchievements extends AchievementPackPartImpl;

enum AchvIndex {
    RINGMASTER, SPARRING_WITH_MASTER, ASSISTANT_HOMICIDE, SEEING_DOUBLE, CLOWN_ALLEY,
    BIG_HUNT, LIFTING_A_DUMBELL, SMALL_HANDS, ELEPHANT_GUN, JUGGLING_ACT, 
    WINDJAMMER, BIG_TOP, BURNING_MIDWAY, HIDE_AND_PUKE, ARCADE_GAMER,
    FULL_CHARGE, MOTION_PROTECTOR, ASSAULT_PROTECTOR, CROWN_NOTE
};

var int stalkersKilled, crawlersKilled, bloatsKilled, zedTimeMeleeKills, clotLarKills, 
        clotBurningKills, droppedT2Weapons;
var bool survivedSiren, failedEscort, failedDefense, damagedWithBars, goldBarsObjective;
var int screamedTime;
var BEResettableCounter miniGamesCounter, clownCounter;
var array<KF_BreakerBoxNPC> breakerBoxes;
var KF_RingMasterNPC ringMaster;
var name prevObjName;

function PostBeginPlay() {
    local BEResettableCounter achvCounter;
    local KF_BreakerBoxNPC breakerBox;

    foreach DynamicActors(class'BEResettableCounter', achvCounter) {
        if (achvCounter.Event == 'MiniGamesCompleted') {
            miniGamesCounter= achvCounter;
        } else if (achvCounter.Event == 'ClownSoulsCompleted') {
            clownCounter= achvCounter;
        }
    }
    foreach DynamicActors(class'KF_BreakerBoxNPC', breakerBox) {
        breakerBoxes[breakerBoxes.Length]= breakerBox;
    }
    SetTimer(1.0, true);
}

function StockEventAchievements getEventAchievementsObj(array<AchievementPack> achievementPacks) {
    local int i;

    for(i= 0; i < achievementPacks.Length; i++) {
        if (StockEventAchievements(achievementPacks[i]) != none) {
            return StockEventAchievements(achievementPacks[i]);
        }
    }
    return none;
}

event playerDamaged(int damage, Pawn instigator, class<DamageType> damageType) {
    if (KFStoryGameInfo(Level.Game) != none && goldBarsObjective && KFHumanPawn_Story(PlayerController(Owner).Pawn).bHasStoryItem) {
        damagedWithBars= true;
    }
}

event objectiveChanged(KF_StoryObjective newObjective) {
    local StockEventAchievements eventAchvObj;
    local KF_RingMasterNPC iterator;
    local bool noCarriersDamaged;
    local Controller C;
    local SAReplicationInfo saRepInfo;

    if (!failedEscort) {
        achievementCompleted(AchvIndex.MOTION_PROTECTOR);
    } else if (!failedDefense) {
        achievementCompleted(AchvIndex.ASSAULT_PROTECTOR);
    }

    noCarriersDamaged= true;
    for(C= Level.ControllerList; C != none; C= C.NextController) {
        if (PlayerController(C) != none && !C.PlayerReplicationInfo.bOnlySpectator) {
            saRepInfo= class'SAReplicationInfo'.static.findSARI(C.PlayerReplicationInfo);
            eventAchvObj= getEventAchievementsObj(saRepInfo.achievementPacks);
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
    stalkersKilled= 0;
    crawlersKilled= 0;
    clotLarKills= 0;
    droppedT2Weapons= 0;
}

function Timer() {
    local int i, numBreakersFull;

    if ((KFPlayerController(Owner).bScreamedAt || screamedTime != 0) && Level.Game.GameDifficulty >= 4.0) {
        if (screamedTime == 0) {
            screamedTime= Level.TimeSeconds;
            survivedSiren= true;
        } else if (Level.TimeSeconds - screamedTime >= 10.0) {
            if (survivedSiren) {
                achievementCompleted(AchvIndex.WINDJAMMER);
            } else {
                screamedTime= 0;
            }
        }
    }
    if (miniGamesCounter != none && miniGamesCounter.NumToCount <= 0) {
        achievementCompleted(AchvIndex.ARCADE_GAMER);
    }
    if (clownCounter != none && clownCounter.NumToCount <= 0) {
        achievementCompleted(AchvIndex.HIDE_AND_PUKE);
    }
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
}

event playerDied(Controller killer, class<DamageType> damageType, int waveNum) {
    survivedSiren= false;
}

event droppedWeapon(KFWeaponPickup weaponPickup) {
    //User bIsTier2Weapon from the inventory type class
    //No way to use bPreviouslyDropped variable because KFWeaponPickup doesn't assign it if the weapon was a tier 2
    if (class<KFWeapon>(weaponPickup.InventoryType) != none && 
            class<KFWeapon>(weaponPickup.InventoryType).default.bIsTier2Weapon) {
        droppedT2Weapons++;
        if (droppedT2Weapons >= 5) {
            achievementCompleted(AchvIndex.JUGGLING_ACT);
        }
    }
}

event waveStart(int waveNum) {
    stalkersKilled= 0;
    crawlersKilled= 0;
    clotLarKills= 0;
    droppedT2Weapons= 0;
}

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot) {
    if (class<DamTypeMelee>(damageType) != none && KFGameType(Level.Game).bZEDTimeActive) {
        zedTimeMeleeKills++;
        if (zedTimeMeleeKills >= 4) {
            achievementCompleted(AchvIndex.BIG_TOP);
        }
    } else {
        zedTimeMeleeKills= 0;
    }

    if (target.IsA('ZombieBoss_CIRCUS')) {
        achievementCompleted(AchvIndex.RINGMASTER);
    } else if (target.IsA('ZombieGoreFast_CIRCUS') && class<DamTypeMelee>(damageType) != none) {
        achievementCompleted(AchvIndex.SPARRING_WITH_MASTER);
    } else if (target.IsA('ZombieStalker_CIRCUS') && KFMonster(target).bBackstabbed) {
        stalkersKilled++;
        if (stalkersKilled >= 2) {
            achievementCompleted(AchvIndex.ASSISTANT_HOMICIDE);
        }
    } else if (target.IsA('ZombieCrawler_CIRCUS') && class<DamTypeBullpup>(damageType) != none) {
        crawlersKilled++;
        if (crawlersKilled >= 5) {
            achievementCompleted(AchvIndex.SEEING_DOUBLE);
        }
    } else if (target.IsA('ZombieBloat_CIRCUS')) {
        bloatsKilled++;
        if (bloatsKilled >= 5) {
            achievementCompleted(AchvIndex.CLOWN_ALLEY);
        }
    } else if (target.IsA('ZombieScrake_CIRCUS') && (damageType == class'DamTypeCrossbow' || damageType == class'DamTypeCrossbowHeadShot')) {
        achievementCompleted(AchvIndex.BIG_HUNT);
    } else if (target.IsA('ZombieHusk_CIRCUS') && damageType == class'DamTypeLaw') {
        achievementCompleted(AchvIndex.LIFTING_A_DUMBELL);
    } else if (target.IsA('ZombieClot_CIRCUS')) {
        if (damageType == class'DamTypeWinchester') {
            clotLarKills++;
            if (clotLarKills >= 3) {
                achievementCompleted(AchvIndex.SMALL_HANDS);
            }
        } else if (class<KFWeaponDamageType>(damageType) != none && class<KFWeaponDamageType>(damageType).default.bDealBurningDamage) {
            clotBurningKills++;
            if (clotBurningKills >= 10) {
                achievementCompleted(AchvIndex.BURNING_MIDWAY);
            }
        }
    } else if (target.IsA('ZombieFleshPound_CIRCUS') && (class<DamTypeDualies>(damageType) != none ||
            class<DamTypeDeagle>(damageType) != none || class<DamTypeDualDeagle>(damageType) != none || 
            class<DamTypeMK23Pistol>(damageType) != none)) {
        achievementCompleted(AchvIndex.ELEPHANT_GUN);
    }
}

defaultproperties {
    failedEscort= true
    failedDefense= true
    damagedWithBars= true

    packName= "Event Achievements"
    
    achievements(0)=(title="Merry Friggin Christmas",description="[2010 Xmas] Kill the Christmas Patriarch",image=Texture'KillingFloor2HUD.Achievements.Achievement_118')
    achievements(0)=(title="Cracked the Nutcracker!",description="[2010 Xmas] Land the killing blow on a Christmas Fleshpound with a Knife",image=Texture'KillingFloor2HUD.Achievements.Achievement_119')
    achievements(0)=(title="Can't Catch Me!",description="[2010 Xmas] Kill 2 Christmas Gorefasts with a Melee weapon from behind in one wave",image=Texture'KillingFloor2HUD.Achievements.Achievement_120')
    achievements(0)=(title="Toasted Jack Frost",description="[2010 Xmas] Kill the Christmas Scrake with a Fire-based weapon",image=Texture'KillingFloor2HUD.Achievements.Achievement_121')
    achievements(0)=(title="That's not Santa!",description="[2010 Xmas] Kill 3 Christmas Bloats with the Bullpup in one wave",image=Texture'KillingFloor2HUD.Achievements.Achievement_122')
    achievements(0)=(title="Back to Work",description="[2010 Xmas] Kill 20 Christmas Clots in one wave",image=Texture'KillingFloor2HUD.Achievements.Achievement_123')
    achievements(0)=(title="Rudolph, the Bloody Nosed Reindeer",description="[2010 Xmas] Kill a Christmas Crawler with a Crossbow",image=Texture'KillingFloor2HUD.Achievements.Achievement_124')
    achievements(0)=(title="Not So Silent Night",description="[2010 Xmas] Kill a Christmas Siren with an undetonated LAW rocket",image=Texture'KillingFloor2HUD.Achievements.Achievement_125')
    achievements(0)=(title="Fending off Mrs. Claws",description="[2010 Xmas] Kill 3 Christmas Stalkers with a Lever Action Rifle without reloading",image=Texture'KillingFloor2HUD.Achievements.Achievement_126')
    achievements(0)=(title="Who Brings a Gun to a Snow Ball Fight?",description="[2010 Xmas] Kill a Christmas Husk with any Pistol.",image=Texture'KillingFloor2HUD.Achievements.Achievement_127')
    achievements(0)=(title="Deck the Halls with Buckets o' Blood",description="[2010 Xmas] Kill 3 Christmas Zeds in 1 ZED time chain with a Melee weapon",image=Texture'KillingFloor2HUD.Achievements.Achievement_128')
    achievements(0)=(title="Tis Better to Give than to Receive",description="[2010 Xmas] Drop 3 Tier 3 weapons for others (with which they kill at least one Christmas Zed)",image=Texture'KillingFloor2HUD.Achievements.Achievement_129')
    achievements(0)=(title="Eggnog Anyone?",description="[2010 Xmas] Get covered in Christmas Bloat Bile and live for 10 seconds on Hard, Suicidal, or Hell on Earth",image=Texture'KillingFloor2HUD.Achievements.Achievement_130')

    achievements(0)=(title="Uber Tuber",description="Expensive but delicious! Brought to you by Dr. Dougley and Lord Ned.",image=Texture'KillingFloor2HUD.Achievements.Achievement_132')
    achievements(0)=(title="Golden Potato",description="Get into GLaDOS' core on Aperture",image=Texture'KillingFloor2HUD.Achievements.Achievement_137')

    achievements(0)=(title="Ringmaster",description="Kill the Ring Leader (Circus Patriarch)",image=Texture'KillingFloor2HUD.Achievements.Achievement_142')
    achievements(1)=(title="Sparring with a Master",description="Kill a Circus Gorefast with a Melee weapon",image=Texture'KillingFloor2HUD.Achievements.Achievement_143')
    achievements(2)=(title="Assistant Homicide",description="Kill 2 Circus Stalkers with a Melee weapon to the back in one wave",image=Texture'KillingFloor2HUD.Achievements.Achievement_144')
    achievements(3)=(title="Seeing Double",description="Kill 5 Circus Crawlers with a Bullpup in one wave",image=Texture'KillingFloor2HUD.Achievements.Achievement_145')
    achievements(4)=(title="Clearing Clown Alley",description="Kill 5 Circus Bloats in one game",image=Texture'KillingFloor2HUD.Achievements.Achievement_146')
    achievements(5)=(title="The Big Hunt",description="Kill a Circus Scrake with a Crossbow",image=Texture'KillingFloor2HUD.Achievements.Achievement_147')
    achievements(6)=(title="Lifting a Dumbell",description="Kill a Circus Husk with a LAW",image=Texture'KillingFloor2HUD.Achievements.Achievement_148')
    achievements(7)=(title="Small Hands",description="Kill 3 Circus Clots in a wave with the Lever Action Rifle",image=Texture'KillingFloor2HUD.Achievements.Achievement_149')
    achievements(8)=(title="Elephant Gun",description="Land the killing blow on a Circus Fleshpound with a Pistol",image=Texture'KillingFloor2HUD.Achievements.Achievement_150')
    achievements(9)=(title="Juggling Act",description="Drop 5 different Tier 2 weapons in one wave",image=Texture'KillingFloor2HUD.Achievements.Achievement_151')
    achievements(10)=(title="Windjammer Enthusiast",description="Survive 10 seconds after being screamed at by at Circus Siren on Hard or above",image=Texture'KillingFloor2HUD.Achievements.Achievement_152')
    achievements(11)=(title="Taking Down the Big Top",description="Kill 4 Circus Zeds in 1 ZED time chain with a Melee weapon",image=Texture'KillingFloor2HUD.Achievements.Achievement_153')
    achievements(12)=(title="Burning up the Midway",description="Kill 10 Circus Clots with a Fire-based weapon",image=Texture'KillingFloor2HUD.Achievements.Achievement_154')

    achievements(12)=(title="Soul Collector",description="Free the souls of the 25 Gnomes hidden on Hillbilly Horror in 1 game",image=Texture'KillingFloor2HUD.Achievements.Achievement_194')
    achievements(12)=(title="Meet Your Maker!",description="Kill 1000 Hillbilly Zeds",image=Texture'KillingFloor2HUD.Achievements.Achievement_195',maxProgress=1000,notifyIncrement=0.25)
    achievements(12)=(title="Creepy Crawlies",description="Kill 15 Hillbilly Crawlers in 1 game with the Tommy Gun or MKb42",image=Texture'KillingFloor2HUD.Achievements.Achievement_196')
    achievements(12)=(title="Rippin' It Up",description="Kill a Hillbilly Husk and another Hillbilly Zed in the same shot with the Buzzsaw Bow or M99",image=Texture'KillingFloor2HUD.Achievements.Achievement_197')
    achievements(12)=(title="I Am Become Death",description="Kill 5 Hillbilly Zeds in 10 seconds with the Scythe or Axe",image=Texture'KillingFloor2HUD.Achievements.Achievement_198')
    achievements(12)=(title="Fiery Personality",description="Set 3 Hillbilly Gorefasts on fire with the Flare Pistol or Trench Gun",image=Texture'KillingFloor2HUD.Achievements.Achievement_199')

    achievements(13)=(title="Hide and go Puke",description="[2013 Summer] Destroy all the Pukey the Clown dolls",image=Texture'KillingFloor2HUD.Achievements.Achievement_217')
    achievements(14)=(title="Arcade Gamer",description="[2013 Summer] Complete the Pop the Clot, the Strong Man and the Grenade Toss games",image=Texture'KillingFloor2HUD.Achievements.Achievement_219')
    achievements(15)=(title="Full Charge",description="[2013 Summer] Have 5 Breaker Boxes 100% repaired at the same time",image=Texture'KillingFloor2HUD.Achievements.Achievement_220')
    achievements(16)=(title="Extended Motion Protector",description="[2013 Summer] Protect the Ringmaster during the escort mission so that he does not get hit more than 15 times",image=Texture'KillingFloor2HUD.Achievements.Achievement_221')
    achievements(17)=(title="Guardian Assault Protector",description="[2013 Summer] Protect the ringmaster during the defense mission so that he does not get hit more than 15 times",image=Texture'KillingFloor2HUD.Achievements.Achievement_222')
    achievements(18)=(title="Golden 3 Crown Note",description="[2013 Summer] Get all 3 gold bars without the carriers taking damage while they have them",image=Texture'KillingFloor2HUD.Achievements.Achievement_223')
}
