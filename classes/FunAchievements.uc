class FunAchievements extends AchievementPackPartImpl;

enum FunIndex {
    MEDIC_GAME, GOOMBA_STOMP, BLUNT_TRAUMA, SHORYUKEN, IM_RICH
};

function Timer() {
    if (KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill != class'KFVetFieldMedic') {
        achievements[FunIndex.MEDIC_GAME].canEarn= false;
    }
}

function MatchStarting() {
    if (KFPlayerReplicationInfo(PlayerController(Owner).PlayerReplicationInfo).ClientVeteranSkill == class'KFVetFieldMedic') {
        achievements[FunIndex.MEDIC_GAME].canEarn= true;
    }
}

event matchEnd(string mapname, float difficulty, int length, byte result) {
    if (length == KFGameType(Level.Game).GL_Long && achievements[FunIndex.MEDIC_GAME].canEarn) {
        achievementCompleted(FunIndex.MEDIC_GAME);
    }
}

event killedMonster(Pawn target, class<DamageType> damageType) {
    achievements[FunIndex.MEDIC_GAME].canEarn= false;
}

defaultproperties {
    packName= "Fun Pack"

    achievements(0)=(title="Medic Game",description="Play and win a long game as medic, without killing a single specimen")
    achievements(1)=(title="Goomba Stomp",description="Kill a crawler by jumping on it")
    achievements(2)=(title="Blunt Trauma",description="Kill 10 husks with impact head shots",maxProgress=10,notifyIncrement=0.5)
    achievements(3)=(title="Shoryuken",description="Uppercut 10 scrakes in a game")
    achievements(4)=(title="I'm Rich!",description="Hold over £10000")
    achievements(5)=(title="",description="")
}
