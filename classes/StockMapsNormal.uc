class StockMapsNormal extends MapAchievementsBase;

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum) {
    Level.Game.Broadcast(PlayerController(Owner), mapname);
}

defaultproperties {
    packName= "Stock Maps - Normal"
    requiredDifficulty= 2.0

    mapIndexes(0)=(mapname="kf-abusementpark",achvIndex=19)
    mapIndexes(1)=(mapname="kf-aperture",achvIndex=18)
    mapIndexes(2)=(mapname="kf-bedlam",achvIndex=6)
    mapIndexes(3)=(mapname="kf-biohazard",achvIndex=8)
    mapIndexes(4)=(mapname="kf-bioticslab",achvIndex=4)
    mapIndexes(5)=(mapname="kf-crash",achvIndex=9)
    mapIndexes(6)=(mapname="kf-departed",achvIndex=10)
    mapIndexes(7)=(mapname="kf-evilsantaslair",achvIndex=17)
    mapIndexes(8)=(mapname="kf-farm",achvIndex=2)
    mapIndexes(9)=(mapname="kf-filthscross",achvIndex=11)
    mapIndexes(10)=(mapname="kf-foundry",achvIndex=5)
    mapIndexes(11)=(mapname="kf-hellride",achvIndex=21)
    mapIndexes(12)=(mapname="kf-hillbillyhorror",achvIndex=22)
    mapIndexes(13)=(mapname="kf-hospitalhorrors",achvIndex=12)
    mapIndexes(14)=(mapname="kf-icebreaker",achvIndex=13)
    mapIndexes(15)=(mapname="kf-icecave",achvIndex=20)
    mapIndexes(16)=(mapname="kf-manor",achvIndex=1)
    mapIndexes(17)=(mapname="kf-moonbase",achvIndex=23)
    mapIndexes(18)=(mapname="kf-mountainpass",achvIndex=14)
    mapIndexes(19)=(mapname="kf-offices",achvIndex=3)
    mapIndexes(20)=(mapname="kf-suburbia",achvIndex=15)
    mapIndexes(21)=(mapname="kf-waterworks",achvIndex=16)
    mapIndexes(22)=(mapname="kf-westlondon",achvIndex=0)
    mapIndexes(23)=(mapname="kf-wyre",achvIndex=7)

    achievements(0)=(title="Pub Crawl",description="Win a medium or long game on West London on Normal difficulty",image=Texture'KillingFloorHUD.Achievements.Achievement_0')
    achievements(1)=(title="Lord of the Manor",description="Win a medium or long game on Manor on Normal difficulty",image=Texture'KillingFloorHUD.Achievements.Achievement_1')
    achievements(2)=(title="Chicken Farmer",description="Win a medium or long game on Farm on Normal difficulty",image=Texture'KillingFloorHUD.Achievements.Achievement_2')
    achievements(3)=(title="The Boss",description="Win a medium or long game on Offices on Normal difficulty",image=Texture'KillingFloorHUD.Achievements.Achievement_3')
    achievements(4)=(title="Lab Cleaner",description="Win a medium or long game on Biotics Lab on Normal difficulty",image=Texture'KillingFloorHUD.Achievements.Achievement_4')
    achievements(5)=(title="Tin Man",description="Win a medium or long game on Foundry on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_44')
    achievements(6)=(title="A Bit Barmy",description="Win a medium or long game on Bedlam on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_47')
    achievements(7)=(title="Squirrel King of the Dark Forrest",description="Win a medium or long game on Wyre on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_50')
    achievements(8)=(title="Waste Disposal",description="Win a medium or long game on Biohazard on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_73')
    achievements(9)=(title="Warehouse Janitor",description="Win a medium or long game on Crash on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_77')
    achievements(10)=(title="Departure Gallery",description="Win a medium or long game on Departed on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_81')
    achievements(11)=(title="Running Late",description="Win a medium or long game on Filth's Cross on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_85')
    achievements(12)=(title="Gimme a Player!",description="Win a medium or long game on Hospital Horrors on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_89')
    achievements(13)=(title="Ice Cube",description="Win a medium or long game on Icebreaker on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_93')
    achievements(14)=(title="Daytrip",description="Win a medium or long game on Mountain Pass on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_97')
    achievements(15)=(title="Neighborhood Watch",description="Win a medium or long game on Suburbia on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_101')
    achievements(16)=(title="Slight Drip",description="Win a medium or long game on Waterworks on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_105')
    achievements(17)=(title="Walking In a Winter Horror Land",description="Win a medium or long game on Santa's Evil Lair on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_114')
    achievements(18)=(title="Science Got Done",description="Win a medium or long game on Aperture on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_133')
    achievements(19)=(title="Flea Circus",description="Win a medium or long game on Abusement Park on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_138')
    achievements(20)=(title="Snow Cave",description="Win a medium or long game on Ice Cave on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_171')
    achievements(21)=(title="Highway to Heaven",description="Win a medium or long game on Hellride on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_181')
    achievements(22)=(title="Third Cousins",description="Win a medium or long game on Hillbilly Horror on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_189')
    achievements(23)=(title="Here is To Us",description="Win a medium or long game on Moonbase on Normal difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_204')
}
