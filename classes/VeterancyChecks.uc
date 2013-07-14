class VeterancyChecks extends Object;

function static bool isFieldMedic(KFPlayerReplicationInfo repInfo) {
    local class<KFVeterancyTypes> perk;

    perk= repInfo.ClientVeteranSkill;
    return perk.static.GetSyringeChargeRate(repInfo) >= 1.0 || 
            perk.static.GetHealPotency(repInfo) > 1.0;
}

function static bool isDemolitions(KFPlayerReplicationInfo repInfo) {
    local class<KFVeterancyTypes> perk;

    perk= repInfo.ClientVeteranSkill;
    return perk.static.AddDamage(repInfo, None, None, 100, class'DamTypeM32Grenade') > 100;
}
