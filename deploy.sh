PATH=$PATH:~/.nvm/versions/node/v18.19.1/bin
npm install
npm run prepbuild
rsync -a _site /var/www/garden.desmondrivet.com/
