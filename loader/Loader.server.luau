--[[
╭─╮╷╭┬╮╭─╮╷  ╷ ╷   ╭┬╮╭─╮╶┬╮╭─╴╭─╮╭─╮╶┬╴╭─╴╶┬╮
╰─╮││││├─╯│  ╰┬╯   ││││ │ ││├╴ ├┬╯├─┤ │ ├╴  ││
╰─╯╵╵ ╵╵  ╰─╴ ╵    ╵ ╵╰─╯╶┴╯╰─╴╵╰╴╵ ╵ ╵ ╰─╴╶┴╯
                     ╷  ╭─╮╭─╮╶┬╮╭─╴╭─╮       
                     │  │ │├─┤ ││├╴ ├┬╯       
>   >      >         ╰─╴╰─╯╵ ╵╶┴╯╰─╴╵╰╴       

Do not modify something if you don't know what you are doing!
Settings are located in ServerScriptService --> SimplyModerated Loader --> Settings
--]]

--- SERVICES ---
local RunService = game:GetService('RunService')
local ServerScriptService = game:GetService('ServerScriptService')

--- STATICS ---
local ENV = if RunService:IsStudio() then 'Studio' else 'Production'
local LOADER_VERSION = '0.0.1dev'
local LOCAL_VERSION = if ServerScriptService:FindFirstChild('MainModule') then if ServerScriptService:FindFirstChild('MainModule'):FindFirstChild('V') then ServerScriptService:FindFirstChild('MainModule'):FindFirstChild('V').Value else nil else nil
local DEBUG = if ENV == 'Studio' and if LOCAL_VERSION then string.find(LOCAL_VERSION, 'dev') or string.find(LOCAL_VERSION, 'pre') else false then true else false
local LOAD_LOCAL = if LOCAL_VERSION and not string.find(LOCAL_VERSION, 'dev') or LOCAL_VERSION and DEBUG then true else false
local ROBLOX_WARN = warn
local ROBLOX_PRINT = print
local _VERSION_USED = '' -- This is set once in the loading process.
local MAIN_MODULE_ID = 110934653842466
local MAIN_MODULE_PRE_ID = 123843391437105

--- FUNCS ---
local error = function(...)
    local output = function(...)
        ROBLOX_WARN('::: SIMPLY MODERATED ::: ::  ERROR  :: : '..if RunService:IsServer() then ServerScriptService:FindFirstChild('MainModule'):FindFirstChild('V').Value..' :' else 'CLIENT :', ...)
    end
    local success, result = pcall(output, ...)
    if not success then
        ROBLOX_WARN('::: SIMPLY MODERATED ::: ::  ERROR  :: : unknown : Could not create an error!', result, ...)
    end
    
end
local warn = function(...)
    local output = function(...)
        ROBLOX_WARN('::: SIMPLY MODERATED ::: :: WARNING :: : '..if RunService:IsServer() then ServerScriptService:FindFirstChild('MainModule'):FindFirstChild('V').Value..' :' else 'CLIENT :', ...)
    end
    local success, result = pcall(output, ...)
    if not success then
        ROBLOX_WARN('::: SIMPLY MODERATED ::: :: WARNING :: : unknown : Could not create a warning!', result, ...)
    end
end
local print = function(...)
    local output = function(...)
        ROBLOX_PRINT('::: SIMPLY MODERATED ::: ::  PRINT  :: : '..if RunService:IsServer() then ServerScriptService:FindFirstChild('MainModule'):FindFirstChild('V').Value..' :' else 'CLIENT :', ...)
    end
    local success, result = pcall(output, ...)
    if not success then
        ROBLOX_WARN('::: SIMPLY MODERATED ::: :: WARNING :: : unknown : Could not create a print!', result, ...)
    end
end
local log = function(...)
    if not DEBUG then
        return
    end
    local output = function(...)
        ROBLOX_PRINT('::: SIMPLY MODERATED ::: ::  DEBUG  :: : '..if RunService:IsServer() then ServerScriptService:FindFirstChild('MainModule'):FindFirstChild('V').Value..' :' else 'CLIENT :', ...)
    end
    local success, result = pcall(output, ...)
    if not success then
        ROBLOX_WARN('::: SIMPLY MODERATED ::: :: WARNING :: : unknown : Could not create a log!', result, ...)
    end
end

local CONTEXT = {Settings = require(script.Parent:FindFirstChild('Settings')), Statics = {LOADER_VERSION = LOADER_VERSION, DEBUG = DEBUG, error = error, warn = warn, print = print, log = log}}

--- CODE ---
if LOAD_LOCAL then
    VERSION_USED = 'v'..LOADER_VERSION
    log('Loading local module ...')
    warn('Attention! This admin is not ready for production! Expect frequent crashes, bugs and updates you have to install manually.')
    require(ServerScriptService:FindFirstChild('MainModule'))(CONTEXT)
else
    VERSION_USED = 'v? pre?dev?'
    warn('Attention! This admin is not ready for production! Expect frequent crashes, bugs and updates you have to install manually.')
    local success, result = pcall(function(...)
        if require(script.Parent:FindFirstChild('Settings')).LoadPreRelease then
            log('Loading PreRelease module ...')
            require(MAIN_MODULE_PRE_ID)(CONTEXT)
        else
            log('Loading module ...')
            require(MAIN_MODULE_ID)(CONTEXT)
        end
    end)
    if not success then
        error('Could not load MainModule!', result)
    end
end
