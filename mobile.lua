require "android"
require "socket"
require "coroutine"

function printTableElements(Table)
    print("/*\t\t*/")
    for i,g in pairs(Table) do
        print(i,g);
    end;
    print("/*\t\t*/")
end;

function sendSensorsData(Socket, Sensors)
    Socket:send("/*\t/\\ /\\ /\\ /\\ \t*/\n")
    for i,g in pairs(Sensors) do
        Socket:send(i .. "\t" ..  g .. "\n");
    end;
    Socket:send("/*\t-- -- -- --\t*/\n")
end;

function createSensorsServer()
    local server   = assert(socket.bind("*", 6060))
    local ip, port = server:getsockname()
    print("server address - " .. ip .. ":" .. port)
    android.startSensing()
    android.sleep(1)
    local client = server:accept()
    client:setoption("tcp-nodelay", true)
    while 1 do
        local sensors = android.readSensors()
        sendSensorsData(client, sensors.result)
        -- printTableElements(sensors.result)
        android.sleep(1)
    end;
    android.stopSensing()
    android.exit();
end;

-- printTableElements(_G)
createSensorsServer()
