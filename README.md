geonames
========

Rails project to download and import free data from geonames.org.

NOTE: This is an early work in progress. 

    rake db:create

    rake db:migrate

Populate database with postal codes for a particular country, specified with a country code:

    rake geonames:postal_codes[US]

