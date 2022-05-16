$destinationFolderName = $args[0]
Write-Host $destinationFolderName
# Recuperation du fichier listant les eco-compteurs
$compteurIds = @()
$url = "https://data.montpellier3m.fr/sites/default/files/ressources/MMM_MMM_GeolocCompteurs.geojson"
$response = [system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest $url).RawContentStream.ToArray()) | ConvertFrom-Json
# Récupération de la liste des identifiants des eco-compteurs
Foreach ( $document in $response.features ) {
    if ( $document.properties."N° Série futur".Length -ne 0 ) {
        $compteurIds += $document.properties."N° Série futur"
    }
    else {
        $compteurIds += $document.properties."N° Série actuel"
    }
}
# Persistance du fichier (pour ingestion dans PBI)
Write-Host "Recuperation du fichier listant les eco-compteurs"
Invoke-WebRequest -Uri $url -OutFile "$($destinationFolderName)\MMM_MMM_GeolocCompteurs.geojson"

# Recuperation des fichiers d'archive des eco-compteurs
foreach ( $compteurId in $compteurIds ) {
   $fileName = "MMM_EcoCompt_$($compteurId)_archive.json"
   Write-Host "Recuperation de l'archive de l'eco-compteur $($compteurId)"
   $url = "https://data.montpellier3m.fr/sites/default/files/ressources/$($fileName)"
    Invoke-WebRequest -Uri $url -OutFile "$($destinationFolderName)\$($fileName)"
}