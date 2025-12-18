$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\..\helpers.ps1
Push-Location $dir
$tmpPath = "./tmp"

if (Test-Path -Path "./gen") {
    Remove-Item -Path "./gen" -Recurse
}
$dbPackFilePath = "E:/SteamLibrary/steamapps/common/Total War WARHAMMER III/data/db.pack"
$extractPath = "/db/factions_tables/data__;$tmpPath"
$factionsFilePath = "./tmp/db/factions_tables/data__.tsv"
$factionList = readFactionList -dbPackFilePath $dbPackFilePath -extractPath $extractPath -factionsFilePath $factionsFilePath
createTsvFilesFromFactionList -factionList $factionList -fileName "kafka_RandomizedAversionBase" -bundleName "kafka_ranav_diplomod_base_effect_bundle"  -effectBaseName "kafka_ranav_diplomod_base_effect"

# Cleanup
Remove-Item -Path $tmpPath -Recurse
Pop-Location