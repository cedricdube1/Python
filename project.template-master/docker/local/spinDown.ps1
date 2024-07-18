docker-compose -p dbmigration -f docker-compose.yml -f ./sqlserver/docker-compose.override.yml down --remove-orphans
if (Test-Path ./tmp) {
    Get-ChildItem ./tmp -Include *.* -Recurse | Remove-Item -Force -Recurse
    Remove-Item ./tmp -Force
}
