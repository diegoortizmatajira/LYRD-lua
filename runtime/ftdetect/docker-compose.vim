" Detect docker-compose.yaml as docker-compose filetype
au BufRead,BufNewFile docker-compose*.yaml set filetype=yaml.docker-compose
au BufRead,BufNewFile docker-compose*.yml set filetype=yaml.docker-compose

