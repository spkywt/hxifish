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
-- func: tool_tip
-- desc: Shows a tooltip with ImGui.
----------------------------------------------------------------------------------------------------
function tool_tip(imgui, desc)
   if (imgui.IsItemHovered()) then imgui.SetTooltip(desc); end
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
-- func: format_time
-- desc: show time as #h #m #s.
----------------------------------------------------------------------------------------------------
function format_time(sec)
   sec = math.floor(sec or 0)

   local h = math.floor(sec / 3600)
   local m = math.floor((sec % 3600) / 60)
   local s = sec % 60

   local parts = {}
   if h > 0 then table.insert(parts, string.format("%dh", h)) end
   if m > 0 or h > 0 then table.insert(parts, string.format("%dm", m)) end
   table.insert(parts, string.format("%ds", s))

   return table.concat(parts, " ")
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
   moon_table.MoonIndex = moon_index;
   moon_table.MoonPhase = moon.Phase[moon_index];
   moon_table.MoonPhasePercent = moon.PhasePercent[moon_index];
   return moon_table;
end

--=============================================================================
-- Return equipment data
---@return table equipTable Current equipment information
--=============================================================================
-- based on code from LuAshitacast by Thorny
-- revised function taken from chains
--=============================================================================
-- Combined gData.GetEquipment and gEquip.GetCurrentEquip
--=============================================================================
GetEquipment = function()
    local inventoryManager = AshitaCore:GetMemoryManager():GetInventory();
    local equipTable = {};

    for k, v in pairs(EquipSlotNames) do
        local equippedItem = inventoryManager:GetEquippedItem(k - 1);
        local index = bit.band(equippedItem.Index, 0x00FF);
        local eqEntry = {};
        if (index == 0) then
            eqEntry.Container = 0;
            eqEntry.Item = nil;
        else
            eqEntry.Container = bit.band(equippedItem.Index, 0xFF00) / 256;
            eqEntry.Item = inventoryManager:GetContainerItem(eqEntry.Container, index);
            if (eqEntry.Item.Id == 0) or (eqEntry.Item.Count == 0) then
                eqEntry.Item = nil;
            end
        end
        if (type(eqEntry) == 'table') and (eqEntry.Item ~= nil) then
            local resource = AshitaCore:GetResourceManager():GetItemById(eqEntry.Item.Id);
            if (resource ~= nil) then
                local singleTable = {};
                singleTable.Container = eqEntry.Container;
                singleTable.Item = eqEntry.Item;
                singleTable.Name = resource.Name[1];
                singleTable.Resource = resource;
                equipTable[v] = singleTable;
            end
        end
    end

    return equipTable;
end