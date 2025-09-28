--[[
* Ashita - Copyright (c) 2014 - 2025 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--

addon.author            = 'Espe (spkywt)';
addon.name              = 'hxifish';
addon.desc              = 'Tracker for fishing statistics.';
addon.version           = '1.2.1';

-- Ashita Libs
require 'common'
local imgui             = require('imgui');
local settings          = require('settings');

-- Addon Custom Files
require 'constants'
require 'helpers'
--require 'packets'
config                  = require('defaults');
local moon              = require('.\\data\\moon');
local fishdata          = require('.\\data\\fishdata');


----------------------------------------------------------------------------------------------------
-- func: FishingTracker
-- desc: Shows fishing tracker window.
----------------------------------------------------------------------------------------------------
local function FishingTracker()
   -- Initialize the window draw.
   imgui.SetNextWindowBgAlpha(0.8);
   imgui.SetNextWindowSize({242, 0}, ImGuiSetCond_Always);
   if (imgui.Begin('Fishing Tracker', true, config.Window_Flags)) then
      -- Current Zone
      local currentZoneID = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
      local currentZoneName = AshitaCore:GetResourceManager():GetString('zones.names', currentZoneID);
      imgui.Text('Zone:  ' .. currentZoneName);
      
      -- Moon Phase
      local moon_table = GetMoon(moon);
      imgui.Text('Moon:  ' .. moon_table.MoonPhase .. ' (' .. moon_table.MoonPhasePercent .. '%)');
      
      -- Current Fishing Skill
      imgui.Text('Skill:');
      imgui.SameLine();
      local FishingSkill = config.Fishing.skill;
      local player = AshitaCore:GetMemoryManager():GetPlayer();
      if (FishingSkill == nil) then FishingSkill = player:GetCraftSkill(0):GetSkill(); end
      local FishingSkillMax = (player:GetCraftSkill(0):GetRank() + 1) * 10;
      local DisplaySkill = FishingSkill .. ' / ' .. FishingSkillMax;
      if (FishingSkillMax == FishingSkill) then
         if (FishingSkill == 100) then
            imgui.PushStyleColor(ImGuiCol_Text, {0, 1, 0, 1});
            DisplaySkill = DisplaySkill .. ' MAXED';
         else
            imgui.PushStyleColor(ImGuiCol_Text, {1, 0, 0, 1});
            DisplaySkill = DisplaySkill .. ' CAPPED';
         end
      elseif (FishingSkillMax - FishingSkill <= 2) and (FishingSkill < 98) then 
         imgui.PushStyleColor(ImGuiCol_Text, {0, 1, 0, 1});
         DisplaySkill = DisplaySkill .. ' RANK QUEST';
      else imgui.PushStyleColor(ImGuiCol_Text, {1, 1, 1, 1});
      end
      imgui.Text(DisplaySkill);
      imgui.PopStyleColor(1);
      imgui.Separator();
      
      -- Stats
      imgui.TextColored({1.0, 1.0, 0.4, 1.0},'Category     Session  All-Time');
      imgui.Separator();
      local var_stats = config.Fishing.session;
      local cfg_stats = config.Fishing.alltime;
      imgui.Text('Casts:       ' .. string.format("%-9s",var_stats.casts) .. cfg_stats.casts);
      imgui.Text('Fish:        ' .. string.format("%-9s",var_stats.fish) .. cfg_stats.fish);
      imgui.Text('Item:        ' .. string.format("%-9s",var_stats.item) .. cfg_stats.item);
      imgui.Text('Gil:         ' .. string.format("%-9s",var_stats.gil) .. cfg_stats.gil);
      imgui.Text('Monster:     ' .. string.format("%-9s",var_stats.monster) .. cfg_stats.monster);
      imgui.Text('No Catch:    ' .. string.format("%-9s",var_stats.noCatch) .. cfg_stats.noCatch);
      imgui.Text('Gave Up:     ' .. string.format("%-9s",var_stats.canceled) .. cfg_stats.canceled);
      imgui.Text('Lost:        ' .. string.format("%-9s",var_stats.lost) .. cfg_stats.lost);
      imgui.Text('Rod Break:   ' .. string.format("%-9s",var_stats.rodBreak) .. cfg_stats.rodBreak);
      imgui.Text('Line Break:  ' .. string.format("%-9s",var_stats.lineBreak) .. cfg_stats.lineBreak);
      imgui.Separator();
      local displaytime = config.Fishing.session.gph.totalTime + ((config.Fishing.session.gph.lastAction ~= 0) and (ashita.time.clock()['s'] - config.Fishing.session.gph.lastAction) or 0);
      imgui.Text('Time:        ' .. format_time(displaytime));
      imgui.Text('Gil:         ' .. comma_value(config.Fishing.session.gph.sum));
      imgui.Text('gph:         ' .. comma_value(config.Fishing.session.gph.value));
      if (config.Fishing.session.gph.lastAction == 0 and config.Fishing.session.gph.totalTime > 0) then
         local pausemsg = 'Paused due to inactivity > ' .. tostring(config.Fishing.session.gph.timeOut / 60) .. 'm'
         imgui.TextColored({1.0, 0.2, 0.2, 1.0}, pausemsg);
      end
      imgui.Separator();
      
      -- Catch History
      imgui.BeginChild('Catch History', {0, 169}, true);
         imgui.TextColored({1.0, 1.0, 0.4, 1.0}, 'Catch History');
         imgui.SameLine();
         show_help(imgui, 'Clear affects catch history\nClick item to change settings');
         imgui.Separator();
         if (config.Fishing.session.history) then
            for item_name, caught in pairs(config.Fishing.session.history) do
               imgui.Text(string.format("%4d", caught));
               imgui.SameLine();
               imgui.TextColored({1.0, 1.0, 1.0, 0.25}, 'x');
               imgui.SameLine();
               --imgui.Text(item_name);
               imgui.PushStyleColor(ImGuiCol_Button, {1, 1, 1, 0});
               if (imgui.SmallButton(item_name)) then
                  config.editItem.id            = fishdata[item_name].fishid;
                  config.editItem.name          = item_name;
                  config.editItem.oldValue      = config.Fishing.customPrices[item_name] or
                                                  fishdata[item_name].ah_price or
                                                  fishdata[item_name].sell_price;
                  config.editItem.newValue      = { config.editItem.oldValue };
                  config.editItem.show          = true;
               end
               imgui.PopStyleColor(1);
               
               if (imgui.IsItemHovered()) then
                  local price    = tostring(config.Fishing.customPrices[item_name] or
                                   fishdata[item_name].ah_price or
                                   fishdata[item_name].sell_price);
                  imgui.SetTooltip(caught .. ' x ' ..
                                   price  .. 'g = ' ..
                                   comma_value(caught * price) .. 'g');
               end
            end
         end
      imgui.EndChild();
      
      -- Button Bar
      imgui.PushStyleColor(ImGuiCol_Button, {1, 0.3, 0.2, 0.5});
      imgui.PushStyleColor(ImGuiCol_ButtonHovered, {1, 0.3, 0.2, 0.8});
      if (imgui.Button(' Clear Session ')) then
         config.Fishing.session = {
            casts          =  0;
            fish           =  0;
            item           =  0;
            gil            =  0;
            rodBreak       =  0;
            lineBreak      =  0;
            canceled       =  0;
            lost           =  0;
            noCatch        =  0;
            monster        =  0;
            gph            =  {
               value       =  0;
               sum         =  0;
               timeOut     =  60;
               totalTime   =  0;
               lastAction  =  0;
            };
            history        =  {};
         };
      end
      imgui.SameLine();
      if (imgui.Button(' Close Window ')) then config.Fishing.show = not config.Fishing.show; end
      imgui.PopStyleColor(2);
    end
   imgui.End();
end


----------------------------------------------------------------------------------------------------
-- func: UpdateGph
-- desc: Sets times needed for tracking gil per hour.
----------------------------------------------------------------------------------------------------
local function UpdateGph(t)
   local total_time = t or config.Fishing.session.gph.totalTime;
   local k = 60;
   local c = total_time / (total_time + k);
   local naive = 3600 * config.Fishing.session.gph.sum / total_time;
   config.Fishing.session.gph.value = math.floor(naive * c);
   
   return false;
end


----------------------------------------------------------------------------------------------------
-- func: EditFish
-- desc: Shows fishing tracker window.
----------------------------------------------------------------------------------------------------
local function EditItem()
   -- Initialize the window draw.
   imgui.SetNextWindowBgAlpha(0.8);
   imgui.SetNextWindowSize({0, 0}, ImGuiSetCond_Always);
   if (imgui.Begin('Edit Fish', true, config.Window_Flags)) then
      -- Window Text
      imgui.Text('Id:      ' .. config.editItem.id);
      imgui.Text('Name:    ' .. config.editItem.name);
      imgui.Text('Value:   ' .. config.editItem.oldValue);
      imgui.Separator();
      imgui.InputInt('##fishval', config.editItem.newValue, 25, 100);
      
      -- Buttons
      imgui.PushStyleColor(ImGuiCol_Button, {1, 0.3, 0.2, 0.5});
      imgui.PushStyleColor(ImGuiCol_ButtonHovered, {1, 0.3, 0.2, 0.8});
      if (imgui.Button(' Cancel ')) then 
         config.editItem.show = false;
      end
      imgui.SameLine();
      if (imgui.Button(' Save ')) then
         if (config.editItem.newValue[1] == config.editItem.oldValue) then
            config.editItem.show = false;
         else
            -- Set Custom Price
            config.Fishing.customPrices[config.editItem.name] = config.editItem.newValue[1];
            echo(addon.name,'Value for ' .. config.editItem.name ..
                            ' set to ' .. tostring(config.editItem.newValue[1]));
                            
            -- Recalculate Gil Total
            local recalc = 0;
            for item_name, caught in pairs(config.Fishing.session.history) do
               local item_value = config.Fishing.customPrices[item_name] or
                                  fishdata[item_name].ah_price or
                                  fishdata[item_name].sell_price;
               recalc = recalc + (item_value * caught);
            end
            
            -- Update Gph
            config.Fishing.session.gph.sum = recalc;
            UpdateGph();
            
            config.editItem.show = false;
         end
      end
      imgui.PopStyleColor(2);
    end
   imgui.End();
end


----------------------------------------------------------------------------------------------------
-- func: UpdateActivityTime
-- desc: Sets times needed for tracking gil per hour.
----------------------------------------------------------------------------------------------------
local function UpdateActivityTime()
   local current_time = ashita.time.clock()['s'];
   
   if (config.Fishing.session.gph.lastAction ~= 0) then
      local add_time = current_time - config.Fishing.session.gph.lastAction;
      config.Fishing.session.gph.totalTime = config.Fishing.session.gph.totalTime + add_time;
   end
   
   config.Fishing.session.gph.lastAction = current_time;
   
   return false;
end


----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('load', 'load_cb', function()
   local ok, res = pcall(function()
      return settings.load(config);
   end)
   
   if ok and type(res) == 'table' then
      config = res;
   else
      config = config:copy(true);
      --pcall(function() settings.save('settings') end)
      --settings.save();
      --config = settings.load(config);
   end
end);


----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Called when the addon is unloaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('unload', 'unload_cb', function()
   settings.save();
end);


-- func: command
-- desc: Event called when a command was entered.
----------------------------------------------------------------------------------------------------
ashita.events.register('command', 'command_cb', function(e)
   -- Get the arguments of the command..
   local args = e.command:args();
   if (#args == 0 or not args[1]:any('/hxifish')) then
      return;
   end
   
   if (args[1]:any('/hxifish')) then
      if (#args == 1) then
         echo(addon.name, '/hxifish show           show tracking window');
         echo(addon.name, '/hxifish timeout #      set timeout in minutes for gph calc');
         echo(addon.name, '/hxifish skills           toggle tracking fishing or all skills');
      elseif (#args == 2) then
         if (args[2]:any('show')) then
            config.Fishing.show = true;
         elseif (args[2]:any('test')) then
            --sendFakeFishingSkillup();
         elseif (args[2]:any('skills')) then
            config.trackAllSkills = not config.trackAllSkills;
            settings.save();
            echo(addon.name, 'Tracking all skills: ' .. tostring(config.trackAllSkills));
         end
      elseif (#args == 3) then
         if (args[2]:any('timeout')) then
            if (args[3]:match('^%d+$') and tonumber(args[3]) >= 1) then
               config.Fishing.session.gph.timeOut = tonumber(args[3] * 60);
               settings.save();
               echo(addon.name, 'GPH inactivity timeout set to ' .. tostring(args[3]) .. ' minute(s).');
            else
               echo(addon.name, 'Usage: /hxifish timeout <number in minutes - minimum 1>');
               echo(addon.name, 'Current: ' .. tostring(config.Fishing.session.gph.timeOut / 60));
            end
         end
      else
         echo(addon.name, 'Unrecognized command.');
      end
   end

   return false;
end);


---------------------------------------------------------------------------------------------------
-- func: incoming_text
-- desc: Event called when the addon is asked to handle an incoming chat line.
---------------------------------------------------------------------------------------------------
ashita.events.register('text_in', 'text_in_cb', function(e)
    local mode = e.mode;
    local message = e.message;
    local modifiedmode = e.modifiedmode;
    local blocked = e.blocked;
    
    -- Do nothing if the line is already blocked..
    if (blocked) then return false; end

    -- Handle the modified message if its set..
    if (modifiedmessage ~= nil and #modifiedmessage > 0) then message = modifiedmessage; end
        
    -- Check for double-chat lines (ie. npc chat)..
    if (message:startswith(string.char(0x1E, 0x01))) then return false; end
   
    -- Remove colors form message
    local originalmsg = message;
   message = string.strip_colors(message);
   
   --echo('debug', AshitaCore:GetResourceManager():GetString('areas', party:GetMemberZone(0)));

   -- Start Fishing --
   local party = AshitaCore:GetMemoryManager():GetParty();
   local playerName = party:GetMemberName(0);
   
   if (config.Status == 'FISHING') then
      local hookNothing = string.match(message, "You didn't catch anything.");
      local fishSuccess = string.match(message, playerName .. " caught (.*)!");
      local lineBreak   = string.match(message, "Your line breaks.");
      local rodBreak    = string.match(message, "Your rod breaks.");
      local stopFish    = string.match(message, "You give up.") or
                     string.match(message, "You give up and reel in your line.");
      local lostFish     =   string.match(message, "You lost your catch.") or 
                     string.match(message, "You lost your catch due to your lack of skill.");
      local monster     = string.match(message, playerName .. " caught a monster!");
      --string.match(message, "You cannot carry any more items.");
      --string.match(message, "Something caught the hook!")
      --string.match(message, "You feel something pulling at your line.")

      -- Update Session, All-Time, & Catch History
      if (hookNothing or lineBreak or rodBreak or stopFish or lostFish or monster or fishSuccess) then
         if hookNothing then
            config.Fishing.session.noCatch   = config.Fishing.session.noCatch + 1;
            config.Fishing.alltime.noCatch   = config.Fishing.alltime.noCatch + 1;
         elseif lineBreak then
            config.Fishing.session.lineBreak = config.Fishing.session.lineBreak + 1;
            config.Fishing.alltime.lineBreak = config.Fishing.alltime.lineBreak + 1;
         elseif rodBreak then
            config.Fishing.session.rodBreak  = config.Fishing.session.rodBreak + 1;
            config.Fishing.alltime.rodBreak  = config.Fishing.alltime.rodBreak + 1;
         elseif stopFish then
            config.Fishing.session.canceled  = config.Fishing.session.canceled + 1;
            config.Fishing.alltime.canceled  = config.Fishing.alltime.canceled + 1;
         elseif lostFish then
            config.Fishing.session.lost      = config.Fishing.session.lost + 1;
            config.Fishing.alltime.lost      = config.Fishing.alltime.lost + 1;
         elseif monster then
            config.Fishing.session.monster   = config.Fishing.session.monster + 1;
            config.Fishing.alltime.monster   = config.Fishing.alltime.monster + 1;
         end
         
         config.Status = nil;
         UpdateActivityTime();
         settings.save();
      end
      
   end
   
    return false;
end);


---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Called when our addon receives an incoming packet.
---------------------------------------------------------------------------------------------------
ashita.events.register('packet_in', 'packet_in_cb', function(e)
   local id = e.id;
   local size = e.size;
   local packet = e.data;
   
   -- Fishing
   if (config.Status == 'FISHING') then
      -- Capture incoming 'Item Update' packet to see what was catch
      if (id == 0x020) then
         local item  = struct.unpack('H', packet, 0x0C + 1);
         local count = struct.unpack('H', packet, 0x04 + 1);
         
         if (item ~= 0) then
            local rmItem = AshitaCore:GetResourceManager():GetItemById(item);
            local item_name = (rmItem.Name and rmItem.Name[1]) or (rmItem.Name and rmItem.Name[0]) or nil;
            
            if (fishdata[item_name]) then
               -- Update Catch Stats
               if (item == 65535) then
                  config.Fishing.session.gil = config.Fishing.session.gil + count;
                  config.Fishing.alltime.gil = config.Fishing.alltime.gil + count;
               elseif (fishdata[item_name].item == 1) then
                  config.Fishing.session.item = config.Fishing.session.item + count;
                  config.Fishing.alltime.item = config.Fishing.alltime.item + count;
               elseif (fishdata[item_name].item == 0) then
                  config.Fishing.session.fish = config.Fishing.session.fish + count;
                  config.Fishing.alltime.fish = config.Fishing.alltime.fish + count;
               else
                  local errMsg = 'unhandled catch type';
                  echo(addon.name, errMsg);
               end
               
               -- Update Catch History
               if (config.Fishing.session.history[item_name] == nil) then
                  config.Fishing.session.history[item_name] = 0;
               end
               config.Fishing.session.history[item_name] = config.Fishing.session.history[item_name] + count;
               
               if (config.Fishing.alltime.history[item_name] == nil) then
                  config.Fishing.alltime.history[item_name] = 0;
               end
               config.Fishing.alltime.history[item_name] = config.Fishing.alltime.history[item_name] + count;
               
               -- Update Catch Value
               local catch_value = config.Fishing.customPrices[item_name] or
                                   fishdata[item_name].ah_price or
                                   fishdata[item_name].sell_price;
               config.Fishing.session.gph.sum = config.Fishing.session.gph.sum + catch_value;
               
               settings.save();
            end
         end
      end
   end
   
   -- Skill Ups
   if (id == 0x029) then
      local message  = struct.unpack('H', packet, 0x18 + 1);
      local param1   = struct.unpack('H', packet, 0x0C + 1);
      local param2   = struct.unpack('H', packet, 0x10 + 1);
      
      -- Restrict to Fishing Skillups for now
      if ((config.trackAllSkills and param1 >= 48) or param1 == 48) then
         if (message == 38) then
            if (get_skill_level(param1) == nil) then set_skill_level(param1); end
            set_skill_level(param1, get_skill_level(param1) + tonumber(param2 / 10));
            settings.save();
         end
         
         if (message == 53) then
            if (get_skill_level(param1) == nil) then set_skill_level(param1); end
            if (get_skill_level(param1) < tonumber(param2)) then
               set_skill_level(param1, tonumber(param2));
               settings.save();
            end
         end
      end
   end
   
   -- Zone IN / Zone Out
   if (id == 0x00A or id == 0x00B) then
      if (config.Status ~= nil) then
         config.Status = nil;
         settings.save();
      end
   end
   
   return false;
end);


----------------------------------------------------------------------------------------------------
-- func: outgoing_packet
-- desc: Called when our addon sends an outgoing packet.
----------------------------------------------------------------------------------------------------
ashita.events.register('packet_out', 'packet_out_cb', function(e) -- id, size, data
   -- Capture outgoing 'Action' packets
   if (e.id == 0x01A) then
      local newpacket = e.data:totable();
      
      -- 0x0A | Category | Cast Fishing Rod <= 14 (0x000E)
      if (newpacket[0x0A+1] == 14) then
         config.Status = 'FISHING';
         config.Fishing.show = true;
         config.Fishing.session.casts = config.Fishing.session.casts + 1;
         config.Fishing.alltime.casts = config.Fishing.alltime.casts + 1;
         UpdateActivityTime();
         settings.save();
      end
   end
   
   -- Capture outgoing 'Fishing Action' packets
   if (e.id == 0x110 and config.Status == 'FISHING') then
      local newpacket = e.data:totable();
      
      -- 0x0E | Action | End <= 4 - 0x04 - 0000 0100 - ''
      if (newpacket[0x0E+1] == 0x04) then
         config.Status = nil;
         config.Fishing.session.canceled = config.Fishing.session.canceled + 1;
         config.Fishing.alltime.canceled = config.Fishing.alltime.canceled + 1;
         UpdateActivityTime();
         settings.save();
      end
   end
   
   -- Logout
   if (e.id == 0x0E7) then
      if (config.Status ~= nil) then
         config.Status = nil;
         settings.save();
      end
   end

    return false;
end);

----------------------------------------------------------------------------------------------------
-- func: d3d_present
-- desc: Event called when the Direct3D device is presenting a scene.
----------------------------------------------------------------------------------------------------
ashita.events.register('d3d_present', 'present_cb', function ()
   -- Prevent Render
   local player = GetPlayerEntity();
   if (player == nil) then
      return;
   end
   
   -- Display Fishing Tracker
   local ok, err = pcall(function()
      if (config.Fishing.show) then
         FishingTracker();
      end
   end)
   if not ok then
      echo(addon.name, 'Error during render: ' .. tostring(err));
      AshitaCore:GetChatManager():QueueCommand(-1, string.format('/addon unload %s', addon.name));
   end
   
   -- Display Item Edit Window
   local ok, err = pcall(function()
      if (config.editItem.show) then
         EditItem();
      end
   end)
   if not ok then
      echo(addon.name, 'Error during render: ' .. tostring(err));
      AshitaCore:GetChatManager():QueueCommand(-1, string.format('/addon unload %s', addon.name));
   end
   
   -- Gil/Hour Updates 
   if ((ashita.time.clock()['s'] % 3) == 0) then
      if (config.Fishing.session.gph.lastAction > 0) then
         local check_time = config.Fishing.session.gph.lastAction + config.Fishing.session.gph.timeOut;
         local add_time = ashita.time.clock()['s'] - config.Fishing.session.gph.lastAction;
         if (check_time < ashita.time.clock()['s']) then
            config.Fishing.session.gph.totalTime = config.Fishing.session.gph.totalTime + add_time;
            config.Fishing.session.gph.lastAction = 0;
         end
         
         local total_time = config.Fishing.session.gph.totalTime + add_time;
         if (total_time > 0) then
            UpdateGph(total_time);
         end
      end
   end
end);