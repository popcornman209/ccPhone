--args = { ... }
--if args ~= {} then
--    fileId = args[1]
--    currentVersion = args[2]
--    log = args[3]
--    restart = args[4]
--end

function prnt(str) if log then print(str) end end

prnt("id: "..fileId)
prnt("current version: "..currentVersion)

rednet.open("back")
prnt("oppened rednet...")
rednet.broadcast("scan","server")
prnt("finding server...")
server,message,prot = rednet.receive("serverFind",1)

if message == nil then prnt("couldnt connect.")
else
    prnt("found.")
    rednet.send(server, fileId, "server")
    prnt("getting newest version...")
    sender, version, prot = rednet.receive("update",1)
    if version ~= nil then 
        prnt("newest version: "..version)
        if version ~= currentVersion then
            paths = {}
            data = {}
            receiving = true
            while receiving do
                sender, message, prot = rednet.receive("updateP",1)
                if message == "complete123" or message == nil then receiving = false
                else
                    prnt("received "..message)
                    table.insert(paths,message)
                    sender, message, prot = rednet.receive("updateD",1)
                    if data ~= nil then table.insert(data,message) end
                end
            end
            prnt("installing...")

            for i = 1,table.getn(paths) do
                file = fs.open(paths[i],"w")
                file.write(data[i])
                file.close()
                prnt("installed "..paths[i])
            end
            prnt("completed.")
            if restart then os.reboot() end
        else prnt("up to date.") end
    else prnt("failed.")
    end
end