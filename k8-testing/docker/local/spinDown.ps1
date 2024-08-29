docker-compose -p mongodb -f docker-compose.yml down --remove-orphans
if (Test-Path ./tmp) {
    Get-ChildItem ./tmp -Include *.* -Recurse | Remove-Item -Force -Recurse
    Remove-Item ./tmp -Force
}
