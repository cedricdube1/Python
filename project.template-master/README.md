# MSSQL Database Migration: Project Template

Template which can be used, along with Build Templates which contains standard pipeline components, for your project to build and deploy database migrations.

## Special Note
By convention, folders under src which contain migration scripts for a database should have the root (database) folder of the database in lowercase. e.g NOT MyDB but mydb

## Requirements
Templates assume some standard configuration components in your project, as well as a standardised structure as laid out in this project.
- Depends on: CI/CD Variable on Project/Project Group: *ARTIFACTORY_USER*
- Depends on: CI/CD Variable on Project/Project Group: *ARTIFACTORY_TOKEN*
- Depends on: CI/CD Variable on Project/Project Group: *GITLAB_ACCESS_TOKEN*
- Depends on: CI/CD Variable on Project/Project Group: *{ENV}_SQL_USER*
- Depends on: CI/CD Variable on Project/Project Group: *{ENV}_SQL_PWD*
- Depends on: CI/CD Variable on Project/Project Group: *{ENV}_SQLSERVER*

## Getting Started
1. Clone this project : 
```
git clone {url to template project} {name of your project}
```
2. Change to the folder where your project resides
3. Rename the origin: 
```
git remote rename origin upstream
```
4. Create a new repo for your project in Gitlab. Do not initialise with a README, we will push into that repo first.
5. Set CICD/General Pipelines/Git Shallow Clone = 0 on the project settings. Also set "Pipelines must succeed"; "All discussions must be resolved" on; Merge Method to "Merge Commit" in General/Merge Requests
6. Add a new origin remote to your project, pointing to the new Gitlab project:
```
git remote add origin {url to new project}
```
7. Push to your new project:
```
git push -u origin master
```
8. In Gitlab, add a tag to begin versioning (0.0.0)
9. Create a "develop" branch from master:
```
git checkout -b develop
```
10. Push the develop branch to your new project:
```
git push -u origin develop
```
11. Create a new feature branch from develop:
```
git checkout -b feature/myfeature develop.
```
12. Copy the pipeline/.gitlab-ci.yml; pipeline/GitVersion.yml pipeline/README.md to your root folder

Now we're all set to work with our repo following gitflow process.
*Be sure to update your README.md accordingly for your project*

Here's a great article on the process and how our GitVersion config supports the workflow :https://www.continuousimprover.com/2022/02/gitversion.html

## Grate
A database migration tool which is utilised by this project and templates. For further detail, see : https://erikbra.github.io/grate/getting-started/

## tSQLt
A database unit test framework which is utilised by this project and templates. For further detail, see : https://tsqlt.org/

## Config
deploymentVars.txt files is used to house common deployment variables set which will apply both to local development environment as well as to the pipeline.
Updates must be made in here to suit your project:
- *LOCAL_DEPENDENCY_MIGRATION_SEQUENCE*: Comma delimited list of dependency migration names. Updated per your requirements or leave blank ("")
- *LOCAL_DEPENDENCY_DB_SEQUENCE*: Comma delimited list of dependency database names. Updated per your requirements or leave blank ("")
- *MIGRATION_DB_SEQUENCE*: Comma delimited list of migration database names that form part of your /src. Updated per your requirements.
- *MIGRATION_COMMAND_TIMEOUT_DEFAULT*: Defaults to 120 seconds. As the migration needs to withstand the longest running command, this setting is applied as the timeout across migration commands.
- *MIGRATION*: Name of the migration which should be unique within the repository/namespace/suffix as it forms the suffix of the pushed image(s)
- *IMAGE_ONLY*: Not all migration projects should result in a deployment to an environment other than local. For example, if a database is not managed by our projects but by another team, but we require an image that represents that database as a dependency, this can be set to true which will prevent deployment to any environment other than LOCAL.

## Docker
In docker, there are compose configurations for each of local;dev;test;prod environments.
Typically, dev;test;prod should not require changes as they do not compose dependencies (those should already be existent in the target environments).
### Local
Local will require updating in the event you have dependency databases - these images will need to be pulled into your compose project. See docker/local/docker-compose.yml for an example.

Local applies to both your machine (if spinUp using docker desktop) and also to the gitlab runner. What you build and test locally on your machine will be composed up on a feature or release branch in the pipeline.

## Image
Contains the dockerfile for the migration image. THe image is built in the context of /src. Changes here should typically not be required.

## Util
Configuration used when running the listed utilities can be stored in here. This allows other developers who may make changes to a project to share the configurations used

## Pipeline
Contains the standard ci yml; GitVersion file and a project README.md template.

## src
Contains three folder sets, differentiating deployment of baseline, migration and tests.
You will need to update src to reflect the databases relevant to your project e.g. src/mytestdb changes to src/{yourdb}
1. Baseline: These files will only be deployed to local. In any other environment, they will be "TRACKED_ONLY" meaning they will be recorded as having run but not actually execute.
2. Migration: These files will deploy as part of your pipeline execution. The special Env.{ENV} tag on the file naming suffix is used to specify when a file is only applicable to a specific environment. 
   - For example *001.prepareServer.Env.LOCAL* will only run on the LOCAL environment, which is applicable on a feature/release branch or your local machine.
3. Test: By default, contains files specific to local which will configure tSQLt for usage. Tests will not be run for dependency databases and will not be run against production. 


Defined folder structure for deployments
```
- root
  - config
    deploymentVars.txt
  - docker
   - local
     - sqlserver
       - docker-compose.override.yml
     - .env
     - docker-compose.yml
     - spinDown.ps1
     - spinUp.ps1
   - dev
     - .env
     - docker-compose.yml
   - test
     - .env
     - docker-compose.yml
   - prod
     - .env
     - docker-compose.yml
  - image
    - Dockerfile
  - util
    - {database_name}
      - scraper
      - generator    
  - pipeline
    - .gitlab-ci.yml
    - GitVersion.yml
    - README.md
  - src
    - {database_name}
      - baseline
        - onlyChanged
        - folderSettings.txt
      - migration
        - 01.beforeMigration
        - 02.alterDatabase
        - 03.runAfterCreateDatabase
        - 04.runBeforeUp
        - 05.up
        - 06.runFirstAfterUp
        - 07.functions
        - 08.views
        - 09.sprocs
        - 10.triggers
        - 11.indexes
        - 12.runAfterOtherAnyTimeScripts
        - 13.permissions
        - 14.afterMigration
        - folderSettings.txt
    - test
      - onlyOnce
        - 001.prepareServer.Env.LOCAL.sql
        - 002.deployClass.Env.LOCAL.sql
      - onlyChanged
      - everyRun
      - folderSettings.txt
```