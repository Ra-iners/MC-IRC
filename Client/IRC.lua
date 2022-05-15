term.clear()
term.setCursorPos(1,1)


local Monitor = peripheral.find("monitor") or nil
if Monitor then
    print("You have a monitor connected. Do you want to switch to it? (y/n)")
    local input = read()
    if input == "y" then
        term.clear()
        term.setCursorPos(1,1)
        print("This GUI now acts as a keyboard. You will not see anything being typed here but it will appear on the display")
        term.redirect(Monitor)
        Monitor.setBackgroundColor(colors.black)
        Monitor.setTextColor(colors.white)
        Monitor.clear()
        Monitor.setTextScale(0.5)
        Monitor.setCursorPos(1,1)
    else
        print("Okay, I'll keep using the terminal.")
    end
end
sleep(1)
term.clear()
term.setCursorPos(1,1)
width,height = term.getSize()

print("Your name: ")
local Nickname = read()

local URL = "ws://8.tcp.ngrok.io:13412"
local ws = http.websocket(URL)

local Identify = {
    ["opcode"] = 0,
    ["nickname"] = Nickname
}
local JSIdentify = textutils.serializeJSON(Identify)
ws.send(JSIdentify)

function createTitle()
    term.setCursorPos(1,1)
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.white)
    term.clearLine()
    term.write(Nickname .." @ " ..URL .."")
    
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end
createTitle()



caretOffset = height
term.setCursorPos(1,caretOffset)
term.write(">")


messageYoff = 2
messagesReceived = 0
function getMessages()
    while true do
        e,u,m = os.pullEvent("websocket_message")
        local Message = textutils.unserializeJSON(m)
        
        term.setCursorPos(1,messageYoff)
        messageYoff = messageYoff + 1
        messagesReceived = messagesReceived + 1


        if Message.opcode == 1 then
            term.setTextColor(colors.white)
            print(Message.nickname .. ": " .. Message.message)
        elseif Message.opcode == 2 then
            term.setTextColor(colors.green)
            print(Message.nickname .." has joined the chat")
        end
        if messagesReceived > 17 then
            term.setCursorPos(1,1)
            term.clear()
            createTitle()
            messagesReceived = 0
            messageYoff = 2
            term.setCursorPos(1,caretOffset)
            term.write(">")
        end
        -- createTitle()
    end
end

function SendChatMessage(msg)
    local Message = {
        ["opcode"] = 1,
        ["nickname"] = Nickname,
        ["message"] = msg
    }
    local JSMessage = textutils.serializeJSON(Message)
    ws.send(JSMessage)
end

message = ""
function GetInput()
    while true do
        term.setTextColor(colors.white)
        local event, key, is_held = os.pullEvent("key")
        char = keys.getName(key)
        local ReplaceList = {
            ["leftShift"] = "",
            ["leftCtrl"] = "",
            ["rightShift"] = "",
            ["rightCtrl"] = "",
            
            ["capsLock"] = "",
            ["grave"] = "~",
            ["one"] = "1",
            ["two"] = "2",
            ["three"] = "3",
            ["four"] = "4",
            ["five"] = "5",
            ["six"] = "6",
            ["seven"] = "7",
            ["eight"] = "8",
            ["nine"] = "9",
            ["zero"] = "0",
            ["minus"] = "-",
            ["equals"] = "=",
            ["left"] = "",
            ["right"] = "",
            ["up"] = "",
            ["down"] = "",
            ["tab"] = "",
            ["leftBracket"] = "[",
            ["rightBracket"] = "]",
            ["backslash"] = "\\",
            ["semiColon"] = ";",
            ["apostrophe"] = "'",
            ["comma"] = ",",
            ["period"] = ".",
            ["slash"] = "/",
            ["space"] = " ",
            ["numPad0"] = "0",
            ["numPad1"] = "1",
            ["numPad2"] = "2",
            ["numPad3"] = "3",
            ["numPad4"] = "4",
            ["numPad5"] = "5",
            ["numPad6"] = "6",
            ["numPad7"] = "7",
            ["numPad8"] = "8",
            ["numPad9"] = "9",
            ["numPadMinus"] = "-",
            ["numPadPlus"] = "+",
            ["numPadEnter"] = "",
            ["numPadDecimal"] = ".",
            ["numPadDivide"] = "/",
            ["numPadMultiply"] = "*",
            ["numPadSubtract"] = "-",
            ["numPadAdd"] = "+",
            ["numPadClear"] = "",
            ["numPadEqual"] = "=",
            ["numPadDelete"] = "",
            ["numPadInsert"] = "",
            ["numPadHome"] = "",
            ["numPadEnd"] = "",
            ["numPadPageUp"] = "",
            ["numPadPageDown"] = "",
            ["numPadUp"] = "",
            ["numPadDown"] = "",
            ["numPadLeft"] = "",
            ["numPadRight"] = ""
        }
        char = ReplaceList[char] or char

        if char == "enter" then
            SendChatMessage(message)
            message = ""
            term.setCursorPos(1,caretOffset)
            term.clearLine()
            term.write(">")
            term.setCursorPos(3,caretOffset)
        elseif char == "backspace" then
            message = message:sub(1, -2)
            term.setCursorPos(3,caretOffset)
            
            term.setCursorPos(1,caretOffset)
            term.clearLine()
            term.write(">")
            term.setCursorPos(3,caretOffset)
            term.write(message)
        elseif char == "space" then
            message = message .. " "
            term.setCursorPos(1,caretOffset)
            term.clearLine()
            term.write(">")
            term.setCursorPos(3,caretOffset)
            term.write(message)
        else
            message = message .. char
            term.setCursorPos(3,caretOffset)
            term.write(message)
        end
    end
end
parallel.waitForAny(getMessages, GetInput)
