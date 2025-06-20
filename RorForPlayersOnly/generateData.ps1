$Tab = [char]9

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

# Extract units table
$tmpPath = "./tmp"
$rpfmPath = "../../_RustPackFileManager\rpfm_cli.exe"
$dbPackFilePath = "E:/SteamLibrary/steamapps/common/Total War WARHAMMER III/data/db.pack"
$tw3Schema = "$env:APPDATA/FrodoWazEre/rpfm/config/schemas/schema_wh3.ron"
$extractPath = "/db/main_units_tables/data__;$tmpPath"
& $rpfmPath --game warhammer_3 pack extract -p $dbPackFilePath -t $tw3Schema -f $extractPath
$unitsFilePath = "./tmp/db/main_units_tables/data__.tsv"
$unitsFileContent = Get-Content $unitsFilePath
# Look for index of is_renown column
$rorMarkerColumnIndex = -1
$counter = 0
foreach($firstLineSplit in $unitsFileContent[0].Split($Tab)) {
    if($firstLineSplit -eq "is_renown")
    {
        $rorMarkerColumnIndex = $counter
        break
    }
    $counter++
}
if($rorMarkerColumnIndex -eq -1)
{
    Write-Output "is_renown column not found"
    return
}
# Find ror in table
$rorList = [System.Collections.Generic.List[String]]::new()
$skipCounter = 0
foreach($line in $unitsFileContent) {
    if($skipCounter -lt 2)
    {
        $skipCounter++
        continue
    }
    $splitLine = $line.Split($Tab)
    $name = $splitLine[0]
    $isRor = [System.Convert]::ToBoolean($splitLine[$rorMarkerColumnIndex])
    if($isRor)
    {
        $rorList.Add($name)
    }
}
# Write to file
Remove-Item -Path "./gen" -Recurse
$rorUnitsLuaList = "./gen/script/campaign/mod/kafka_rfpo_list.lua"
$null = New-Item -ItemType "file" -Path $rorUnitsLuaList -Force
Add-Content -Path $rorUnitsLuaList -Value 'local rfpo = core:get_static_object("kafka_rfpo")'
Add-Content -Path $rorUnitsLuaList -Value "rfpo.ror = {"
$firstLine = $true
foreach($ror in $rorList) {
    if(!$firstLine) {
        Add-Content -Path $rorUnitsLuaList -NoNewline -Value ","
    }
    Add-Content -Path $rorUnitsLuaList -Value "'$ror'"
    $firstLine = $false
}
Add-Content -Path $rorUnitsLuaList -Value "}"
# Cleanup
Remove-Item -Path $tmpPath -Recurse
Pop-Location