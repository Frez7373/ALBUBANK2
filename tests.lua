-- ALBU BANK API smoke test
-- Run on a CC:Tweaked computer with a modem connected to the same network as the server.

local bank = dofile("/lib/bank_client.lua")

local function check(name, ok, err)
    if ok then
        print("PASS: " .. name)
    else
        print("FAIL: " .. name .. " -> " .. tostring(err))
    end
    return ok
end

local ok, data, err = bank.request("ping", {}, 5)
check("server ping", ok, err)
if ok then print("Server: " .. tostring(data.server)) end

print("")
print("Smoke test complete.")
