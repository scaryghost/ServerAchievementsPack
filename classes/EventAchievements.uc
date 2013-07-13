class EventAchievements extends AchievementPackPartImpl;

enum AchvIndex {
    RINGMASTER, SPARRING_WITH_MASTER, ASSISTANT_HOMICIDE, SEEING_DOUBLE, CLOWN_ALLEY,
    BIG_HUNT, LIFTING_A_DUMBELL, SMALL_HANDS, ELEPHANT_GUN, JUGGLING_ACT, 
    WINDJAMMER, BIG_TOP, BURNING_MIDWAY
};

var int stalkersKilled, crawlersKilled, bloatsKilled, zedTimeMeleeKills, clotLarKills, 
        clotBurningKills, droppedT2Weapons;
var bool survivedSiren;

function PostBeginPlay() {
    if (achievements[achvIndex.WINDJAMMER].completed == 0) {
        SetTimer(1.0, true);
    }
}

function Timer() {
    if (TimerRate == 1.0 && KFPlayerController(Owner).bScreamedAt) {
        SetTimer(10.0, false);
        survivedSiren= true;
    } else if (TimerRate == 0.0) {
        if (survivedSiren && Level.Game.GameDifficulty >= 4.0) {
            achievementCompleted(AchvIndex.WINDJAMMER);
        } else {
            SetTimer(1.0, true);
        }
    }
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
        } else if (class<DamTypeBurned>(damageType) != none || class<DamTypeFlamethrower>(damageType) != none) {
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
    packName= "Event Achievements"
    
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
}
