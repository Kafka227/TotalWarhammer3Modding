$Tab = [char]9

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Push-Location $dir

# Extract factions table and read factions
$tmpPath = "./tmp"
$rpfmPath = "../../_RustPackFileManager\rpfm_cli.exe"
$dbPackFilePath = "E:/SteamLibrary/steamapps/common/Total War WARHAMMER III/data/db.pack"
$tw3Schema = "$env:APPDATA/FrodoWazEre/rpfm/config/schemas/schema_wh3.ron"
$extractPath = "/db/factions_tables/data__;$tmpPath"
& $rpfmPath --game warhammer_3 pack extract -p $dbPackFilePath -t $tw3Schema -f $extractPath
$factionsFilePath = "./tmp/db/factions_tables/data__.tsv"
$factionList = [System.Collections.Generic.List[String]]::new()
$skipCounter = 0
foreach($line in Get-Content $factionsFilePath) {
    if($skipCounter -lt 2)
    {
        $skipCounter++
        continue
    }
    $tabIndex = $line.IndexOf($Tab)
    $factionName = $line.Substring(0, $tabIndex)
    $factionList.Add($factionName)
}

Remove-Item -Path "./gen" -Recurse
# Generate aversion effects tables
$factionToEffectJunctionFilePath = "./gen/db/effect_bonus_value_faction_junctions_tables/kafka_RandomizedAversion.tsv"
$effectBundlesToEffectsJunctionFilePath = "./gen/db/effect_bundles_to_effects_junctions_tables/kafka_RandomizedAversion.tsv"
$effectsFilePath = "./gen/db/effects_tables/kafka_RandomizedAversion.tsv"
$null = New-Item -ItemType "file" -Path $factionToEffectJunctionFilePath -Force
$null = New-Item -ItemType "file" -Path $effectBundlesToEffectsJunctionFilePath -Force
$null = New-Item -ItemType "file" -Path $effectsFilePath -Force
Add-Content -Path $factionToEffectJunctionFilePath -Value "bonus_value_id	effect	faction"
Add-Content -Path $factionToEffectJunctionFilePath -Value "#effect_bonus_value_faction_junctions_tables;0;db/effect_bonus_value_faction_junctions_tables/kafka_RandomizedAversion"
Add-Content -Path $effectBundlesToEffectsJunctionFilePath -Value "effect_bundle_key	effect_key	effect_scope	value	advancement_stage"
Add-Content -Path $effectBundlesToEffectsJunctionFilePath -Value "#effect_bundles_to_effects_junctions_tables;3;db/effect_bundles_to_effects_junctions_tables/kafka_RandomizedAversion"
Add-Content -Path $effectsFilePath -Value "effect	icon	priority	icon_negative	category	is_positive_value_good"
Add-Content -Path $effectsFilePath -Value "#effects_tables;0;db/effects_tables/kafka_RandomizedAversion"	
$counter = 1
foreach($faction in $factionList) {
    # Create factionToEffectJunction
    $factionToEffectJunction = "diplomatic_mod	kafka_generic_diplomod_effect_$counter	$faction"
    Add-Content -Path $factionToEffectJunctionFilePath -Value $factionToEffectJunction
    # Create effects
    $effect = "kafka_generic_diplomod_effect_$counter	diplomacy.png	5	diplomacy.png	campaign	true"
    Add-Content -Path $effectsFilePath -Value $effect
    # Create effectBundlesToEffectsJunction
    $effectBundleToEffectJunction = "kafka_generic_diplomod_effect_bundle	kafka_generic_diplomod_effect_$counter	faction_to_faction_own_unseen	-1.0000	start_turn_completed"
    Add-Content -Path $effectBundlesToEffectsJunctionFilePath -Value $effectBundleToEffectJunction
    $counter += 1
}

# Cleanup
Remove-Item -Path $tmpPath -Recurse
Pop-Location