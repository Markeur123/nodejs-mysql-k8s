const http = require('http');

http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  const mysql = require('mysql');
  const connection = mysql.createConnection({
    host     : 'mysql-prod.prod.svc.cluster.local',
    user     : 'dbproduser',
    password : 'password',
    database : 'dbprod',
  });

  connection.connect(err => {
    if (err) throw err;
    console.log('Connected');

    connection.query('CREATE TABLE IF NOT EXISTS hello_world (name VARCHAR(255))', (err, result) => {
      if (err) throw err;
      console.log('Table created');

      connection.query('INSERT INTO hello_world (name) VALUES ("Hello World")', (err, result) => {
        if (err) throw err;
        console.log('1 record inserted');

        connection.query('SELECT * FROM hello_world', (err, rows, fields) => {
          if (err) throw err;
          console.log('1 record selected');
          res.write(rows[0].name);
          res.end();

          connection.end(err => {
            if (err) throw err;
            console.log('Disconnected');
          });
        });
      });
    });
  });
}).listen(3000, () => console.log('Server listening at port 3000'));
