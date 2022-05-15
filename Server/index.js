const {WebSocketServer} = require("ws")
const wss = new WebSocketServer({port: 8080})

let clients = []

function BroadcastAll(message)
{
    clients.forEach(client => client.send(message))
}

wss.on('connection', function con(ws){
    ws.on('message', function(m){
        var msg = JSON.parse(m);
        if(msg.opcode == 0) // User connection
        {
            ws.nickname = msg.nickname
            clients.push(ws)
            var conAlert = {
                opcode: 2, // 2 = system message
                nickname: ws.nickname,
                message: "Connected"              
            }
            BroadcastAll(JSON.stringify(conAlert))
        }
        else if(msg.opcode == 1) // User message
        {
            var msgAlert = {
                opcode: 1, // 1 = user message
                nickname: ws.nickname,
                message: msg.message
            }
            BroadcastAll(JSON.stringify(msg))
        }
    })
})