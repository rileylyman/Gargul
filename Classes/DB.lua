---@type GL
local _, GL = ...;

---@class DB
GL.DB = {
    _initialized = false,
    AwardHistory = {},
    Cache = {},
    LootPriority = {},
    PlusOnes = {},
    Settings = {},
    SoftRes = {},
    TMB = {},
};

local DB = GL.DB;

function DB:_init()
    GL:debug("DB:_init");

    -- No need to initialize this class twice
    if (self._initialized) then
        return;
    end

    if (not GargulDB or not type(GargulDB) == "table") then
        GargulDB = {};
    end

    -- Prepare our database tables
    GargulDB.AwardHistory = GargulDB.AwardHistory or {};
    GargulDB.LootPriority = GargulDB.LootPriority or {};
    GargulDB.PlusOnes = GargulDB.PlusOnes or {};
    GargulDB.Settings = GargulDB.Settings or {};
    GargulDB.SoftRes = GargulDB.SoftRes or {};
    GargulDB.TMB = GargulDB.TMB or {};

    -- Provide a shortcut for each table
    self.AwardHistory = GargulDB.AwardHistory;
    self.LootPriority = GargulDB.LootPriority;
    self.PlusOnes = GargulDB.PlusOnes;
    self.Settings = GargulDB.Settings;
    self.SoftRes = GargulDB.SoftRes;
    self.TMB = GargulDB.TMB;

    -- Fire DB:store before every logout/reload/exit
    GL.Events:register("DBPlayerLogoutListener", "PLAYER_LOGOUT", self.store);

    self._initialized = true;
end

--- Make sure the database persists between sessions
--- This is just a safety precaution and should strictly
--- speaking not be necessary, but hey you never know!
function DB:store()
    GL:debug("DB:store");

    GargulDB.AwardHistory = GL.DB.AwardHistory;
    GargulDB.LootPriority = GL.DB.LootPriority;
    GargulDB.PlusOnes = GL.DB.PlusOnes;
    GargulDB.Settings = GL.Settings.Active;
    GargulDB.SoftRes = GL.DB.SoftRes;
    GargulDB.TMB = GL.DB.TMB;
end

-- Get a value from the database, or return a default if it doesn't exist
function DB:get(keyString, default)
    return GL:tableGet(DB, keyString, default);
end

-- Set a database value by a given key and value
function DB:set(keyString, value)
    return GL:tableSet(DB, keyString, value);
end

-- Reset the tables
function DB:reset()
    GL:debug("DB:reset");

    self.AwardHistory = {};
    self.LootPriority = {};
    self.PlusOnes = {};
    self.Settings = {};
    self.SoftRes = {};
    self.TMB = {};

    GL:success("Tables reset");
end

GL:debug("DB.lua");