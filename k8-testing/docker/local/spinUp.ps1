
Write-Output("*********************************************")
Write-Output("Spining up mongo instances: ")
Write-Output("*********************************************")

# SPIN DOWN LOCAL INSTANCE AS SPECIFIED IN THE local/docker-compose
.\spinDown.ps1

#$ENV_DEPLOYMENT="local"
if(-not(Test-Path ./tmp)) {
    New-Item  -ItemType Directory ./tmp
}

# SPIN UP LOCAL INSTANCE AS SPECIFIED IN THE local/docker-compose
Write-Output "Log Start" > ./tmp/log.txt
docker-compose -p mongodb -f docker-compose.yml up -d --build --force-recreate #>> ./tmp/log.txt
Write-Output "Logs retained in ./tmp/log.txt" 