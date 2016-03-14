#!/usr/bin/env mongo 192.168.99.100

var ip = '192.168.99.100';
var initPort = 27018;
var secondaryNum = 4;

var conf = {
    _id: 'test-rs0',
    members: [{
        _id: 0,
        host: ip + ':' + initPort,
        priority: 10
    }]
};

rs.initiate(conf);
for (var i = 0;i < secondaryNum; i++) {
    rs.add(ip + ':' + (initPort + 1 + i));
}

