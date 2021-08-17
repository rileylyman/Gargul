--[[
    This class handles the addon's default and user settings

    The default settings are overwritten with the user's settings
    after the addon is loaded

    The showSettingsMenu function is responsible for showing the
    settings in the WoW settings menu
]]

---@type GL
local _, GL = ...;

---@class Settings
GL.Settings = {
    _initialized = false,
    Defaults = GL.Data.DefaultSettings,
    Active = {}, -- This object holds the actual setting values applicable to this runtime
};

local Settings = GL.Settings; ---@type Settings

function Settings:_init()
    GL:debug("Settings:_init");

    -- No need to initialize this class twice
    if (self._initialized) then
        return;
    end

    -- Combine defaults and user settings
    self:overrideDefaultsWithUserSettings();

    -- Prepare the options / config frame
    local Frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer);
    Frame.name = "Gargul";
    Frame:SetScript("OnShow", function ()
        self:showSettingsMenu(Frame);
    end);
    InterfaceOptions_AddCategory(Frame);

    self._initialized = true;
end

function Settings:draw(section)
    GL.Interface.Settings.Overview:draw(section);
end

function Settings:close()
    GL.Interface.Settings.Overview:close();
end

-- Reset the addon to its default settings
function Settings:resetToDefault()
    GL:debug("Settings:resetToDefault");

    self.Active = {};
    GL.DB.Settings = {};

    -- Combine defaults and user settings
    self:overrideDefaultsWithUserSettings();
end

-- Override the addon's default settings with the user's custom settings
function Settings:overrideDefaultsWithUserSettings()
    GL:debug("Settings:overrideDefaultsWithUserSettings");

    -- Reset the currently active settings table
    self.Active = {};

    -- Combine the default and user's settings to one settings table
    Settings = GL:tableMerge(Settings.Defaults, GL.DB.Settings);

    -- Set the values of the settings table directly on the GL.Settings table.
    for key, value in pairs(Settings) do
        self.Active[key] = value;
    end

    GL.DB.Settings = self.Active;
end

-- We use this method to make sure that the interface is only built
-- when the user has actually accessed the settings menu, which doesn't happen every session
function Settings:showSettingsMenu(Frame)
    GL:debug("Settings:showSettingsMenu");

    -- Add the addon title to the top of the settings frame
    local Title = Frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    Title:SetPoint("TOPLEFT", 16, -16);
    Title:SetText("Gargul");

    -- This is the "PackMule" button that opens the PackMule settings
    local SettingsButton = CreateFrame("Button", nil, Frame, "UIPanelButtonTemplate");
    SettingsButton:SetText("Settings");
    SettingsButton:SetWidth(177);
    SettingsButton:SetHeight(24);
    SettingsButton:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", 0, -8);
    SettingsButton:SetScript("OnClick", function()
        self:draw();

        -- Make sure the vanilla interface options are closed and don't reopen automatically
        HideUIPanel(InterfaceOptionsFrame);
        HideUIPanel(GameMenuFrame);
    end);
end

-- Get a setting by a given key. Use dot notation to traverse multiple levels e.g:
-- Settings.UI.Auctioneer.offsetX can be fetched using Settings:get("Settings.UI.Auctioneer.offsetX")
-- without having to worry about tables or keys existing yes or no.
function Settings:get(keyString, default)
    -- Just in case something went wrong with merging the default settings
    if (type(default) == "nil") then
        default = GL:tableGet(GL.Data.DefaultSettings, keyString);
    end

    return GL:tableGet(self.Active, keyString, default);
end

-- Set a setting by a given key and value. Use dot notation to traverse multiple levels e.g:
-- Settings.UI.Auctioneer.offsetX can be set using Settings:set("Settings.UI.Auctioneer.offsetX", myValue)
-- without having to worry about tables or keys existing yes or no.
function Settings:set(keyString, value)
    return GL:tableSet(self.Active, keyString, value);
end

GL:debug("Settings.lua");