uniiv
=====
Your personal buddy to graduate in style.


#Installation
** Need ruby > 2.0.0 **
Clone the repo and install dependencies
```bash
git clone https://github.com/timcolonel/uniiv.git
bundle install
```

Install external dependencies
* Mysql server
* Graphviz

Setup the database login information for the machine

```bash
rails g uniiv:install
```

```bash
rake db:create
rake db:migrate
rake db:sync_local #Not working currently use mysql workbench to export main dev and reimport locally

```

[Javascript tools](https://github.com/timcolonel/uniiv/wiki/Javascript)


#Server

## One time step:
* Install nginx
* [Install solr](https://github.com/timcolonel/uniiv/wiki/Installing-solr)


## Deploy
Use capistrano, require to have ssh access to the server user deploy
```bash
cap <environment> deploy #Deploy new version 
cap <environment> solr:reindex #Reindex
```

