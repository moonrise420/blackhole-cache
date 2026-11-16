-- Black Hole Cache: a contained singularity that holds every resource and never runs dry. Needs PowerGrid
-- (its network) - or Spacebuild, which PowerGrid uses when it is installed.
BlackHoleCache = BlackHoleCache or {}
BlackHoleCache.Version = "1.0.0"
BlackHoleCache.Links = {
	GitHub = "https://github.com/moonrise420/blackhole-cache",
	Workshop = "https://steamcommunity.com/sharedfiles/filedetails/?id=3840678750",
}

-- the name in the player's language
local NAMES = {
	en = "Black Hole Energy", de = "Schwarzes-Loch-Energie", fr = "Énergie de trou noir", ["es-es"] = "Energía de agujero negro",
	nl = "Zwarte-gat-energie", ru = "Энергия чёрной дыры", cs = "Energie černé díry", et = "Musta augu energia",
	hr = "Energija crne rupe", hu = "Fekete lyuk energia", ["sv-se"] = "Svart håls-energi", tr = "Kara Delik Enerjisi",
}
function BlackHoleCache.Name()
	if SERVER then return NAMES.en end
	-- the language chosen for our addons (sg_language, as PowerGrid's texts), else GMod's own
	local sg = GetConVar("sg_language")
	local cv = (sg and sg:GetString() ~= "") and sg or GetConVar("gmod_language")
	local code = string.lower(cv and cv:GetString() or "en")
	return NAMES[code] or NAMES[code:match("^(%a+)") or ""] or NAMES[(code:match("^(%a+)") or "") .. "-" .. (code:match("^(%a+)") or "")] or NAMES.en
end

-- 2026-11-15 (gallery shoot: the panel said "Schwarzes-Loch-Energie" with the addons set to English): the name is
-- worked out when the entity file loads, before Ascension Gates makes sg_language; set it again once everything is
-- loaded and whenever the language changes (panel, spawn menu and parts tool read ENT.PrintName)
if CLIENT then
	local function rename()
		local st = scripted_ents.GetStored("agp_blackhole_cache")
		if st and st.t then st.t.PrintName = BlackHoleCache.Name() end
	end
	hook.Add("InitPostEntity", "BlackHoleCache.Name", rename)
	cvars.AddChangeCallback("sg_language", function() timer.Simple(0, rename) end, "BlackHoleCache.Name")
	cvars.AddChangeCallback("gmod_language", function() timer.Simple(0, rename) end, "BlackHoleCache.Name")
end

-- in PowerGrid's spawn tab and parts tool, with the generators (PowerGrid may load after this file)
hook.Add("Initialize", "BlackHoleCache.Spawn", function()
	if PowerGrid and PowerGrid.AddSpawn then PowerGrid.AddSpawn("agp_blackhole_cache", "generators", 190) end
end)

-- without PowerGrid it cannot work: say so once, instead of errors
hook.Add("InitPostEntity", "BlackHoleCache.Check", function()
	if PowerGrid then return end
	local msg = "[Black Hole Cache] needs the addon PowerGrid (Steam Workshop). Please subscribe to it and restart."
	MsgN(msg)
	if CLIENT then timer.Simple(8, function() chat.AddText(Color(255, 170, 60), msg) end) end
end)
