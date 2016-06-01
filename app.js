require('marko/node-require').install();
var fs      = require('fs');
var logger  = require('./logger');
var express = require('express');
var app = express();

// Redirect the system output and error pipes to a file
const access = fs.createWriteStream( '/var/log/node/console.log', { flags : 'a' } );
process.stdout.write = process.stderr.write = access.write.bind( access );

app.disable( 'x-powered-by' );

app.get( '/', ( request, response ) => {
   // response.send( 'Hello World (from NodeJS)!' );
   var template = require('./views/index.marko');
   template.render( {}, response );
});

app.listen( 8081 );