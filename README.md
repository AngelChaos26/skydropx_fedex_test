# Fedex API Testing

Fedex API for testing based in the indications by SkyDropX.

## Prerequisites

You will need the following things properly installed on your computer. The recommended way of running this application is via Ruby installed with `rvm`.

* [RVM](http://rvm.io/)
* [Git](https://git-scm.com/)
* [PostgreSQL](https://www.postgresql.org/)

## Installation

* `git clone <repository-url>` this repository
* `cd api`
* `bundle install`
* `bundle exec rake db:setup`

## Setting up the dev environment

- Create a new file called `.env` in the root directory of the application based on `.env.sample`. Fill out the appropriate secrets before running the ruby server daemon.

```
FEDEX_KEY=
FEDEX_PASSWORD=
FEDEX_ACCOUNT=
FEDEX_METER=
FEDEX_MODE=
PACKAGES_FILE=
FEDEX_USERNAME=
FEDEX_DATABASE_PASSWORD=
```

- Install Rails dependencias, via `bundle command`.

```bash
bundle install
```

- Setup `development` and `test` db.

```bash
bundle exec rake db:setup
```

## Running / Development

* `rails s`
* Visit your app at [http://localhost:3000](http://localhost:3000).

## Testing

This application uses `rspec` for unit and integration testing. Before you commit your changes, make sure you've tested everything with the following commands:

* `rpec`

## Lint

This application uses `rubocop` for ruby style checking.

- `rubocop`

### ENV

Add the following to `.env`.

```sh
FEDEX_KEY='valor_proporcionada_en_documento'
FEDEX_PASSWORD='valor_proporcionada_en_documento'
FEDEX_ACCOUNT='valor_proporcionada_en_documento'
FEDEX_METER='valor_proporcionada_en_documento'
FEDEX_MODE='valor_proporcionada_en_documento'
PACKAGES_FILE=labels.json
FEDEX_USERNAME='usuario_db'
FEDEX_DATABASE_PASSWORD='password_db'
```
