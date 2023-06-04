rednet.open("top")

while true do
    sender, message, prot = rednet.receive("server")
    if message == "scan" then rednet.send(sender,"scan","serverFind")
    elseif message == "appStoreLoad" then
        files = fs.list("appStore/")
        for i = 1,table.getn(files) do
            settings.load("appStore/"..files[i])
            rednet.send(sender,settings.get("name"),"appStore")
            rednet.send(sender,settings.get("id"),"appStore")
            rednet.send(sender,settings.get("desc"),"appStore")
        end
    else
        files = fs.list("apps/")
        for i = 1,table.getn(files) do
            settings.load("apps/"..files[i])
            if settings.get("id") == message then file = files[i] end
        end
        if type(file) == "table" then
            for i = 1,table.getn(file) do print(file[i]) end
        elseif file ~= nil then
            settings.load("apps/"..file)
            rednet.send(sender,settings.get("version"),"update")
            files = settings.get("files")
            for i = 1,table.getn(files) do
                rednet.send(sender,files[i][2],"updateP")
                file = fs.open(files[i][1],"r")
                rednet.send(sender, file.readAll(), "updateD")
                file.close()
            end 
            rednet.send(sender,"complete123","update")
        end
    end
end