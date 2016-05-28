const winston = require('winston');

// Logging levels
const config = {
   levels: {
      error : 0,
      info  : 1
   }
};

module.exports = new winston.Logger({
   transports : [
      new winston.transports.File({
         filename : '/var/log/node/node-error.log',
         json     : false
      })
   ],
   levels : config.levels
});