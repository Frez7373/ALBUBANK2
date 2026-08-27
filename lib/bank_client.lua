-- ALBU BANK CLIENT
-- CC:Tweaked / Minecraft 1.16.5

local modem = peripheral.find("modem")
if not modem then error("ERROR: Modem not found") end

local PORT = 4200
local TIMEOUT = 8

modem.open(PORT)

local function makeId()
    return string.format("REQ-%d-%d-%d", os.epoch("utc"), os.getComputerID(), math.random(1000, 9999))
end

local function request(action, data, timeout)
    timeout = tonumber(timeout) or TIMEOUT
    local requestId = makeId()

    modem.transmit(PORT, PORT, {
        type = "request",
        request_id = requestId,
        action = action,
        data = data or {}
    })

    local timer = os.startTimer(timeout)

    while true do
        local event, side, channel, replyChannel, msg = os.pullEvent()

        if event == "modem_message" then
            if channel == PORT and type(msg) == "table" and msg.type == "response" and msg.request_id == requestId then
                if msg.ok then
                    return true, msg.data, nil
                end
                return false, nil, msg.error or "UNKNOWN_ERROR"
            end
        elseif event == "timer" and side == timer then
            return false, nil, "TIMEOUT"
        end
    end
end

local function printHeader(title)
    term.clear()
    term.setCursorPos(1, 1)
    print("========================================")
    print("              ALBU BANK")
    print("========================================")
    print("")
    if title then print(title) end
    print("")
end

local function pause()
    print("")
    print("Press any key to continue...")
    os.pullEvent("key")
end

local function promptPin()
    write("PIN: ")
    return read("*")
end

local function waitForCard(message)
    local drive = peripheral.find("drive")
    if not drive then return nil, "DISK_DRIVE_NOT_FOUND" end

    while true do
        printHeader("CARD")
        print(message or "Insert your ALBU bank card.")
        print("")
        print("Waiting for card...")

        if drive.isDiskPresent() then
            local mount = drive.getMountPath()
            if mount then
                local path = mount .. "/albu_card.dat"
                if fs.exists(path) then
                    local h = fs.open(path, "r")
                    local raw = h and h.readAll() or nil
                    if h then h.close() end

                    if raw then
                        local ok, card = pcall(textutils.unserialize, raw)
                        if ok and type(card) == "table" and card.card_id and card.account_id then
                            return card, nil
                        end
                    end
                end
            end
        end

        local event, key = os.pullEvent()
        if event == "key" and key == keys.q then
            return nil, "CANCELLED"
        end
    end
end

local function ejectCard()
    local drive = peripheral.find("drive")
    if drive and drive.isDiskPresent() then
        drive.ejectDisk()
    end
end

math.randomseed((os.epoch("utc") + os.getComputerID()) % 2147483647)

return {
    request = request,
    printHeader = printHeader,
    pause = pause,
    promptPin = promptPin,
    waitForCard = waitForCard,
    ejectCard = ejectCard
}
