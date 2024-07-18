# MSSQL Database Migration: dbSurge

Contains necessary files and configurations for building a migration image.

## Special Note
NONE

## Configuration
### deploymentVars
- LOCAL_DEPENDENCY_MIGRATION_SEQUENCE:
- LOCAL_DEPENDENCY_DB_SEQUENCE:
- MIGRATION_DB_SEQUENCE: dbSurge
- MIGRATION_COMMAND_TIMEOUT_DEFAULT: 120
- MIGRATION: dbSurge
- IMAGE_ONLY: false

## Util
### dbSurge
1. Scraper: YES
2. Generator: NO


## Database Migration Sets
### dbSurge
1. Baseline: NO
2. Migration: YES
3. Test: NO

## Change Log
### 1.0.0 (Ticket: MBRD-001)
```
1. Initial version
  
```
### 1.1.0 (Ticket: MBRD-002)
```
1. Added dbo.MyTable
  
```