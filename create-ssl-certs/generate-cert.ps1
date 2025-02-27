# generate an ssl cert a .cnf cert definition found in the 
openssl req `
    -newkey rsa:2048 `
    -x509 `
    -nodes `
    -keyout ./server.key `
    -new `
    -out ./server.crt `
    -config ./cert-def.cnf `
    -sha256 `
    -days 365