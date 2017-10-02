---
title:      Dropwizard Database Migrations
created_at: 2013-05-10 12:00:00 +00:00
layout:     default
published: true
description: Database migrations are a way to programmatically manage, apply and track changes to a databases schema.
keywords: dropwizard, Liquibase, sql, migrations, rdbms
---

NoSQL for the win... wait what!? No!! Sorry but, I'll be talking about that stodgy undervalued workhorse called the SQL RDBMS. Specifically I'll illustrate how to manage a schema using Dropwizard[1] and its abstraction of Liquibase[2] migrations.

### What are migrations?

Database migrations are a way to programmatically manage, apply and track changes to a databases schema. The changes are typically tracked using a meta-data table and predefined sequence identifiers. As each change is successfully applied the meta-data is updated to include the sequence/change-set identifier, date of change, etc. Migrations are analogous to source control management in many respects and that's exactly what Liquibase provides, SCM tooling for your schema. Dropwizard migrations gives a nice container and abstraction for Liquibase and your migration scripts.

Migrations can be used to reverse a change-set (aka a roll-back) however, roll-backs must be explicitly defined with Liquibase. In practise roll-back procedures on a production database are non-trivial. Because a roll-back is outside the "Happy Path", delivery schedules often cause them to receive less time and attention. I highly encourage running automated verification of your roll-back procedure with production like data **before** trying it against production.

### Evolution of a table

As an illustration let's start with a simple table DDL that tracks clicks;

v1 - we record the time and item clicked.

    CREATE TABLE clicks (
      clicktime TIMESTAMP,        -- time of the event
      item_clicked VARCHAR(255)   -- the button id or URL clicked
    );

v2 - we also want to track a users journey through our site via their session ID.

    CREATE TABLE clicks (
      clicktime TIMESTAMP,        -- time of the event
      item_clicked VARCHAR(255),  -- the button id or URL clicked 
      session VARCHAR(255),       -- the session or user ID
    );

v1 to v2 transition for existing tables

    ALTER TABLE clicks 
      ADD 
        session VARCHAR(255);    -- the session or user ID

In a traditional approach you may have a pile of SQL scripts that are applied one by one (or worse manually typed into each console). As illustrated above there are 2 different ways to produce a v2 table. For new environments you can use the v2 script directly. For an existing environment (such as production) it's likely more desirable to use the transition script if you already have valuable data. You could simply use the v1 and v1 to v2 transition script everywhere but, you're essentially replicating what migration tools do (there's a dry-run option if you want/need to know what's going to happen).

The main concern database migration tools try to address is that as tables are added and relations are built it becomes time consuming to track what changes need to be applied (and difficult to do it safely and consistently). The previously mentioned DDL is the type of tedium that computers were built to help with and the mechanics that migrations are ideally suited. So let's get started with our Dropwizard project which I'll call "velodrome".

### Dropwizard First Steps

Getting started with Liquibase migrations is as simple as adding the dropwizard-migrations, and the appropriate JDBC driver[3] as a dependency to your project. If you're using maven this is the spec for dropwizard-migrations (note the dropwizard.version property, you'll need to add or substitute it in your pom file);

    <dependency>
            <groupId>com.yammer.dropwizard</groupId>
            <artifactId>dropwizard-migrations</artifactId>
            <version>${dropwizard.version}</version>
    </dependency>

As described in the [manual](http://dropwizard.codahale.com/manual/migrations/) you'll need to add the bundle to your initialize method, database configuration to your configuration class and a configuration YAML file containing the database details.

config.yml

    database:
      driverClass: org.apache.derby.jdbc.EmbeddedDriver
      url: jdbc:derby:db/velodrome;create=true
      user: SA
      password:

### Liquibase Migrations

Once you've added the dependencies and Dropwizard code you can start on the actual migration resources. Dropwizard uses `src/main/resources/migrations.xml` as the entry point for migrations. Personally I prefer one file per change-set[4] so let's store each change-set in a folder called "migrations" located at `src/main/resources/migrations/`. I dislike XML based configuration so I'll specify all of the migrations in [SQL format](http://www.liquibase.org/documentation/sql_format.html).

src/main/resources/migrations.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <databaseChangeLog
            xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
             http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-2.0.xsd">

      <includeAll path="migrations"/>
    </databaseChangeLog>

src/main/resources/migrations/00001\_create\_clicks\_table.sql

    --liquibase formatted sql

    --changeset nfisher:1
    CREATE TABLE clicks (
      clicktime TIMESTAMP,        -- time of the event
      item_clicked VARCHAR(255)   -- the button id or URL clicked
    );

    --rollback DROP TABLE clicks;

src/main/resources/migrations/00002\_add\_session\_column\_to\_clicks\_table.sql

    --liquibase formatted sql


    --changeset nfisher:2
    ALTER TABLE clicks 
      ADD (
        session VARCHAR(255)       -- the session or user ID
      );
    --rollback ALTER TABLE clicks DROP session;

When executed Liquibase will handle all of the tracking and intelligently apply the transitions as required. An important point to make is that you should **avoid** making changes to your change-sets once they've been shared with others and/or applied against production (follow the same rules as Git rebasing). This ensures you can recreate a database that has the same schema as every other that is associated with the application.

### Build and running a migration

Dropwizard packs all of the migrations into the JAR file as resources making a single transportable binary. To generate the JAR file simply use mavens package command.

    mvn package

This will generate a binary in the `target` folder. For this project `target/velodrome-0.0.1-SNAPSHOT.jar`. For local development I would recommend making an alias called velodrome using the following command;

    alias velodrome="java -jar $PROJECT_HOME/target/velodrome-0.0.1-SNAPSHOT.jar"

Some of the available commands include;

    $ velodrome db -h                           # list available commands
    $ velodrome db status config.yml            # output what change-sets need to be applied, if any
    $ velodrome db migrate config.yml           # migrate the database to the latest revision
    $ velodrome db migrate --dry-run config.yml # output the SQL that will be used to migrate the database

### Final Notes

Dropwizard and Liquibase provide a nice and neat package to migrate schemas. The single package design reduces the number of moving parts simplifying, the path to production and reducing the possibility of mismatched environments. The externalised configuration makes provisioning a new environment a breeze. And with the command driven interface it is easily instrumented into a build pipeline which can provide a level of automation, reliability and consistency that will free your DBA's for other problems.

#### Footnotes

[1] [Dropwizard](http://dropwizard.codahale.com) is a production-ready REST framework.

[2] [Liquibase](http://www.liquibase.org) is a database migration library.

[3] For velodrome I've used [Apache Derby](http://db.apache.org/derby/). I've found it to be the least problematic of the embedded databases for cross-platforms applications but, any database with a JDBC driver can be used. (I was time crunched and have yet to spend a lot of time diagnosing the issues I experienced with H2 and HSQLDB)

[4] One file per change-set reduces the likelihood of changing previous change-sets by accident. It also makes any changes to an existing change-set directly visible in your SCM's history.
