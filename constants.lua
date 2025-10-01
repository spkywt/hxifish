require('common')

-- Constants
ZoneType = {[0] = 1,[26] = 1,[32] = 1,[48] = 1,[50] = 1,[70] = 1,[71] = 1,[80] = 1,[87] = 1,[94] = 1,[189] = 1,[199] = 1,[214] = 1,[219] = 1,[230] = 1,[231] = 1,[232] = 1,[233] = 1,[234] = 1,[235] = 1,[236] = 1,[237] = 1,[238] = 1,[239] = 1,[240] = 1,[241] = 1,[242] = 1,[243] = 1,[244] = 1,[245] = 1,[246] = 1,[247] = 1,[248] = 1,[249] = 1,[250] = 1,[251] = 1,[252] = 1,[256] = 1,[257] = 1,[280] = 1,[284] = 1,[285] = 1};

SkillTypes = {[48]="Fishing",[49]="Woodworking",[50]="Smithing",[51]="Goldsmithing",[52]="Clothcraft",[53]="Leathercraft",[54]="Bonecraft",[55]="Alchemy",[56]="Cooking",[57]="Synergy",[58]="Rid",[59]="Dig"};

EquipSlotNames = T{[1] = 'Main',[2] = 'Sub',[3] = 'Range',[4] = 'Ammo',[5] = 'Head',[6] = 'Body',[7] = 'Hands',[8] = 'Legs',[9] = 'Feet',[10] = 'Neck',[11] = 'Waist',[12] = 'Ear1',[13] = 'Ear2',[14] = 'Ring1',[15] = 'Ring2',[16] = 'Back'};

return {
   ZoneType = ZoneType,
   SkillTypes = SkillTypes,
   EquipSlotNames = EquipSlotNames
}