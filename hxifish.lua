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

addon.author   = 'Espe (spkywt)';
addon.name     = 'hxifish';
addon.desc     = 'Tracker for fishing statistics.';
addon.version  = '1.0.2';

-- Ashita Libs
require 'common'
local imgui       = require('imgui');
local settings    = require('settings');

-- Addon Files
require 'constants'
require 'helpers'
local moon        = require('.\\data\\moon');

----------------------------------------------------------------------------------------------------
-- func: settings
-- desc: Initialize settings
----------------------------------------------------------------------------------------------------
config = require('config');
local default_settings =
{
   Fishing					=	{
      skill				   =	nil;
      stats				   =	{
         casts			   =	0;
         fish			   =	0;
         item			   =	0;
         gil				=	0;
         rodBreak		   =	0;
         lineBreak		=	0;
         canceled		   =	0;
         noCatch			=	0;
         monster			=	0;
      };
   };
};

----------------------------------------------------------------------------------------------------
-- func: ShowFishingTracker
-- desc: Shows fishing tracker window.
----------------------------------------------------------------------------------------------------
local function ShowFishingTracker()
	-- Initialize the window draw.
   imgui.SetNextWindowBgAlpha(0.8);
   imgui.SetNextWindowSize({236, 457}, ImGuiSetCond_Always);
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
		local FishingSkill = config.settings.Fishing.skill;
      local player = AshitaCore:GetMemoryManager():GetPlayer();
		if (FishingSkill == nil) then FishingSkill = player:GetCraftSkill(0):GetSkill(); end
		local FishingSkillMax = (player:GetCraftSkill(0):GetRank() + 1) * 10;
		local DisplaySkill = FishingSkill .. ' / ' .. FishingSkillMax;
		if (FishingSkillMax == FishingSkill) then
			imgui.PushStyleColor(ImGuiCol_Text, 1, 0, 0, 1);
			DisplaySkill = DisplaySkill .. ' MAXED';
		elseif (FishingSkillMax - FishingSkill <= 2) then 
			imgui.PushStyleColor(ImGuiCol_Text, 0, 1, 0, 1);
			DisplaySkill = DisplaySkill .. ' RANK QUEST';
		else imgui.PushStyleColor(ImGuiCol_Text, {1, 1, 1, 1});
		end
		imgui.Text(DisplaySkill);
		imgui.PopStyleColor(1);
		imgui.Separator();
		
		-- Stats
		imgui.TextColored({1.0, 1.0, 0.4, 1.0},'Category     Session  All-Time');
		imgui.Separator();
		local var_stats = config.fishTracker.stats;
		local cfg_stats = config.settings.Fishing.stats;
		imgui.Text('Fish:        ' .. string.format("%-9s",var_stats.fish) .. cfg_stats.fish);
		imgui.Text('Item:        ' .. string.format("%-9s",var_stats.item) .. cfg_stats.item);
		imgui.Text('Monster:     ' .. string.format("%-9s",var_stats.monster) .. cfg_stats.monster);
		imgui.Text('No Catch:    ' .. string.format("%-9s",var_stats.noCatch) .. cfg_stats.noCatch);
		imgui.Text('Stop/Lost:   ' .. string.format("%-9s",var_stats.canceled) .. cfg_stats.canceled);
		imgui.Text('Rod Break:   ' .. string.format("%-9s",var_stats.rodBreak) .. cfg_stats.rodBreak);
		imgui.Text('Line Break:  ' .. string.format("%-9s",var_stats.lineBreak) .. cfg_stats.lineBreak);
		imgui.Separator();
		imgui.Text('Casts:       ' .. string.format("%-9s",var_stats.casts) .. cfg_stats.casts);
		imgui.Text('Gil:         ' .. string.format("%-9s",var_stats.gil) .. cfg_stats.gil);
		imgui.Separator();
		
		-- Catch History
		imgui.BeginChild('Catch History', {0, 169}, true);
			imgui.TextColored({1.0, 1.0, 0.4, 1.0}, 'Catch History');
			imgui.SameLine();
			show_help(imgui, 'Clear affects catch history\nReset affects catch history & session counts');
			imgui.SameLine(imgui.GetWindowWidth() - 50);
			imgui.PushStyleColor(ImGuiCol_Button, {1, 1, 1, 0.1});
			if (imgui.SmallButton('Clear')) then config.fishHistory = {}; end
			imgui.PopStyleColor(1);
			imgui.Separator();
			for item, casts in pairs(config.fishHistory) do
				imgui.Text(string.format("%4d", config.fishHistory[item]));
				imgui.SameLine();
				imgui.TextColored({1.0, 1.0, 1.0, 0.25}, 'x');
				imgui.SameLine();
				imgui.Text(item);
			end
		imgui.EndChild();
		
		-- Button Bar
      imgui.PushStyleColor(ImGuiCol_Button, {1, 0.3, 0.2, 0.5});
		imgui.PushStyleColor(ImGuiCol_ButtonHovered, {1, 0.3, 0.2, 0.8});
		if (imgui.Button(' Clear Session ')) then
			config.fishTracker.stats	= {casts=0;fish=0;item=0;gil=0;rodBreak=0;lineBreak=0;canceled=0;noCatch=0;monster=0;};
			config.fishHistory	= {};
		end
		imgui.SameLine();
		if (imgui.Button(' Close Window ')) then config.fishTracker.show = not config.fishTracker.show; end
		imgui.PopStyleColor(2);
    end
	imgui.End();
end


----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('load', 'load_cb', function()
   local ok, err = pcall(function()
      config.settings = settings.load(default_settings);
   end)
   
   if not ok then
      settings.save();
      config.settings = settings.load(default_settings);
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
         echo(addon.name, '/hxifish show         show tracker');
         echo(addon.name, '/hxifish reset        clear all-time data');
         echo(addon.name, '/hxifish reload       reload addon');
         echo(addon.name, '/hxifish unload       unload addon');
      elseif (#args == 2) then
         if (args[2]:any('show')) then
            config.fishTracker.show = true;
         elseif (args[2]:any('reload')) then
            AshitaCore:GetChatManager():QueueCommand(-1, string.format('/addon reload %s', addon.name));
         elseif (args[2]:any('unload')) then
            AshitaCore:GetChatManager():QueueCommand(-1, string.format('/addon unload %s', addon.name));
         elseif (args[2]:any('reset')) then
            echo(addon.name, 'Reset all-time tracking data?');
            echo(addon.name, '/hxifish reset confirm');
         end
      elseif (#args == 3) then
         if (args[2]:any('reset')) then
            if (args[3]:any('confirm')) then
               config.fishHistory	= {};
               for k,v in pairs(config.fishTracker.stats) do config.fishTracker.stats[k] = 0; end
               for k,v in pairs(config.settings.Fishing.stats) do
                  config.settings.Fishing.stats[k] = 0; end
               settings.save();
               echo(addon.name, 'All-time data has been reset.');
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
		local lostFish	  =	string.match(message, "You lost your catch.") or 
							string.match(message, "You lost your catch due to your lack of skill.");
		local monster	  = string.match(message, playerName .. " caught a monster!");
		--string.match(message, "You cannot carry any more items.");
		--string.match(message, "Something caught the hook!")
		--string.match(message, "You feel something pulling at your line.")

		-- Update Session, All-Time, & Catch History
		if (hookNothing or lineBreak or rodBreak or stopFish or lostFish or monster or fishSuccess) then
			if hookNothing then
				config.fishTracker.stats.noCatch = config.fishTracker.stats.noCatch + 1;
				config.settings.Fishing.stats.noCatch = config.settings.Fishing.stats.noCatch + 1;
			elseif lineBreak then
				config.fishTracker.stats.lineBreak = config.fishTracker.stats.lineBreak + 1;
				config.settings.Fishing.stats.lineBreak = config.settings.Fishing.stats.lineBreak + 1;
			elseif rodBreak then
				config.fishTracker.stats.rodBreak = config.fishTracker.stats.rodBreak + 1;
				config.settings.Fishing.stats.rodBreak = config.settings.Fishing.stats.rodBreak + 1;
			elseif stopFish or lostFish then
				config.fishTracker.stats.canceled = config.fishTracker.stats.canceled + 1;
				config.settings.Fishing.stats.canceled = config.settings.Fishing.stats.canceled + 1;
			elseif monster then
				config.fishTracker.stats.monster = config.fishTracker.stats.monster + 1;
				config.settings.Fishing.stats.monster = config.settings.Fishing.stats.monster + 1;
			end
			
			config.fishTracker.stats.casts = config.fishTracker.stats.casts + 1;
			config.settings.Fishing.stats.casts = config.settings.Fishing.stats.casts + 1;
			config.Status = nil;
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
				for x = 1, table.getn(ListAll) do
					local rmItem = AshitaCore:GetResourceManager():GetItemById(item);
               local item_name = (rmItem.Name and rmItem.Name[1]) or (rmItem.Name and rmItem.Name[0]) or nil;
               
               if (ListAll[x] == item_name) then
                  --local item_name = items[item].en;
						local item_quantity = count;
						
						for _,v in pairs(ListFish) do
						  if v == item_name then
							config.fishTracker.stats.fish = config.fishTracker.stats.fish + item_quantity;
							config.settings.Fishing.stats.fish = config.settings.Fishing.stats.fish + item_quantity;
							break
						  end
						end
						
						for _,v in pairs(ListItem) do
						  if v == item_name then
							if (item == 65535) then
								config.fishTracker.stats.gil = config.fishTracker.stats.gil + item_quantity;
								config.settings.Fishing.stats.gil = config.settings.Fishing.stats.gil + item_quantity;
							else
								config.fishTracker.stats.item = config.fishTracker.stats.item + item_quantity;
								config.settings.Fishing.stats.item = config.settings.Fishing.stats.item + item_quantity;
							end
							break
						  end
						end
						
						-- Update Catch History
						if (config.fishHistory[item_name] == nil) then config.fishHistory[item_name] = 0; end
						config.fishHistory[item_name] = config.fishHistory[item_name] + item_quantity;
						
						settings.save();
						break;
					end
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
      if (param1 == 48) then
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
		if (config.Status ~= nil) then config.Status = nil; end
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
         config.fishTracker.show = true;
         config.fishTracker.stats.casts = config.fishTracker.stats.casts + 1;
			config.settings.Fishing.stats.casts = config.settings.Fishing.stats.casts + 1;
         settings.save();
      end
	end
	
	-- Capture outgoing 'Fishing Action' packets
	if (e.id == 0x110 and config.Status == 'FISHING') then
		local newpacket = e.data:totable();
		
		-- 0x0E | Action | End <= 4 - 0x04 - 0000 0100 - ''
		if (newpacket[0x0E+1] == 0x04) then
			config.Status = nil;
			config.fishTracker.stats.canceled = config.fishTracker.stats.canceled + 1;
			config.settings.Fishing.stats.canceled = config.settings.Fishing.stats.canceled + 1;
         settings.save();
		end
	end
	
	-- Logout
	if (e.id == 0x0E7) then
		if (config.Status ~= nil) then config.Status = nil; end
	end

    return false;
end);

----------------------------------------------------------------------------------------------------
-- func: d3d_present
-- desc: Event called when the Direct3D device is presenting a scene.
----------------------------------------------------------------------------------------------------
ashita.events.register('d3d_present', 'present_cb', function ()
   local player = GetPlayerEntity();
	if (player == nil) then
		return;
	end
   
   local ok, err = pcall(function()
      if (config.fishTracker.show) then
         ShowFishingTracker();
      end
   end)
   
   if not ok then
      echo(addon.name, 'Error during render: ' .. tostring(err));
      AshitaCore:GetChatManager():QueueCommand(-1, string.format('/addon unload %s', addon.name));
   end
end);