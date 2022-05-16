Function Load_MMM_EcoCompt {
	param(
		$filepath
	)
	$primaryKey = "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
	$primaryKeySs = ConvertTo-SecureString -String $primaryKey -AsPlainText

	$database = "MMM"
	$cosmosDbContext = New-CosmosDbContext -Emulator -Database $database -Key $primaryKeySs
	$collectionId = "GeolocCompteurs"

	$documents = Get-Content -Path $filePath -Encoding utf8 | ConvertFrom-Json
	$errors = @{}

	Foreach ($document in $documents.features) {
        $documentId = $document.properties.OSM_Line_id.ToString()
		if (-Not ($null -eq $documentId)) {
			Write-Host "Chargement du document #$($documentId)"
			$document.properties | Add-Member -Type NoteProperty -Name 'id' -Value $documentId
			$documentJson = ConvertTo-Json $document.properties
			Write-Host $documentJson
			try {
				New-CosmosDbDocument -Context $cosmosDbContext -CollectionId $collectionId -DocumentBody $documentJson -PartitionKey $documentId
			}
			catch [Microsoft.PowerShell.Commands.HttpResponseException] {
				if ($errors[$documentId]) {
					$errors[$documentId] = $Error[0].Exception.Response.ReasonPhrase
				}
				else {
					$errors.Add($documentId, $Error[0].Exception.Response.ReasonPhrase)
				}
			}
			catch {
				Write-Host $Error[0].Exception
			}
		}
	}

	ConvertTo-Json $errors | Write-host
	Write-host "Nb erreurs : $($errors.count)"

	return ($errors.count = 0 ? 0 : -1)
}

<#
	Iteration des fichiers d'un répertoire 
	Préparation des fichiers JSON et chargement en DB
#>
$sourceFolderName = $args[0]

# Création des répertoires de traitement done / error si nécéssaire
$resultFolderName = "$($sourceFolderName)\done"
if (-Not (Get-Item -Path $resultFolderName -ErrorAction Ignore))
{    
    New-Item $resultFolderName -ItemType Directory
}

$resultFolderName = "$($sourceFolderName)\error"
if (-Not (Get-Item -Path $resultFolderName -ErrorAction Ignore))
{    
    New-Item $resultFolderName -ItemType Directory
}

Get-ChildItem $sourceFolderName -Filter MMM_MMM_GeolocCompteurs.geojson | Foreach-Object {
    $filePath = $_.FullName
    
	# Charger le contenu du fichier dans la DB
	Write-Host "Chargement du contenu en DB : $($filePath)"
	$result = Load_MMM_EcoCompt $filePath
	$destinationDirectory = "$($sourceFolderName)\$($result -eq 0 ? 'done' : 'error')"
 
	# Déplacement du fichier dans le répertoire done / error en fonction du résultat
	Move-Item -Path $filePath -Destination $destinationDirectory -force
}
