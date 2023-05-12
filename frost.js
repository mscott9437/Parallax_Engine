const fs = require('fs');
const http = require('http');

const port = 3000;
const host = '127.0.0.1';

http.createServer((req, res) => {

   const { headers, method, url } = req;

   let body = [];

   req.on('data', (chunk) => { body.push(chunk) }).on('end', () => {

      body = Buffer.concat(body).toString();

      switch(req.url) {

         case '/user.json':
            var reader = fs.createReadStream('user.json');
            reader.pipe(res);
            console.log(req.url);
            break;

         case '/':
            var reader = fs.createReadStream('proto.html');
            reader.pipe(res);
            console.log(req.url);
            break;

         case '/favicon.ico':
            res.statusCode = 200;
            res.end();
            console.log(req.url);
            break;

         case '/graph':
            res.statusCode = 200;
            res.setHeader('Content-Type', 'application/json');
            const resBody = { headers, method, url, body };
            res.write(JSON.stringify(resBody));
            res.end();
            console.log(req.url);
            break;

         default:
            res.statusCode = 404;
            res.end();
            console.log(req.url);
            break;

      }

      //res.writeHead(200, {'Content-Type': 'text/plain'});
      //res.end(JSON.stringify(resBody));

   })

}).listen(port, host, () => { console.log(`${host}:${port}`); });
