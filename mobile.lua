require "android"
require "socket"

--[[
function printTableElements(Table)
    print("/*\t\t*/")
    for i,g in pairs(Table) do
        print(i,g);
    end;
    print("/*\t\t*/")
end;
--]]

function createRandomSensors()
    local math = require "math"
    local sensorsTable = {}
    sensorsTable["Sensor 1"] = math.random()
    sensorsTable["Sensor 2"] = math.random()
    sensorsTable["Sensor 3"] = math.random()
    sensorsTable["Sensor 4"] = math.random()
    sensorsTable["Sensor 5"] = math.random()
    sensorsTable["Sensor 6"] = math.random()
    return sensorsTable
end;

function sendSensorsData(Sockets, Sensors)
    for Index,Socket in pairs(Sockets) do
        if not Socket:send(Sensors) then
            Socket:close()
            Sockets[Index] = nil;
        end
    end;
end;

function makeSensorsString(Sensors)
    local eol = "\n"
    -- local eol = "\n\r"
    local string = "/*\t/\\ /\\ /\\ /\\ \t*/" .. eol
    for i,g in pairs(Sensors) do
        string = string .. i .. "\t" .. g .. eol
    end;
    string = string .. "/*\t-- -- -- --\t*/" .. eol
    return string
end;

function createServerSocket(Port)
    local server = assert(socket.bind("*", Port))
    local ip, port = server:getsockname()
    print("server address - " .. ip .. ":" .. port)
    -- set 100 msec timeout on incoming connection wait
    server:settimeout(0.1)
    return server
end;

function prepareClientSocket(Socket)
    -- disable Nagle's algorithm
    Socket:setoption("tcp-nodelay", true)
    -- keep alive to detect broken connections
    Socket:setoption("keepalive", true)
    -- set 10 sec timeout on send data
    Socket:settimeout(10)
end;

function createSensorsServer()
    local server   = createServerSocket(6060)
    android.startSensing()
    -- wait for some electric sheep here
    android.sleep(1)

    local clientTable = {}
    while 1 do
        local client = server:accept()
        if client then
            local ip, port = client:getpeername()
            print("client address - " .. ip .. ":" .. port)
            prepareClientSocket(client)
            clientTable[client] = client
        end

        local sensors = android.readSensors()
        sendSensorsData(clientTable, makeSensorsString(sensors.result))
        -- local sensors = createRandomSensors()
        -- sendSensorsData(clientTable, makeSensorsString(sensors))
    end;

    android.stopSensing()
    -- wait for some electric sheep here
    android.sleep(1)
    android.exit();
end;

-- printTableElements(_G)
createSensorsServer()
