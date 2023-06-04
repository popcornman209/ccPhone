function write(thing, y)
    len = string.len(thing)
    if len <= 26 then
        term.setCursorPos(14-string.len(thing)/2, y)
        term.write(thing)
    else
        current = thing
        for i = 0,math.ceil(len/26)-1 do
            temp = string.sub(current,i*26+1, math.min(26,string.len(current))+i*26)
            term.setCursorPos(14-string.len(temp)/2, y+i)
            term.write(temp)
        end
    end
end
function getSetting(name, defVal)
    out = settings.get(name)
    if out == nil then
        out = defVal
        settings.set(name,defVal)
    end
    return out
end
function recvID(id, prot, timeOut)
    time = timeOut
    finding = true
    while finding do
        oldTime = os.clock()
        id2, message, prot2 = rednet.receive(prot, time)
        time = time-(os.clock()-oldTime)
        if time<0 then time = 0 end
        if id2 == id then return id2,message,prot2 end
        if id2 == nil then return nil,nil,nil end
    end
end

rednet.open("back")
quit = false
while quit == false do
    if settings.load("data/billies") == false then
        settings.clear()
        settings.set("prot","global")
        settings.save("data/billies")
    end


    settings.clear()
    settings.load("data/main")
    bgColor = getSetting("bgColor",colors.cyan)
    txtColor = getSetting("txtColor",colors.white)
    buttonColor = getSetting("buttonColor",colors.blue)
    devMode = getSetting("devMode",false)

    term.setBackgroundColor(bgColor)
    term.setTextColor(txtColor)
    term.clear()
    term.setBackgroundColor(colors.red)
    if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
    term.setCursorPos(1,1)
    term.write("X")
    term.setBackgroundColor(bgColor)
    write("loading...",2)

    settings.clear()
    settings.load("data/billies")
    prot = settings.get("prot")
    finding = true
    billies = {}
    i = 1
    time = 1.5
    while finding do
        oldTime = os.clock()
        id, name, prot2 = rednet.receive("billyStat-"..prot, time)
        if name ~= nil then
            found = false
            for i, v in ipairs(billies) do
                if v == id then found = true end
            end
            if found == false then
                table.insert(billies, id)
                paintutils.drawBox(6,i*2+2,20,i*2+2,buttonColor)
                term.setBackgroundColor(buttonColor)
                write(name,i*2+2)
                i = i+1
            end
            time = time-(os.clock()-oldTime)
            if time<0 then time = 0 end
        else finding = false end
    end
    settings.clear()
    term.setBackgroundColor(bgColor)
    write("  billies:  ",2)

    if table.getn(billies) == 0 then
        write("No devices!", 4)
        going = true
        while going do
            event, button, x, y = os.pullEvent("mouse_click")
            if x == 1 and y == 1 then
                going = false
                quit = true
            end
        end
    else
        going = true
        while going do
            event, button, x, y = os.pullEvent("mouse_click")
            if x <= 20 and x >= 6 then
                button = y/2-1
                if button <= table.getn(billies) and button >= 1 and button == math.floor(button) then
                    going = false
                end
            elseif x == 1 and y == 1 then
                going = false
                quit = true
            end
        end
        
        if quit == false then
            term.setBackgroundColor(bgColor)
            term.setTextColor(txtColor)
            term.clear()
            term.setBackgroundColor(colors.red)
            if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
            term.setCursorPos(1,1)
            term.write("<")
            term.setBackgroundColor(bgColor)
            write("loading...",2)
            id, name, prot2 = recvID(billies[button],"billyStat-"..prot, 1.5)
            id, kind, prot2 = recvID(billies[button],"billyStat-"..prot.."-data", 1.5)
            
            write("    "..name.."    ",2)
            write("type: "..kind,3)
            if kind == "miner" then
                id, desc, prot2 = recvID(billies[button],"billyStat-"..prot.."-data", 1.5)
                id, fuel, prot2 = recvID(billies[button],"billyStat-"..prot.."-data", 1.5)
                id, requiredFuel, prot2 = recvID(billies[button],"billyStat-"..prot.."-data", 1.5)

                write("description:",5)
                write(desc,6)
                x = (1-(fuel/requiredFuel))*24
                write("progess:",8)
                paintutils.drawLine(2,9,x+1,9,colors.green)
                paintutils.drawLine(x+2,9,25,9,colors.red)
                paintutils.drawBox(8,11,18,11,buttonColor)
                write("inventory",11)
                going = true
                while going do
                    event, button, x, y = os.pullEvent("mouse_click")
                    if x <= 20 and x >= 6 then
                        going = false
                        term.setBackgroundColor(bgColor)
                        term.setTextColor(txtColor)
                        term.clear()
                        term.setBackgroundColor(colors.red)
                        if bgColor == colors.red then term.setBackgroundColor(colors.brown) end
                        term.setCursorPos(1,1)
                        term.write("<")
                        term.setBackgroundColor(bgColor)
                        write("loading...",2)
                        i = 5
                        getting = true
                        id, name, prot2 = recvID(billies[button],"billyStat-"..prot, 1.5)
                        while getting do
                            id, item, prot2 = recvID(billies[button],"billyStat-"..prot.."-inv", 0.5)
                            if item == "end" or item == nil then getting = false
                            else
                                write(item,i)
                                i = i+1
                            end
                        end
                        write("inventory:",2)
                        write("*updates every layer*",3)
                        going2 = true
                        while going2 do
                            event, button, x, y = os.pullEvent("mouse_click")
                            if x <= 1 and x >= 1 then going2 = false end
                        end
                    elseif x == 1 and y == 1 then
                        going = false
                    end
                end
            end
        end
    end
end