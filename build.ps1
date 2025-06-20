$rpfmPath = "..\_RustPackFileManager\rpfm_cli.exe"
# \AppData\Roaming\FrodoWazEre\rpfm\config\schemas\schema_wh3.ron
$tw3Schema = ".\schema_wh3.ron"
$files = Get-ChildItem ".\"
foreach ($f in $files) {
    # Work per folder
    $folderNameFull = $f.FullName
    $folderName = $f.Name
    $importFolderName = "$folderNameFull\pack"
    $folderObject = get-item $folderNameFull
    if(!$folderObject.PSIsContainer) {
        continue
    }
    if(!(Test-Path $importFolderName)) {
        continue
    }
    $folderName
    # Run buildscript
    $generationScript = "$folderNameFull\generateData.ps1"
    $genFolderName = "$folderNameFull\gen"
    if(Test-Path $generationScript -PathType Leaf)
    {
        &"$generationScript"
    }
    # Generate pack file
    $packFileName = "$folderNameFull\kafka_$folderName.pack"
    if(Test-Path $packFileName) {
        Remove-Item -Path $packFileName
    }
    & $rpfmPath --game warhammer_3 pack create -p $packFileName
    & $rpfmPath --game warhammer_3 pack add -F $importFolderName -p $packFileName -t $tw3Schema
    if(Test-Path $generationScript -PathType Leaf)
    {
        & $rpfmPath --game warhammer_3 pack add -F $genFolderName -p $packFileName -t $tw3Schema
    }
}