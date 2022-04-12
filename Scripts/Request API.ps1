$compteurIds = @()
$url = "https://data.montpellier3m.fr/sites/default/files/ressources/MMM_MMM_GeolocCompteurs.geojson"
$response = [system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest $url).RawContentStream.ToArray()) | ConvertFrom-Json
Foreach ( $document in $response.features ) {
    if ( $document.properties."N° Série futur".Length -ne 0 ) {
        $compteurIds += $document.properties."N° Série futur"
    }
    else {
        $compteurIds += $document.properties."N° Série actuel"
    }
}
$destinationFolderName = $args[0]
foreach ( $compteurId in $compteurIds ) {
   $fileName = "MMM_EcoCompt_$($compteurId)_archive.json"
   $url = "https://data.montpellier3m.fr/sites/default/files/ressources/$($fileName)"
    Invoke-WebRequest -Uri $url -OutFile "$($destinationFolderName)\$($fileName)"
}