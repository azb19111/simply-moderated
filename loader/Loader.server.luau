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
local LOCAL_VERSION = if ServerScriptService:FindFirstChild('SimplyModerated MainModule') then if ServerScriptService:FindFirstChild('SimplyModerated MainModule'):FindFirstChild('V') then ServerScriptService:FindFirstChild('SimplyModerated MainModule'):FindFirstChild('V').Value else nil else nil
local DEBUG = if ENV == 'Studio' and if LOCAL_VERSION then string.find(LOCAL_VERSION, 'dev') or string.find(LOCAL_VERSION, 'pre') else false then true else false
local LOAD_LOCAL = if DEBUG or LOCAL_VERSION and not string.find(LOCAL_VERSION, 'dev') and string.find(LOCAL_VERSION, 'pre') then true else false
local ROBLOX_WARN = warn
local ROBLOX_PRINT = print
local VERSION_USED = '' -- This is set once in the loading process.

--- FUNCS ---
local error = function(...)
    ROBLOX_WARN('::: SIMPLY MODERATED ::: ::  ERROR  :: : '..if RunService:IsServer() then VERSION_USED..' :' else 'CLIENT :', ...)
end
local warn = function(...)
    ROBLOX_WARN('::: SIMPLY MODERATED ::: :: WARNING :: : '..if RunService:IsServer() then VERSION_USED..' :' else 'CLIENT :', ...)
end
local print = function(...)
    ROBLOX_PRINT('::: SIMPLY MODERATED ::: ::  PRINT  :: : '..if RunService:IsServer() then VERSION_USED..' :' else 'CLIENT :', ...)
end
local log = function(...)
    if not DEBUG then
        return
    end
    ROBLOX_PRINT('::: SIMPLY MODERATED ::: ::  DEBUG  :: : '..if RunService:IsServer() then VERSION_USED..' :' else 'CLIENT :', ...)
end

local CONTEXT = {Settings = require(script.Parent:FindFirstChild('Settings')), Statics = {LOADER_VERSION = LOADER_VERSION, DEBUG = DEBUG, error = error, warn = warn, print = print, log = log}}

--- CODE ---
if LOAD_LOCAL then
    VERSION_USED = 'v'..LOADER_VERSION
    warn('Attention! This admin is not ready for production! Expect frequent crashes, bugs and updates you have to install manually.')
    require(ServerScriptService:FindFirstChild('SimplyModerated MainModule'):FindFirstChild('MainModule'))(CONTEXT)
else
    VERSION_USED = 'v? pre?dev?'
    warn('Attention! This admin is not ready for production! Expect frequent crashes, bugs and updates you have to install manually.')
    local success, result = pcall(function(...)
        require(110934653842466)(CONTEXT)
    end)
    if not success then
        error('Could not load MainModule!', result)
    end
end
