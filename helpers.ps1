Function readFactionList {
    param (
        [string]$dbPackFilePath,
        [string]$extractPath,
        [string]$factionsFilePath
    )
    $Tab = [char]9
    $rpfmPath = "../../_RustPackFileManager\rpfm_cli.exe"
    $tw3Schema = "$env:APPDATA/FrodoWazEre/rpfm/config/schemas/schema_wh3.ron"
    & $rpfmPath --game warhammer_3 pack extract -p $dbPackFilePath -t $tw3Schema -f $extractPath > $null
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
    return $factionList
}

Function createTsvFilesFromFactionList {
    param (
        [System.Collections.Generic.List[String]]$factionList,
        [string]$fileName,
        [string]$bundleName,
        [string]$effectBaseName
    )
    # Generate aversion effects tables
    $factionToEffectJunctionFilePath = "./gen/db/effect_bonus_value_faction_junctions_tables/$fileName.tsv"
    $effectBundlesToEffectsJunctionFilePath = "./gen/db/effect_bundles_to_effects_junctions_tables/$fileName.tsv"
    $effectsFilePath = "./gen/db/effects_tables/$fileName.tsv"
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
        $effectName = $effectBaseName + "_" + $counter
        # Create factionToEffectJunction
        $factionToEffectJunction = "diplomatic_mod	$effectName	$faction"
        Add-Content -Path $factionToEffectJunctionFilePath -Value $factionToEffectJunction
        # Create effects
        $effect = "$effectName	diplomacy.png	5	diplomacy.png	campaign	true"
        Add-Content -Path $effectsFilePath -Value $effect
        # Create effectBundlesToEffectsJunction
        $effectBundleToEffectJunction = "$bundleName	$effectName	faction_to_faction_own_unseen	-1.0000	start_turn_completed"
        Add-Content -Path $effectBundlesToEffectsJunctionFilePath -Value $effectBundleToEffectJunction
        $counter += 1
    }
}