geonames
========

Rails project to download and import free data from geonames.org.

NOTE: This is an early work in progress. 

This project uses MySQL. Since MySQL's default UTF-8 encoding only stores three bytes per character, and many of geoname.org's location names require four byte UTF-8, you'll see in database.yml and in migration files that datbase encoding is set to MySQL's utf8mb4 encoding, which allows for these names to be saved. If you use PostgreSQL, you can remove these encoding references, as PostgreSQL's UTF-8 stores the full 4 bytes by default.

Create database:

    > rake db:create

Migrate database:

    > rake db:migrate

Populate database with postal codes for a particular country, specified with a country code:

    > rake geonames:postal_codes[US]

Poulate database with feature codes used to classify geonames:

    > rake geonames:feature_codes
