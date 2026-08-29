--[[
╭─╮╷╭┬╮╭─╮╷  ╷ ╷   ╭┬╮╭─╮╶┬╮╭─╴╭─╮╭─╮╶┬╴╭─╴╶┬╮      
╰─╮││││├─╯│  ╰┬╯   ││││ │ ││├╴ ├┬╯├─┤ │ ├╴  ││      
╰─╯╵╵ ╵╵  ╰─╴ ╵    ╵ ╵╰─╯╶┴╯╰─╴╵╰╴╵ ╵ ╵ ╰─╴╶┴╯      
                     ╭┬╮╭─╮╷╭╮╷   ╭┬╮╭─╮╶┬╮╷ ╷╷  ╭─╴
                     │││├─┤││╰┤   ││││ │ │││ ││  ├╴ 
>   >      >         ╵ ╵╵ ╵╵╵ ╵╶─╴╵ ╵╰─╯╶┴╯╰─╯╰─╴╰─╴
--]]

--- SERVICES ---
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService('ServerScriptService')
local Settings = require(ServerScriptService["SimplyModerated Loader"].Settings)

--- STATICS ---
local ROBLOX_WARN = warn
local ROBLOX_PRINT = print
local CONTEXT -- This is set once in the INIT function.
local SETTINGS -- This is set once in the INIT function.
local SETTINGS_PROTOCOL -- This is set once in the INIT function.
local LOADER_VERSION -- This is set once in the INIT function.
local LOADER_PROTOCOL -- This is set once in the INIT function.
local VERSION -- This is set once in the INIT function.
local STORAGE -- This is set once in the INIT function. SET IT
local SHARED = script:FindFirstChild('shared')
local SERVER = script:FindFirstChild('server')
local CLIENT = script:FindFirstChild('client')

--- FUNCS ---
local error -- This is set once in the INIT function.
local warn -- This is set once in the INIT function.
local print -- This is set once in the INIT function.
local log -- This is set once in the INIT function.

local SAFE = function(func, onFail, onFailMessage)
    local toReturn1
    local toReturn2
    local success, result = pcall(function(...)
        local success, result = pcall(func)
        if not success then
            result = '[ SAFE function: ' .. result .. ' ]'
            onFailMessage = '>'
            if not onFail then
                warn(onFailMessage, result)
            else
                if onFail == 'error' then
                    error(onFailMessage, result)
                elseif onFail == 'warn' then
                    warn(onFailMessage, result)
                elseif onFail == 'print' then
                    print(onFailMessage, result)
                elseif onFail == 'log' then
                    log(result)
                end
            end
            toReturn1, toReturn2 = false, result
        else
            toReturn1, toReturn2 = true, result
        end
    end)
    if not success then
        error('Could not run the SAFE function!', result)
    end
    return toReturn1, toReturn2
end
local function getRealKey(key)
    local realKey = {}
    for position, codepoint in utf8.codes(key) do
	    table.insert(realKey, codepoint * position - position)
    end
    return realKey
end
local function utf8FromInput(input)
    local result = {}
    for position, codepoint in utf8.codes(input) do
        table.insert(result, codepoint)
    end
    return result
end
local function getKeyPos(pos, realKeyValues)
    local keyPos = pos
    if pos > realKeyValues then
        keyPos = keyPos / realKeyValues
        keyPos = keyPos - math.floor(keyPos)
        keyPos = keyPos * realKeyValues + 1
        keyPos = math.round(keyPos)
    end
    return keyPos
end
local function ENCODEAsync(key, toEncode)
    local realKey = getRealKey(key)
    local realToEncode = utf8FromInput(toEncode)

    local realKeyValues = #realKey
    local preResult = {}
    local result = ''
    local dataSegment = 1
    for pos, encode in realToEncode do
        local keyPos = getKeyPos(pos, realKeyValues)
        table.insert(preResult, tostring(encode + realKey[keyPos]))
        if tonumber(string.len(tostring(encode + realKey[keyPos]))) > dataSegment then
            dataSegment = tonumber(string.len(tostring(encode + realKey[keyPos])))
        end
        if pos / 60 == math.floor(60) then
            task.wait()
        end
    end
    for pos, i in preResult do
        if string.len(i) < dataSegment then
            result = result .. string.rep('0', dataSegment - string.len(i)) .. i
        else
            result = result .. i
        end
        if pos / 60 == math.floor(pos / 60) then
            task.wait()
        end
    end
    result = tostring(dataSegment .. ',' .. result)
    return result
end

local function DECODEAsync(key, toDecode)
    local realKey = getRealKey(key)

    local realKeyValues = #realKey
    local preRresult = {}
    local result = ''
    local dataSegment = string.gsub(string.split(toDecode, ',')[1], ',', '', 1)
    dataSegment = tonumber(dataSegment)
    toDecode = string.split(toDecode, ',')[2]
    local pos = 1
    while #preRresult * dataSegment < string.len(toDecode) do
        table.insert(preRresult, tonumber(string.sub(toDecode, pos, pos + dataSegment - 1)))
        pos += dataSegment
        if pos / 60 == math.floor(pos / 60) then
            task.wait()
        end
    end
    for pos, codepoint in preRresult do
        local keyPos = getKeyPos(pos, realKeyValues)
        result = result .. utf8.char(codepoint - realKey[keyPos])
        if pos / 60 == math.floor(pos / 60) then
            task.wait()
        end
    end
    return result
end

local function init(context)
    CONTEXT = context
    SETTINGS = context.Settings
    SETTINGS_PROTOCOL = context.Settings.SETTINGS_PROTOCOL
    local statics = context.Statics
    log = statics.log
    print = statics.print
    warn = statics.warn
    error = statics.error
    LOADER_VERSION = statics.LOADER_VERSION
    LOADER_PROTOCOL = statics.LOADER_PROTOCOL
    VERSION = script:FindFirstChild('V').Value
    log('Full context from loader: ', CONTEXT)

    script.Parent = ServerScriptService
    SHARED.Name = 'SimplyModerated Shared'
    SERVER.Name = 'SimplyModerated Server'
    CLIENT.Name = 'SimplyModerated Client'
    SHARED.Parent = ReplicatedStorage
    SERVER.Parent = ServerScriptService
    CLIENT.Parent = script
    log('Parenting complete.')

    CONTEXT.Statics.HTTP = HttpService.HttpEnabled
    CONTEXT.Statics.USE_DATA_STORE = true
    if not Settings.DataStoreName then
        warn('Set Settings.DataStoreName! Not using DataStore for this session ..')
        CONTEXT.Statics.USE_DATA_STORE = false
    end
    if not Settings.DataStoreKey then
        warn('Set Settings.DataStoreKey! Not using DataStore for this session ..')
        CONTEXT.Statics.USE_DATA_STORE = false
    end
    if string.len(Settings.DataStoreKey) <= 10 then
        warn('Set Settings.DataStoreKey to something longer! Spam your keyboard. Not using DataStore for this session ..')
        CONTEXT.Statics.USE_DATA_STORE = false
    end
    if CONTEXT.Statics.USE_DATA_STORE then
        CONTEXT.Statics.DATA_STORE = DataStoreService:GetDataStore(Settings.DataStoreName)
    else
        CONTEXT.Statics.DATA_STORE = nil
    end
    if statics.DEBUG and CONTEXT.Statics.USE_DATA_STORE then
        task.spawn(function()
            log('Awaiting encode / decode test ...')
            local toEncode = 'q4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZq4rftgaw367ez89r0ouivpb 976aq34wertugfivawehr4btf87rlaiuzebhw4itrogurtsrhzjoigbxdnfh kdrtg irzusrervgb(/T§daoiufrbzhuoi&Z"RG(RIFUYSDBNGV ZZFZZZ DBUX)ORIUTZHDBGRFHXJC KLGVZ BFDGN IKRUZRERSHBOISR%TGBHUZ'
            local tests = 0
            local testResults = {}
            task.wait(10)
            while tests < 5 do
                local start = os.clock()
                local encoded = ENCODEAsync(Settings.DataStoreKey, toEncode)
                local encode = os.clock()
                DECODEAsync(Settings.DataStoreKey, encoded)
                local finish = os.clock()
                local encodeTime = encode - start
                local decodeTime = finish - encode
                table.insert(testResults, {encodeTime, decodeTime})
                tests += 1
                task.wait()
            end
            local maxEncodeTime = 0
            local minEncodeTime = 100
            local maxDecodeTime = 0
            local minDecodeTime = 100
            for _, i in testResults do
                if i[1] > maxEncodeTime then
                    maxEncodeTime = i[1]
                end
                if i[1] < minEncodeTime then
                    minEncodeTime = i[1]
                end
                if i[2] > maxDecodeTime then
                    maxDecodeTime = i[2]
                end
                if i[2] < minDecodeTime then
                    minDecodeTime = i[2]
                end
            end
            log('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
            log('ENCODE / DECODE PERFORMANCE STATS')
            log('string.len(toEncode)', string.len(toEncode))
            log('tests', tests)
            log('maxEncodeTime', maxEncodeTime)
            log('minEncodeTime', minEncodeTime)
            log('maxDecodeTime', maxDecodeTime)
            log('minDecodeTime', minDecodeTime)
            log('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
        end)
    end
end

--- CODE ---

return init
