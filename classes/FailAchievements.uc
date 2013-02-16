class FailAchievements extends AchievementPackPartImpl;

enum FailIndex {
    GORED_FAST
};

defaultproperties {
    packName= "Fail Pack"

    achievements(0)=(title="Gored Fast",description="Be killed by a headless gorefast")
    achievements(1)=(title="",description="Kill 20 headless bloats with pipe bombs",maxProgress=20,notifyIncrement=0.20)
    achievements(2)=(title="",description="Die with your syringe, welder, or knife out 10 times",maxProgress=10,notifyIncrement=0.5)
    achievements(3)=(title="",description="Die on wave 1 with a level 6 perk on normal difficulty")
    achievements(4)=(title="",description="Kill 20 stalkers with impact damage from explosives",maxProgress=20,notifyIncrement=0.20)
    achievements(5)=(title="",description="Be killed while still having full armor")
    achievements(6)=(title="",description="Enrage a fleshpound with the 9mm or dual 9mm")
    achievements(7)=(title="",description="Light 20 scrakes or fleshpounds on fire",maxProgress=20,notifyIncrement=0.20)
    achievements(8)=(title="",description="Be killed by bloat bile as a berserker or medic")
    achievements(9)=(title="",description="Enrage 50 scrakes with explosives",maxProgress=50,notifyIncrement=0.1)
    achievements(10)=(title="",description="Be killed by your own explosive, detonated by bloat bile or a husk fireball")
}
