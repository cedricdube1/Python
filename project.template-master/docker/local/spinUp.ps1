
param(
	$CONFIG_PATH = "../../config/deploymentVars.txt"
    )

# CHECK PATH  
if (-Not(Test-Path $CONFIG_PATH)) {
    Write-Output("CONFIG_PATH provided does not exist. Terminating.")
    return
  }
# DEFINE INPUTS
$config = Get-Content -Path $CONFIG_PATH
foreach ($string in $config)
{
    $configSplit = $string -split "="
    $variableName = $configSplit[0]
    $variableValue = $configSplit[1]
    New-Variable -name $variableName.ToUpper().Trim() -value $variableValue.Trim()

}
if (-Not(Test-Path variable:LOCAL_DEPENDENCY_MIGRATION_SEQUENCE)) {
  Write-Output("LOCAL_DEPENDENCY_MIGRATION_SEQUENCE will default to empty. Syntax: LOCAL_DEPENDENCY_MIGRATION_SEQUENCE=dependentmigration, othermigration.")
  $LOCAL_DEPENDENCY_DB_SEQUENCE=""
}
if (-Not(Test-Path variable:LOCAL_DEPENDENCY_DB_SEQUENCE)) {
  Write-Output("LOCAL_DEPENDENCY_DB_SEQUENCE will default to empty. Syntax: LOCAL_DEPENDENCY_DB_SEQUENCE=mydependency, myotherdependency.")
  $LOCAL_DEPENDENCY_DB_SEQUENCE=""
}
if (-Not(Test-Path variable:MIGRATION_COMMAND_TIMEOUT_DEFAULT)) {
  Write-Output("MIGRATION_COMMAND_TIMEOUT_DEFAULT will default to 120. Syntax: MIGRATION_COMMAND_TIMEOUT_DEFAULT=120.")
  $MIGRATION_COMMAND_TIMEOUT_DEFAULT=120
}
if (-Not(Test-Path variable:MIGRATION_DB_SEQUENCE)) {
  Write-Output("MIGRATION_DB_SEQUENCE is required. Syntax: MIGRATION_DB_SEQUENCE=mydb, myotherdb. Terminating.")
  return
}
if (-Not(Test-Path variable:MIGRATION)) {
  Write-Output("MIGRATION is required. Syntax: MIGRATION=MyMigration. Terminating.")
  return
}

Write-Output("*********************************************")
Write-Output("Running with configuration: ")
Write-Output("*********************************************")
Write-Output("LOCAL_DEPENDENCY_MIGRATION_SEQUENCE: "+$LOCAL_DEPENDENCY_MIGRATION_SEQUENCE)
Write-Output("LOCAL_DEPENDENCY_DB_SEQUENCE: "+$LOCAL_DEPENDENCY_DB_SEQUENCE)
Write-Output("MIGRATION_COMMAND_TIMEOUT_DEFAULT: "+$MIGRATION_COMMAND_TIMEOUT_DEFAULT)
Write-Output("MIGRATION_DB_SEQUENCE: "+$MIGRATION_DB_SEQUENCE)
Write-Output("MIGRATION: "+$MIGRATION) 
Write-Output("*********************************************")
# SANITIZE INPUTS
$LOCAL_DEPENDENCY_MIGRATION_SEQUENCE = $LOCAL_DEPENDENCY_MIGRATION_SEQUENCE -replace '\s',''
$LOCAL_DEPENDENCY_DB_SEQUENCE = $LOCAL_DEPENDENCY_DB_SEQUENCE -replace '\s',''
$MIGRATION_DB_SEQUENCE = $MIGRATION_DB_SEQUENCE -replace '\s',''
$MIGRATION = $MIGRATION -replace '\s',''
# SPIN DOWN LOCAL INSTANCE AS SPECIFIED IN THE local/docker-compose
.\spinDown.ps1

$ENV_DEPLOYMENT="local"
if(-not(Test-Path ./tmp)) {
    New-Item  -ItemType Directory ./tmp
}

# SPIN UP LOCAL INSTANCE AS SPECIFIED IN THE local/docker-compose
docker-compose -p dbmigration -f docker-compose.yml -f ./sqlserver/docker-compose.override.yml up -d --build --force-recreate
Write-Output "Log Start" > ./tmp/log.txt

if ($LOCAL_DEPENDENCY_MIGRATION_SEQUENCE -ne "") {
  $LOCAL_DEPENDENCY_MIGRATION_SEQUENCE.Split(",") | ForEach-Object {
    $MIGRATION_NAME=$_.ToString().Trim()
    docker cp dbmigration_${MIGRATION_NAME}_1:/app/data/. ./tmp/${MIGRATION_NAME}
    docker cp ./tmp/${MIGRATION_NAME}/. dbmigration_base_1:/app/data/${MIGRATION_NAME}
    if ($LOCAL_DEPENDENCY_DB_SEQUENCE -ne "") {
      $LOCAL_DEPENDENCY_DB_SEQUENCE.Split(",") | ForEach-Object {
        $DATABASE_NAME=$_.ToString().Trim()
        $DATABASE_NAME_CLEANED=$DATABASE_NAME.ToLower()
        Write-Output ("Processing database: " + $DATABASE_NAME + " from migration: " + $MIGRATION_NAME)
        $FOLDER_PATH="./$MIGRATION_NAME/$DATABASE_NAME_CLEANED"
        docker exec dbmigration_base_1 grate --schema=grateDeployment_${DATABASE_NAME_CLEANED} --environment=$ENV_DEPLOYMENT --commandtimeout=$MIGRATION_COMMAND_TIMEOUT_DEFAULT --silent --files="$FOLDER_PATH/migration" --folders="$FOLDER_PATH/migration/folderSettings.txt" --connectionstring="Server=sqlserver;Database=$DATABASE_NAME;User Id=sa;Password=sql@dm1n;Encrypt=False" >> ./tmp/log.txt
     }
    }
  }
}

 $MIGRATION_DB_SEQUENCE.Split(",") | ForEach-Object {
    $DATABASE_NAME=$_.ToString().Trim()
    $DATABASE_NAME_CLEANED=$DATABASE_NAME.ToLower()
    $MIGRATION_CLEANED=$MIGRATION.ToLower()
    $MIGRATION_CLEANED=$MIGRATION_CLEANED.replace("-","_")
    Write-Output "Processing migration: " + $DATABASE_NAME
    docker cp dbmigration_migration_1:/app/data/. ./tmp
    docker cp ./tmp/. dbmigration_base_1:/app/data
    docker exec dbmigration_base_1 grate --schema=grateDeployment_${MIGRATION_CLEANED} --environment=$ENV_DEPLOYMENT --commandtimeout=$MIGRATION_COMMAND_TIMEOUT_DEFAULT --silent --files="./$DATABASE_NAME_CLEANED/baseline" --folders="./$DATABASE_NAME_CLEANED/baseline/folderSettings.txt" --connectionstring="Server=sqlserver;Database=$DATABASE_NAME;User Id=sa;Password=sql@dm1n;Encrypt=False" >> ./tmp/log.txt
    docker exec dbmigration_base_1 grate --schema=grateDeployment_${MIGRATION_CLEANED} --environment=$ENV_DEPLOYMENT --commandtimeout=$MIGRATION_COMMAND_TIMEOUT_DEFAULT --silent --files="./$DATABASE_NAME_CLEANED/migration" --folders="./$DATABASE_NAME_CLEANED/migration/folderSettings.txt" --connectionstring="Server=sqlserver;Database=$DATABASE_NAME;User Id=sa;Password=sql@dm1n;Encrypt=False" >> ./tmp/log.txt
    docker exec dbmigration_base_1 grate --schema=grateDeployment_${MIGRATION_CLEANED} --environment=$ENV_DEPLOYMENT --commandtimeout=$MIGRATION_COMMAND_TIMEOUT_DEFAULT --silent --files="./$DATABASE_NAME_CLEANED/test" --folders="./$DATABASE_NAME_CLEANED/test/folderSettings.txt" --connectionstring="Server=sqlserver;Database=$DATABASE_NAME;User Id=sa;Password=sql@dm1n;Encrypt=False" >> ./tmp/log.txt 
}

Write-Output "Logs retained in ./tmp/log.txt"