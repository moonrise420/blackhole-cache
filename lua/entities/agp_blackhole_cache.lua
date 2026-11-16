-- Black Hole Cache (needs PowerGrid): a contained singularity that supplies every resource (like the Black Hole),
-- but pulls nothing in and destroys nothing. Admins only by default (agp_blackhole_cache_everyone 1 = everyone).
ENT.Type = "anim"
ENT.Base = "agp_power_base"
ENT.AGPNameKey = "agp_ent_blackhole_cache"
ENT.PrintName = BlackHoleCache and BlackHoleCache.Name() or "Black Hole Energy"
ENT.Author = "moonrise420"
ENT.Category = "PowerGrid"
ENT.Spawnable = true
ENT.AGPKind = "cache"
ENT.AGPModel = "models/agp_power/agp_blackhole_cache.mdl"
ENT.AGPCapacity = 500000
ENT.AGPAdminOnly = true   -- SpawnFunction checks it (agp_blackhole_cache_everyone 1 = everyone)
ENT.AGPScreen = { up = 6, scale = 0.12, w = 440, lines = 14 }
list.Set("CAP.Entity", ENT.PrintName, ENT)
if SERVER then AddCSLuaFile() end

-- AGP 2026-11-08: only the spawn menu held non-admins back (SpawnFunction checks AGPAdminOnly); the duplicator only knows
-- ENT.AdminOnly, so anyone could paste a dupe with the cache in it (endless resources). Pasting (GMod duplicator,
-- saves, AdvDupe2 - they all create it through this class function) follows the same rule as spawning now: admins,
-- single player, or everyone when agp_blackhole_cache_everyone is 1
if SERVER then
    local CLASS = "agp_blackhole_cache"
    local function allowed(ply)
        if not IsValid(ply) or game.SinglePlayer() or (ply.IsAdmin and ply:IsAdmin()) then return true end
        local cv = GetConVar("agp_blackhole_cache_everyone")
        return cv ~= nil and cv:GetBool()
    end
    BlackHoleCache = BlackHoleCache or {}
    BlackHoleCache.MayHave = allowed
    duplicator.RegisterEntityClass(CLASS, function(ply, data)
        if not allowed(ply) then
            if PowerGrid and PowerGrid.Say and isentity(ply) and ply:IsPlayer() then PowerGrid.Say(ply, "agp_msg_admin_only", "Only admins can spawn this.") end
            return nil
        end
        return duplicator.GenericDuplicatorFunction(ply, data)
    end, "Data")
end

if CLIENT then
    local mat = Material("models/effects/portalrift_sheet")
    local glow = Material("sprites/light_glow02_add")
    function ENT:Draw()
        self.BaseClass.Draw(self)
        -- the little black hole inside the globe
        local c = self:LocalToWorld(Vector(0, 0, 13.5))  -- the black sphere inside the rings
        local t = CurTime()
        render.SetMaterial(glow)
        render.DrawSprite(c, 34 + math.sin(t * 3) * 3, 34 + math.sin(t * 3) * 3, Color(120, 60, 255, 160))
        render.SetMaterial(mat)
        render.DrawSprite(c, 14, 14, Color(0, 0, 0, 255))
    end
end
