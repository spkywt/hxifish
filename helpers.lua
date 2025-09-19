--[[
 * ItemWatch - Copyright (c) 2016 atom0s [atom0s@live.com]
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
 * Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
 *
 * By using ItemWatch, you agree to the above license and its terms.
 *
 *      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
 *                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
 *                    endorses you or your use.
 *
 *   Non-Commercial - You may not use the material (ItemWatch) for commercial purposes.
 *
 *   No-Derivatives - If you remix, transform, or build upon the material (ItemWatch), you may not distribute the
 *                    modified material. You are, however, allowed to submit the modified works back to the original
 *                    ItemWatch project in attempt to have it added to the original project.
 *
 * You may not apply legal terms or technological measures that legally restrict others
 * from doing anything the license permits.
 *
 * No warranties are given.
]]--

require 'common'

----------------------------------------------------------------------------------------------------
-- func: echo
-- desc: Prints out a message with the Itemwatch tag at the front.
----------------------------------------------------------------------------------------------------
function echo(label, msg)
	local txt = '\31\200[\31\05' .. label .. '\31\200] \31\130' .. msg;
    print(txt);
end

----------------------------------------------------------------------------------------------------
-- func: wait
-- desc: Waits for 1, or specified amount, of seconds.
----------------------------------------------------------------------------------------------------
local function wait(seconds)
    local time = seconds or 1;
    local start = os.time();
    repeat until os.time() == start + time;
end

----------------------------------------------------------------------------------------------------
-- func: show_help
-- desc: Shows a tooltip with ImGui.
----------------------------------------------------------------------------------------------------
function show_help(imgui, desc)
    imgui.TextDisabled('(?)');
    if (imgui.IsItemHovered()) then
        imgui.SetTooltip(desc);
    end
end

----------------------------------------------------------------------------------------------------
-- from sam_lie
-- Compatible with Lua 5.0 and 5.1.
-- Disclaimer : use at own risk especially for hedge fund reports :-)
-- add comma to separate thousands
----------------------------------------------------------------------------------------------------
function comma_value(amount)
	local formatted = amount;
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2');
		if (k == 0) then break; end
	end
	return formatted;
end

----------------------------------------------------------------------------------------------------
-- func: get_skill_level // set_skill_level
-- desc: Shows a tooltip with ImGui.
----------------------------------------------------------------------------------------------------
function get_skill_level(sID)
	if (sID == 48) then
      if not (default_config[playerName][SkillTypes[sID]]) then
         default_config[playerName][SkillTypes[sID]] = { skill = nil };
      end
   
      return default_config[playerName][SkillTypes[sID]].skill;
   end
   
   return false;
end

function set_skill_level(sID, newVal)
	if (sID == 48) then
      local player = AshitaCore:GetMemoryManager():GetPlayer();
      local jobskill = player:GetCraftSkill(sID - 48):GetSkill()
      
		newVal = newVal or jobskill;
      newVal = tonumber(string.format("%.1f", newVal));
		default_config[playerName][SkillTypes[sID]].skill = newVal;
      
		if (newVal < jobskill) then
			default_config[playerName][SkillTypes[sID]].skill = jobskill;
		elseif ((newVal - 1.4) > jobskill) then
			default_config[playerName][SkillTypes[sID]].skill = jobskill;
		end
      
      echo(SkillTypes[sID] .. ' Skill', '' .. default_config[playerName][SkillTypes[sID]].skill);
	end
end

----------------------------------------------------------------------------------------------------
-- Helper functions borrowed from luashitacast
----------------------------------------------------------------------------------------------------
function GetTimestamp()
   local pVanaTime = ashita.memory.find('FFXiMain.dll', 0,
                                      'B0015EC390518B4C24088D4424005068', 0,
                                      0);
   local pointer = ashita.memory.read_uint32(pVanaTime + 0x34);
   local rawTime = ashita.memory.read_uint32(pointer + 0x0C) + 92514960;
   local timestamp = {};
   timestamp.day = math.floor(rawTime / 3456);
   timestamp.hour = math.floor(rawTime / 144) % 24;
   timestamp.minute = math.floor((rawTime % 144) / 2.4);
   return timestamp;
end

function GetWeather()
   local pWeather = ashita.memory.find('FFXiMain.dll', 0,
                                     '66A1????????663D????72', 0, 0);
   local pointer = ashita.memory.read_uint32(pWeather + 0x02);
   return ashita.memory.read_uint8(pointer + 0);
end

function GetMoon(moon)
   local timestamp = GetTimestamp();
   local moon_index = ((timestamp.day + 26) % 84) + 1;
   local moon_table = {};
   moon_table.MoonPhase = moon.Phase[moon_index];
   moon_table.MoonPhasePercent = moon.PhasePercent[moon_index];
   return moon_table;
end