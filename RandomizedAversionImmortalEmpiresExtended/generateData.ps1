$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
. $dir\..\helpers.ps1
Push-Location $dir
$tmpPath = "./tmp"

if (Test-Path -Path "./gen") {
    Remove-Item -Path "./gen" -Recurse
}
$dbPackFilePath = "E:\SteamLibrary\steamapps\workshop\content\1142710\3007996493\!cr_immortal_empires_expanded.pack"
$extractPath = "/db/factions_tables/!cr_new_factions;$tmpPath"
$factionsFilePath = "./tmp/db/factions_tables/!cr_new_factions.tsv"
$factionListImmortal = readFactionList -dbPackFilePath $dbPackFilePath -extractPath $extractPath -factionsFilePath $factionsFilePath
createTsvFilesFromFactionList -factionList $factionListImmortal -fileName "kafka_RandomizedAversionImmortal" -bundleName "kafka_ranav_diplomod_extended_effect_bundle"  -effectBaseName "kafka_ranav_diplomod_extended_effect"

# Cleanup
Remove-Item -Path $tmpPath -Recurse
Pop-Location