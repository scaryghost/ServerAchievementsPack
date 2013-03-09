class StockKFAchievements extends AchievementPackPartImpl;

enum StockIndex {
    EXPERIMENTICIDE, FACIST_DIETITIAN, HOMERS_HEROES, KEEP_THOSE_SNEAKERS, RANDOM_AXE,
    BITTER_IRONY, HOT_CROSS_FUN, DIGNITY_FOR_THE_DEAD, TOO_CLOSE, MASTER_SURGEON,
    ITS_WHATS_INSIDE, QUARTER_POUNDER, THIN_ICE, PHILANTHROPIST, STRAIGHT_RUSH,
    BROKE_THE_CAMELS_BACK, DEATH_TO_THE_MAD_SCIENTIST, EXPERIMENTIMILLICIDE, EXPERIMENTILOTTACIDE, 
    EXPLOSIVE_PERSONALITY, FLAMING_HELL, MERRY_MEN, BLOOPER_REEL, DOT_OF_DOOM, SCARD, 
    HEALING_TOUCH, POUND_THIS, KILLER_JUNIOR, LET_THEM_BURN, BURNING_IRONY,
    HIGHLANDER, BLOODY_YANKS, FINISH_HIM, I_LOVE_ZE_HEALING, ITALIAN_MEAT_PASTA, FEELING_LUCKY,
    COWBOY, SPEC_OPS, COMBAT_MEDIC, FUGLY, BRITISH_SUPERIORITY, HISTORICAL_REMNANTS, NAILD,
    TRENCH_WARFARE
};

var int axeKills, scrakeChainsawKills, medicKnifeKills, ebrHeadShotKills, m4MagKills, benelliMagKills, 
        revolverMagKills, mk23MagClotKills, mkb42Kills, stalkerNailgunKills;
var bool onlyCrossbowDmg, survivedWave, canEarnThinIce, killedwithBullpup, killedWithFnFal;
var bool claymoreScKill, claymoreFpKill, claymoreBossKill;
var array<byte> speciesKilled;
var array<Pawn> gibbedMonsters;

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
        if (StockKFAchievements(achievementPacks[i]) != none) {
            return StockKFAchievements(achievementPacks[i]);
        }
    }
    return none;
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
    local int i;

    if (result == 2 && difficulty >= 5.0) {
        achievementCompleted(StockIndex.DEATH_TO_THE_MAD_SCIENTIST);
    }
    if (claymoreScKill && claymoreFpKill && claymoreBossKill) {
        achievementCompleted(StockIndex.HIGHLANDER);
    } else if (speciesKilled.Length == KFGameType(Level.Game).MonsterCollection.default.MonsterClasses.Length + 1) {
        for(i= 0; i < speciesKilled.Length; i++) {
            if (speciesKilled[i] != 1) {
                break;
            }
        }
        if (i == speciesKilled.Length) {
            achievementCompleted(StockIndex.FUGLY);
        }
    }
}

event waveStart(int waveNum) {
    local bool hasDual9mm, hasDualHC, hasDualRevolver;
    local Inventory inv;

    survivedWave= true;
    canEarnThinIce= Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1;

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

event playerDied(Controller killer, class<DamageType> damageType, int waveNum) {
    survivedWave= false;
}

event killedMonster(Pawn target, class<DamageType> damageType, bool headshot) {
    local int i;
    local Controller C;
    local SAReplicationInfo saRepInfo;
    local bool allOnlyCrossbowDmg;
    local StockKFAchievements stockKFAchievementObj;

    addProgress(StockIndex.EXPERIMENTICIDE, 1);
    addProgress(StockIndex.EXPERIMENTIMILLICIDE, 1);
    addProgress(StockIndex.EXPERIMENTILOTTACIDE, 1);

    if (isGibbed(target)) {
        addProgress(StockIndex.ITS_WHATS_INSIDE, 1);
        if (ZombieFleshpound(target) != none) {
            addProgress(StockIndex.QUARTER_POUNDER, 1);
        }
        if (damageType == class'DamTypeM79Grenade') {
            addProgress(StockIndex.BLOOPER_REEL, 1);
        }
    }

    if (ZombieBloat(target) != none) {
        addProgress(StockIndex.FACIST_DIETITIAN, 1);
    } else if (ZombieSiren(target) != none) {
        addProgress(StockIndex.HOMERS_HEROES, 1);
    } else if (ZombieStalker(target) != none) {
        if (class<DamTypeFrag>(damageType) != none) {
            addProgress(StockIndex.KEEP_THOSE_SNEAKERS, 1);
        } else if (damageType == class'DamTypeNailGun') {
            stalkerNailgunKills++;
            if (stalkerNailgunKills == 4) {
                achievementCompleted(StockIndex.NAILD);
            }
        }
    } else if (ZombieScrake(target) != none) {
        if (damageType == class'DamTypeChainsaw') {
            scrakeChainsawKills++;
            if (scrakeChainsawKills == 2) {
                achievementCompleted(StockIndex.BITTER_IRONY);
            }
        } else if (damageType == class'DamTypeClaymoreSword') {
            claymoreScKill= true;
        } else if (damageType == class'DamTypeM203Grenade') {
            achievementCompleted(StockIndex.FINISH_HIM);
        }
    } else if (ZombieFleshpound(target) != none) {
        if (class<DamTypeMelee>(damageType) != none) {
            achievementCompleted(StockIndex.TOO_CLOSE);
        } else if (damageType == class'DamTypeAA12Shotgun') {
            addProgress(StockIndex.POUND_THIS, 1);
        } else if (damageType == class'DamTypeClaymoreSword') {
            claymoreFpKill= true;
        }
    } else if (ZombieBoss(target) != none) {
        if (damageType == class'DamTypeLaw') {
            achievementCompleted(StockIndex.BROKE_THE_CAMELS_BACK);
        } else if (damageType == class'DamTypeClaymoreSword') {
            claymoreBossKill= true;
        }
        allOnlyCrossbowDmg= true;
        for(C= Level.ControllerList; C != none; C= C.NextController) {
            if (PlayerController(C) != none && !C.PlayerReplicationInfo.bOnlySpectator) {
                saRepInfo= class'SAReplicationInfo'.static.findSARI(C.PlayerReplicationInfo);
                stockKFAchievementObj= getStockKFAchievementsObj(saRepInfo.achievementPacks);
                if (!ZombieBoss(target).bHealed) {
                    stockKFAchievementObj.achievementCompleted(StockIndex.STRAIGHT_RUSH);
                }
                allOnlyCrossbowDmg= allOnlyCrossbowDmg && stockKFAchievementObj.onlyCrossbowDmg;
            }
        }
        if (allOnlyCrossbowDmg) {
            achievementCompleted(StockIndex.MERRY_MEN);
        }
    } else if (ZombieCrawler(target) != none && target.Physics == PHYS_Falling && damageType == class'DamTypeM79Grenade') {
        addProgress(StockIndex.KILLER_JUNIOR, 1);
    } else if (ZombieHusk(target) != none) {
        if (!ZombieHusk(target).bDamagedAPlayer && (class<DamTypeBurned>(damageType) != none || class<DamTypeFlamethrower>(damageType) != none)) {
            achievementCompleted(StockIndex.FLAMING_HELL);
        } else if (class<DamTypeHuskGun>(damageType) != none || 
                class<DamTypeHuskGunProjectileImpact>(damageType) != none ) {
            addProgress(StockIndex.BURNING_IRONY, 1);
        }
    } else if (ZombieClot(target) != none && damageType == class'DamTypeMK23Pistol') {
        mk23MagClotKills++;
    }

    if (damageType == class'DamTypeAxe') {
        axeKills++;
        if (axeKills == 15) {
            achievementCompleted(StockIndex.RANDOM_AXE);
        }
    } else if ((damageType == class'DamTypeCrossbow' || damageType == class'DamTypeCrossbowHeadShot') && KFMonster(target) != none && KFMonster(target).bBurnified) {
        addProgress(StockIndex.HOT_CROSS_FUN, 1);
    } else if (damageType == class'DamTypeKnife' && KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill == class'KFVetFieldMedic') {
        medicKnifeKills++;
        if (medicKnifeKills == 8) {
            achievementCompleted(StockIndex.MASTER_SURGEON);
        }
    } else if (damageType == class'DamTypePipebomb' && KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill == class'KFVetDemolitions') {
        addProgress(StockIndex.EXPLOSIVE_PERSONALITY, 1);
    } else if (damageType == class'DamTypeSCARMK17AssaultRifle') {
        addProgress(StockIndex.SCARD, 1);
    } else if (damageType == class'DamTypeM4AssaultRifle') {
        m4MagKills++;
    } else if (damageType == class'DamTypeBenelli') {
        benelliMagKills++;
    } else if (damageType == class'DamTypeMagnum44Pistol') {
        revolverMagKills++;
    } else if (damageType == class'DamTypeM7A3M' && KFMonster(target).bDamagedAPlayer) {
        achievementCompleted(StockIndex.COMBAT_MEDIC);
    } else if (damageType == class'DamTypeBullpup') {
        killedWithBullpup= true;
    } else if (damageType == class'DamTypeFNFALAssaultRifle') {
        killedWithFnFal= true;
    } else if (damageType == class'DamTypeMkb42AssaultRifle') {
        mkb42Kills++;
    } else if (damageType == class'DamTypeTrenchgun') {
        addProgress(StockIndex.TRENCH_WARFARE, 1);
    } else if (damageType == class'DamTypeKSGShotgun') {
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
    }
}

event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot) {
    if (KFMonster(target) != none) {
        if (headshot && KFMonster(target).bDecapitated) {
            if (KFMonster(target).bLaserSightedEBRM14Headshotted) {
                ebrHeadShotKills++;
                if (ebrHeadShotKills == 25) {
                    achievementCompleted(StockIndex.DOT_OF_DOOM);
                }
            } else {
                ebrHeadShotKills= 0;
            }
        }
        if ( target.Health - damage <= 0 && damage > damageType.default.HumanObliterationThreshhold && damage != 1000 && 
                (!KFMonster(target).bDecapitated || KFMonster(target).bPlayBrainSplash)) {
            gibbedMonsters[gibbedMonsters.Length]= target;
        }
    }
    if (ZombieBoss(target) != none && (damageType != class'DamTypeCrossbow' && damageType != class'DamTypeCrossbowHeadshot')) {
        onlyCrossbowDmg= false;
    }
    if (damageType == class'DamTypeMAC10MPInc') {
        addProgress(StockIndex.LET_THEM_BURN, min(damage, target.Health));
    }
}

event touchedHealDart(MP7MHealinglProjectile healDart) {
    local SAReplicationInfo saRepInfo;
    local float potentialHealth;

    potentialHealth= Controller(Owner).Pawn.Health + KFPawn(Controller(Owner).Pawn).HealthToGive;
    if (potentialHealth <= Controller(Owner).Pawn.HealthMax) {
        if (healDart.class == class'MP5MHealinglProjectile') {
            saRepInfo= class'SAReplicationInfo'.static.findSARI(healDart.Instigator.PlayerReplicationInfo);
            getStockKFAchievementsObj(saRepInfo.achievementPacks).addProgress(StockIndex.I_LOVE_ZE_HEALING, KFPawn(Controller(Owner).Pawn).HealthToGive);
        } else if (healDart.class == class'MP7MHealinglProjectile') {
            saRepInfo= class'SAReplicationInfo'.static.findSARI(healDart.Instigator.PlayerReplicationInfo);
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
    }
}

defaultproperties {
    packName= "Stock KF"

    onlyCrossbowDmg= true;

    achievements(0)=(title="Experimenticide",description="Kill 100 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_18',maxProgress=100,notifyIncrement=1.0)
    achievements(1)=(title="Fascist Dietitian",description="Kill 200 bloats",image=Texture'KillingFloorHUD.Achievements.Achievement_21',maxProgress=200,notifyIncrement=0.2)
    achievements(2)=(title="Homer's Heroes",description="Kill 100 sirens",image=Texture'KillingFloorHUD.Achievements.Achievement_22',maxProgress=100,notifyIncrement=0.2)
    achievements(3)=(title="Keep Those Sneakers Off the Floor!",description="Kill 20 stalkers with explosives",image=Texture'KillingFloorHUD.Achievements.Achievement_23',maxProgress=20,notifyIncrement=0.25)
    achievements(4)=(title="Random Axe of Kindness",description="Kill 15 specimens with a fire axe in a single wave",image=Texture'KillingFloorHUD.Achievements.Achievement_24')
    achievements(5)=(title="Bitter Irony",description="Kill 2 scrakes with a chainsaw in a single wave",image=Texture'KillingFloorHUD.Achievements.Achievement_25')
    achievements(6)=(title="Hot Cross Fun",description="Kill 25 burning specimens with a crossbow",image=Texture'KillingFloorHUD.Achievements.Achievement_26',maxProgress=25,notifyIncrement=0.2)
    achievements(7)=(title="Dignity for the Dead",description="Kill 10 specimens feeding on dead teammates' corpses",image=Texture'KillingFloorHUD.Achievements.Achievement_27',maxProgress=10,notifyIncrement=0.5)
    achievements(8)=(title="Too Close For Comfort",description="Finish off a fleshpound using a melee attack",image=Texture'KillingFloorHUD.Achievements.Achievement_31')
    achievements(9)=(title="Master Surgeon",description="As a medic, kill 8 specimens using a knife in a single wave",image=Texture'KillingFloorHUD.Achievements.Achievement_32')
    achievements(10)=(title="It's What's Inside That Counts",description="Turn 500 specimens into giblets",image=Texture'KillingFloorHUD.Achievements.Achievement_33',maxProgress=500,notifyIncrement=0.25)
    achievements(11)=(title="Quarter Pounder With Ease",description="Turn 5 fleshpounds into giblets",image=Texture'KillingFloorHUD.Achievements.Achievement_34',maxProgress=5)
    achievements(12)=(title="Thin-Ice Pirouette",description="Complete 10 waves when the rest of your team has died",image=Texture'KillingFloorHUD.Achievements.Achievement_36',maxProgress=10,notifyIncrement=0.5)
    achievements(13)=(title="Philanthropist",description="Give 1,000 pounds to teamamtes who have 50% of your cash or less",image=Texture'KillingFloorHUD.Achievements.Achievement_37',maxProgress=1000,notifyIncrement=1.0)
    achievements(14)=(title="Straight Rush",description="Kill the patriarch before he has a chance to heal",image=Texture'KillingFloorHUD.Achievements.Achievement_40')
    achievements(15)=(title="The L.A.W. That Broke The Camel's Back",description="Deliver the Killing Blow to the Patriarch with a L.A.W. Rocket",image=Texture'KillingFloorHUD.Achievements.Achievement_41')
    achievements(16)=(title="Death To the Mad Scientist",description="Defeat the Patriarch on Suicidal",image=Texture'KillingFloorHUD.Achievements.Achievement_42')
    achievements(17)=(title="Experimentimillicide",description="Kill 1,000 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_19',maxProgress=1000,notifyIncrement=0.5)
    achievements(18)=(title="Experimentilottacide",description="Kill 10,000 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_20',maxProgress=10000,notifyIncrement=0.25)
    achievements(19)=(title="Explosive Personality",description="As Demolitions, kill 1000 specimens with the the pipebomb",image=Texture'KillingFloor2HUD.Achievements.Achievement_56',maxProgress=1000,notifyIncrement=0.1)
    achievements(20)=(title="Flaming Hell, That was Close",description="As Firebug, kill the husk with the flamethrower before he hurts anyone",image=Texture'KillingFloor2HUD.Achievements.Achievement_57')
    achievements(21)=(title="Merry Men",description="Kill the patriarch when everyone is ONLY using crossbows",image=Texture'KillingFloor2HUD.Achievements.Achievement_58')
    achievements(22)=(title="Blooper Reel",description="Turn 500 Zeds into giblets using the M79",image=Texture'KillingFloor2HUD.Achievements.Achievement_59',maxProgress=500,notifyIncrement=0.25)
    achievements(23)=(title="Dot of Doom",description="Get 25 headshots in a row with the EBR while using the laser sight",image=Texture'KillingFloor2HUD.Achievements.Achievement_60')
    achievements(24)=(title="SCAR'd",description="Kill 1000 specimens with the SCAR",image=Texture'KillingFloor2HUD.Achievements.Achievement_62',maxProgress=1000,notifyIncrement=0.25)
    achievements(25)=(title="Healing Touch",description="Heal 200 teammates with the MP7's medication dart",image=Texture'KillingFloor2HUD.Achievements.Achievement_63',maxProgress=200,notifyIncrement=0.20)
    achievements(26)=(title="Pound This",description="Kill 100 fleshpounds with the AA12",image=Texture'KillingFloor2HUD.Achievements.Achievement_64',maxProgress=100,notifyIncrement=0.2)
    achievements(27)=(title="Killer Junior",description="Kill 20 crawlers in mid-air with the M79",image=Texture'ServerAchievementsPack.StockKFAchievements.Achievement_26',maxProgress=20,notifyIncrement=0.5)
    achievements(28)=(title="Let Them Burn",description="Get 1000 points of burn damage with the MAC-10",image=Texture'KillingFloor2HUD.Achievements.Achievement_113',maxProgress=1000)
    achievements(29)=(title="Burning Irony",description="Kill 15 husks with the Husk Cannon",image=Texture'KillingFloor2HUD.Achievements.Achievement_163',maxProgress=15,notifyIncrement=0.33333)
    achievements(30)=(title="Highlander",description="Kill a scrake, a fleshpound, and the patriarch with the Claymore sword within one map",image=Texture'KillingFloor2HUD.Achievements.Achievement_164')
    achievements(31)=(title="Bloody Yanks",description="Kill 1 specimen ONLY while expending a full M4 Assault Rifle magazine",image=Texture'KillingFloor2HUD.Achievements.Achievement_165')
    achievements(32)=(title="Finish Him",description="Hit a scrake with the M203 Rifle grenade to kill him",image=Texture'KillingFloor2HUD.Achievements.Achievement_166')
    achievements(33)=(title="I love ze Healing not ze Hurting",description="Heal others for 3000 points of health with the MP5 SMG",image=Texture'KillingFloor2HUD.Achievements.Achievement_167',maxProgress=3000,notifyIncrement=0.33333)
    achievements(34)=(title="Italian Meat Pasta",description="Kill 12 zeds with a full magazine from the Combat Shotgun",image=Texture'KillingFloor2HUD.Achievements.Achievement_168')
    achievements(35)=(title="Feeling Lucky?",description="Kill a specimen with every shot from your Revolver for one magazine",image=Texture'KillingFloor2HUD.Achievements.Achievement_169')
    achievements(36)=(title="We Have Ourselves a Cowboy",description="Hold Dual 9mm, Dual Hand Cannons, and Dual Revolvers",image=Texture'KillingFloor2HUD.Achievements.Achievement_170')
    achievements(37)=(title="Spec Ops",description="Kill 12 clots with one magazine without reloading (MK23)",image=Texture'KillingFloor2HUD.Achievements.Achievement_176')
    achievements(38)=(title="Combat Medic",description="Kill a zed that has injured a player (M7A3 rifle)",image=Texture'KillingFloor2HUD.Achievements.Achievement_177')
    achievements(39)=(title="Fugly",description="Kill one of each type of zed in one round (HSG Shotgun)",image=Texture'KillingFloor2HUD.Achievements.Achievement_178')
    achievements(40)=(title="British Superiority",description="Kill a zed each with both the Bullpup and FN-Fal",image=Texture'KillingFloor2HUD.Achievements.Achievement_179')
    achievements(41)=(title="Historical Remnants",description="Kill 6 zeds with one magazine, without reloading (Mkb42)",image=Texture'KillingFloor2HUD.Achievements.Achievement_185')
    achievements(42)=(title="Nail'd!",description="Kill 4 stalkers in a game with the Nailgun",image=Texture'KillingFloor2HUD.Achievements.Achievement_186')
    achievements(43)=(title="Trench Warfare",description="Set a total of 200 zeds on fire",image=Texture'KillingFloor2HUD.Achievements.Achievement_188',maxProgress=200,notifyIncrement=50)
}