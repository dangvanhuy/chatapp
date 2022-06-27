const express = require('express');

const app = express();
const POST = process.env.POST || 4000;
const server = app.listen(POST, () => {
    console.log('Sever is Started on', POST);
});

const io = require('socket.io')(server);
const connectedUser =new Set();
io.on('connection', (socket) => {
    console.log("Connected Successfully", socket.id);
    connectedUser.add(socket.id);
    io.emit('connected-user', connectedUser.size);
    socket.on('disconnet',()=>{
        console.log("Diconnected", socket.id);
        connectedUser.delete(socket.id);
        io.emit('connected-user', connectedUser.size);
    });

    socket.on('message',(data)=>{
        console.log(data);
        socket.broadcast.emit('message-receive',data);
    });
});
