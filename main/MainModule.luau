--[[
╭─╮╷╭┬╮╭─╮╷  ╷ ╷   ╭┬╮╭─╮╶┬╮╭─╴╭─╮╭─╮╶┬╴╭─╴╶┬╮      
╰─╮││││├─╯│  ╰┬╯   ││││ │ ││├╴ ├┬╯├─┤ │ ├╴  ││      
╰─╯╵╵ ╵╵  ╰─╴ ╵    ╵ ╵╰─╯╶┴╯╰─╴╵╰╴╵ ╵ ╵ ╰─╴╶┴╯      
                     ╭┬╮╭─╮╷╭╮╷   ╭┬╮╭─╮╶┬╮╷ ╷╷  ╭─╴
                     │││├─┤││╰┤   ││││ │ │││ ││  ├╴ 
>   >      >         ╵ ╵╵ ╵╵╵ ╵╶─╴╵ ╵╰─╯╶┴╯╰─╯╰─╴╰─╴
--]]

--- SERVICES ---
local ServerScriptService = game:GetService('ServerScriptService')

--- STATICS ---
local ROBLOX_WARN = warn
local ROBLOX_PRINT = print
local CONTEXT -- This is set once in the INIT function.
local SETTINGS -- This is set once in the INIT function.
local LOADER_VERSION -- This is set once in the INIT function.
local VERSION -- This is set once in the INIT function.
local STORAGE -- This is set once in the INIT function.

--- FUNCS ---
local error -- This is set once in the INIT function.
local warn -- This is set once in the INIT function.
local print -- This is set once in the INIT function.
local log -- This is set once in the INIT function.

local function INIT(context)
    CONTEXT = context
    SETTINGS = context.Settings
    local statics = context.Statics
    log = statics.log
    print = statics.print
    warn = statics.warn
    error = statics.error
    LOADER_VERSION = statics.LOADER_VERSION
    VERSION = script:FindFirstChild('V').Value
    log('Full context: ', CONTEXT)
end

--- CODE ---

return INIT
