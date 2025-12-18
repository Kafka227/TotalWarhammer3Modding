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
& $rpfmPath --game warhammer_3 pack extract -p $dbPackFilePath -t $tw3Schema -f $extractPath > $null
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
# Write to files
$fileName = "kafka_rfpo"

$bundleToEffectJunction = "./gen/db/effect_bonus_value_faction_junctions_tables/$fileName.tsv"
$null = New-Item -ItemType "file" -Path $bundleToEffectJunction -Force
Add-Content -Path $bundleToEffectJunction -Value "bonus_value_id	effect	unit_record_key"
Add-Content -Path $bundleToEffectJunction -Value "#effect_bonus_value_unit_record_junctions_tables;0;db/effect_bonus_value_unit_record_junctions_tables/$fileName"
$counter = 1
foreach($ror in $rorList) {
    Add-Content -Path $bundleToEffectJunction -Value "unit_cap	kafka_rfpo_effect_$counter	$ror"
    $counter += 1
}

$effectsFilePath = "./gen/db/effects_tables/$fileName.tsv"
$null = New-Item -ItemType "file" -Path $effectsFilePath -Force
Add-Content -Path $effectsFilePath -Value "effect	icon	priority	icon_negative	category	is_positive_value_good"
Add-Content -Path $effectsFilePath -Value "#effects_tables;0;db/effects_tables/$fileName"
$counter = 1
foreach($ror in $rorList) {
    Add-Content -Path $effectsFilePath -Value "kafka_rfpo_effect_$counter	unit_capacity.png	0	unit_capacity.png	campaign	true	$ror"
    $counter += 1
}

$effectBundles = "./gen/db/effect_bundles_tables/$fileName.tsv"
$null = New-Item -ItemType "file" -Path $effectBundles -Force
Add-Content -Path $effectBundles -Value "key	localised_description	localised_title	bundle_target	priority	ui_icon	is_global_effect	show_in_3d_space	owner_only"
Add-Content -Path $effectBundles -Value "#effect_bundles_tables;4;db/effect_bundles_tables/$fileName"									
Add-Content -Path $effectBundles -Value "kafka_rfpo_bundle			faction	1	unit_capacity.png	true	false	true"

$effectBundleToEffectJunction = "./gen/db/effect_bundles_to_effects_junctions_tables/$fileName.tsv"
$null = New-Item -ItemType "file" -Path $effectBundleToEffectJunction -Force
Add-Content -Path $effectBundleToEffectJunction -Value "effect_bundle_key	effect_key	effect_scope	value	advancement_stage"
Add-Content -Path $effectBundleToEffectJunction -Value "#effect_bundles_to_effects_junctions_tables;3;db/effect_bundles_to_effects_junctions_tables/$fileName"				
#kafka_rfpo_bundle	kafka_rfpo_effect	faction_to_faction_own	-99.0000	start_turn_completed
$counter = 1
foreach($ror in $rorList) {
    Add-Content -Path $effectBundleToEffectJunction -Value "kafka_rfpo_bundle	kafka_rfpo_effect_$counter	faction_to_faction_own	-99.0000	start_turn_completed"
    $counter += 1
}

# Cleanup
Remove-Item -Path $tmpPath -Recurse
Pop-Location