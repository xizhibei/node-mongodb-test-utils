'use strict';

const _ = require('lodash');
const Promise = require('bluebird');
const mongoose = require('mongoose');
const qs = require('querystring');
mongoose.Promise = Promise;

const HOST = process.env.PRIMARY_HOST || 'localhost';

const params = qs.stringify({
    'replicaSet': 'test-rs0',
    'readPreference': 'secondaryPreferred'
  });

// mongo driver will auto discover the replica set, so primary is enough
const url = `mongodb://${HOST}/test?${params}`;

const options = {
  replset: {
    poolSize: 10,
    socketOptions: {
      connectTimeoutMS: 2000,
      keepAlive: 1
    }
  },
  server: {
    poolSize: 10,
    autoReconnect: true
  }
};

mongoose.connect(url, options);
mongoose.connection.on('error', (err) => {
  console.log(err);
  process.exit(-1);
});
