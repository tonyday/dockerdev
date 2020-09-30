### Setup a basic Ruby/Node/Postgres Docker image that can used for development

 - based on Ubuntu Bionic
 - creates an "app" user (`docker`)
 - includes `zsh` and `zim`
 - installs `rbenv` and the latest `Ruby`
 - installs `nvm` (but does not install a specific `node` version)
 - sets up PostgreSQL Apt Repository (but does not install a specific Postgres version)
