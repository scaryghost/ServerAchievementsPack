class StockAchievements extends AchievementPackPartImpl
    abstract;

function bool checkCounter(int counter, byte achvIndex) {
    if (counter <= 0) {
        achievementCompleted(achvIndex);
    }
    return true;
}
