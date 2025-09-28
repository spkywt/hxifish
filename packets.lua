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
-- func: sendFakeFishingSkillup
-- desc: Locally fakes fishing skill up of 0.1
-- auth: atom0s
----------------------------------------------------------------------------------------------------
function sendFakeFishingSkillup()
    local sid = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0);
    local tid = AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0);
    local packet = struct.pack('bbbbIIIIhhI', 
        0x29, 0x0E, 0x00, 0x00, 
        sid, sid, 
        0x30,
        0x01, 
        tid, tid, 
        0x26
    );
    AshitaCore:GetPacketManager():AddIncomingPacket(0x29, packet:totable());
end
