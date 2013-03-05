class StockKFAchievements extends AchievementPackPartImpl;

enum StockIndex {
    EXPERIMENTICIDE, FACIST_DIETITIAN, HOMERS_HEROES, KEEP_THOSE_SNEAKERS, RANDOM_AXE,
    BITTER_IRONY, HOT_CROSS_FUN, DIGNITY_FOR_THE_DEAD, TOO_CLOSE, MASTER_SURGEON,
    ITS_WHATS_INSIDE, QUARTER_POUNDER, THIN_ICE, PHILANTHROPIST, STRAIGHT_RUSH,
    BROKE_THE_CAMELS_BACK, DEATH_TO_MAD_SCIENTEST, EXPERIMENTIMILLICIDE, EXPERIMENTILOTTACIDE, 
    EXPLOSIVE_PERSONALITY, MERRY_MEN, BLOOPER_REAL, DOT_OF_DOOM, SCARD, HEALING_TOUCH,
    POUND_THIS, KILLER_JUNIOR, LET_THEM_BURN
};

var int axeKills;
var int scrakeChainsawKills;
var int medicKnifeKills;
//target.Health <= 0 && Damage > DamageType.default.HumanObliterationThreshhold && Damage != 1000 && (!bDecapitated || bPlayBrainSplash)
event killedMonster(Pawn target, class<DamageType> damageType, bool headshot) {
    addProgress(StockIndex.EXPERIMENTICIDE, 1);
    addProgress(StockIndex.EXPERIMENTIMILLICIDE, 1);
    addProgress(StockIndex.EXPERIMENTILOTTACIDE, 1);

    if (ZombieBloat(target) != none) {
        addProgress(StockIndex.FACIST_DIETITIAN, 1);
    } else if (ZombieSiren(target) != none) {
        addProgress(StockIndex.HOMERS_HEROES, 1);
    } else if (ZombieStalker(target) != none && class<DamTypeFrag>(damageType) != none) {
        addProgress(StockIndex.KEEP_THOSE_SNEAKERS, 1);
    } else if (ZombieScrake(target) != none && damageType == class'DamTypeChainsaw') {
        scrakeChainsawKills++;
        if (scrakeChainsawKills == 2) {
            achievementCompleted(StockIndex.BITTER_IRONY);
        }
    } else if (ZombieFleshpound(target) != none) {
        if (class<DamTypeMelee>(damageType) != none) {
            achievementCompleted(StockIndex.TOO_CLOSE);
        } else if (damageType == class'DamTypeAA12Shotgun') {
            addProgress(StockIndex.POUND_THIS, 1);
        }
    } else if (ZombieBoss(target) != none) {
        if (ZombieBoss(target).SyringeCount == 0) {
            //Need to alert others that he had didn't use any syringes
            achievementCompleted(StockIndex.STRAIGHT_RUSH);
        }
        if (damageType == class'DamTypeLaw') {
            achievementCompleted(StockIndex.BROKE_THE_CAMELS_BACK);
        }
    } else if (ZombieCrawler(target) != none && target.Physics == PHYS_Falling && damageType == class'DamTypeM79Grenade') {
        addProgress(StockIndex.KILLER_JUNIOR, 1);
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
    }
    if (Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 && target.AnimAction == 'ZombieFeed') {
        addProgress(StockIndex.DIGNITY_FOR_THE_DEAD, 1);
    }
}

event pickedUpItem(Pickup item) {
    local int i;
    local SAReplicationInfo saRepInfo;

    if (CashPickup(item) != none && Controller(Owner).PlayerReplicationInfo != CashPickup(item).DroppedBy.PlayerReplicationInfo) {
        if ((CashPickup(item).DroppedBy.PlayerReplicationInfo.Score + float(CashPickup(item).CashAmount)) >= 0.50 * Controller(Owner).PlayerReplicationInfo.Score) {
            saRepInfo= class'SAReplicationInfo'.static.findSARI(CashPickup(item).DroppedBy.PlayerReplicationInfo);
            for(i= 0; i < saRepInfo.achievementPacks.Length; i++) {
                if (StockKFAchievements(saRepInfo.achievementPacks[i]) != none) {
                    StockKFAchievements(saRepInfo.achievementPacks[i]).addProgress(StockIndex.PHILANTHROPIST, CashPickup(item).CashAmount);
                }
            }
        }
    }
}

event touchedHealDart(MP7MHealinglProjectile healDart) {
    local int i;
    local SAReplicationInfo saRepInfo;

    if (Controller(Owner).Pawn.Health < Controller(Owner).Pawn.HealthMax && healDart.IsA('MP7MHealinglProjectile')) {
        saRepInfo= class'SAReplicationInfo'.static.findSARI(healDart.Instigator.PlayerReplicationInfo);
        for(i= 0; i < saRepInfo.achievementPacks.Length; i++) {
            if (StockKFAchievements(saRepInfo.achievementPacks[i]) != none) {
                StockKFAchievements(saRepInfo.achievementPacks[i]).addProgress(StockIndex.HEALING_TOUCH, 1);
            }
        }
    }
}

defaultproperties {
    packName= "Stock KF"

    achievements(0)=(title="Experimenticide",description="Kill 100 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_18',maxProgress=100)
    achievements(1)=(title="Fascist Dietitian",description="Kill 200 bloats",image=Texture'KillingFloorHUD.Achievements.Achievement_21',maxProgress=200,notifyIncrement=0.2)
    achievements(2)=(title="Homer's Heroes",description="Kill 100 sirens",image=Texture'KillingFloorHUD.Achievements.Achievement_22',maxProgress=100,notifyIncrement=0.2)
    achievements(3)=(title="Keep Those Sneakers Off the Floor!",description="Kill 20 stalkers with explosives",image=Texture'KillingFloorHUD.Achievements.Achievement_23',maxProgress=20)
    achievements(4)=(title="Random Axe of Kindness",description="Kill 15 specimens with a fire axe in a single wave",image=Texture'KillingFloorHUD.Achievements.Achievement_24')
    achievements(5)=(title="Bitter Irony",description="Kill 2 scrakes with a chainsaw in a single wave",image=Texture'KillingFloorHUD.Achievements.Achievement_25')
    achievements(6)=(title="Hot Cross Fun",description="Kill 25 burning specimens with a crossbow",image=Texture'KillingFloorHUD.Achievements.Achievement_26',maxProgress=25,notifyIncrement=0.2)
    achievements(7)=(title="Dignity for the Dead",description="Kill 10 specimens feeding on dead teammates' corpses",image=Texture'KillingFloorHUD.Achievements.Achievement_27',maxProgress=10,notifyIncrement=0.5)
    achievements(8)=(title="Too Close For Comfort",description="Finish off a fleshpound using a melee attack",image=Texture'KillingFloorHUD.Achievements.Achievement_31')
    achievements(9)=(title="Master Surgeon",description="As a medic, kill 8 specimens using a knife in a single wave",image=Texture'KillingFloorHUD.Achievements.Achievement_32')
    achievements(10)=(title="It's What's Inside That Counts",description="Turn 500 specimens into giblets",image=Texture'KillingFloorHUD.Achievements.Achievement_33',maxProgress=500,notifyIncrement=0.25)
    achievements(11)=(title="Quarter Pounder With Ease",description="Turn 5 fleshpounds into giblets",image=Texture'KillingFloorHUD.Achievements.Achievement_34',maxProgress=5)
    achievements(12)=(title="Thin-Ice Pirouette",description="Complete 10 waves when the rest of your team has died",image=Texture'KillingFloorHUD.Achievements.Achievement_36',maxProgress=10,notifyIncrement=0.5)
    achievements(13)=(title="Philanthropist",description="Give 1,000 pounds to teamamtes who have 50% of your cash or less",image=Texture'KillingFloorHUD.Achievements.Achievement_37',maxProgress=1000)
    achievements(14)=(title="Straight Rush",description="Kill the patriarch before he has a chance to heal",image=Texture'KillingFloorHUD.Achievements.Achievement_40')
    achievements(15)=(title="The L.A.W. That Broke The Camel's Back",description="Deliver the Killing Blow to the Patriarch with a L.A.W. Rocket",image=Texture'KillingFloorHUD.Achievements.Achievement_41')
    achievements(16)=(title="Death To the Mad Scientist",description="Defeat the Patriarch on Suicidal",image=Texture'KillingFloorHUD.Achievements.Achievement_42')
    achievements(17)=(title="Experimentimillicide",description="Kill 1,000 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_19',maxProgress=1000,notifyIncrement=0.5)
    achievements(18)=(title="Experimentilottacide",description="Kill 10,000 specimens",image=Texture'KillingFloorHUD.Achievements.Achievement_20',maxProgress=10000,notifyIncrement=0.25)
    achievements(19)=(title="Explosive Personality",description="As Demolitions, kill 1000 specimens with the the pipebomb",image=Texture'KillingFloor2HUD.Achievements.Achievement_56',maxProgress=1000,notifyIncrement=0.1)
    achievements(20)=(title="Merry Men",description="Kill the patriarch when everyone is ONLY using crossbows",image=Texture'KillingFloor2HUD.Achievements.Achievement_58')
    achievements(21)=(title="Blooper Reel",description="Turn 500 Zeds into Giblets using the M79",image=Texture'KillingFloor2HUD.Achievements.Achievement_59',maxProgress=500,notifyIncrement=0.25)
    achievements(22)=(title="Dot of Doom",description="Get 25 headshots in a row with the EBR while using the laser sight",image=Texture'KillingFloor2HUD.Achievements.Achievement_60')
    achievements(23)=(title="SCAR'd",description="Kill 1000 specimens with the SCAR",image=Texture'KillingFloor2HUD.Achievements.Achievement_62',maxProgress=1000,notifyIncrement=0.25)
    achievements(24)=(title="Healing Touch",description="Heal 200 teammates with the MP7's medication dart",image=Texture'KillingFloor2HUD.Achievements.Achievement_63',maxProgress=200,notifyIncrement=0.20)
    achievements(25)=(title="Pound This",description="Kill 100 fleshpounds with the AA12",image=Texture'KillingFloor2HUD.Achievements.Achievement_64',maxProgress=100,notifyIncrement=0.2)
    achievements(26)=(title="Killer Junior",description="Kill 20 crawlers in mid-air with the M79",image=Texture'ServerAchievementsPack.StockKFAchievements.Achievement_26',maxProgress=20,notifyIncrement=0.5)
    achievements(27)=(title="Let Them Burn",description="Get 1000 points of burn damage with the MAC-10",image=Texture'KillingFloor2HUD.Achievements.Achievement_113',maxProgress=1000)
}
