Function Load_MMM_EcoCompt {
	param(
		$filepath
	)
	$primaryKey = "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
	$primaryKeySs = ConvertTo-SecureString -String $primaryKey -AsPlainText

	$database = "MMM"
	$cosmosDbContext = New-CosmosDbContext -Emulator -Database $database -Key $primaryKeySs
	$collectionId = "EcoCompt"

	$documents = Get-Content -Path $filePath | ConvertFrom-Json
	$errors = @{}

	Foreach ($document in $documents) {
		if (-Not ($null -eq $document.Id)) {
			Write-Host "Chargement du document #$($document.Id.ToString())"
			$documentJson = ConvertTo-Json $document
			try {
				New-CosmosDbDocument -Context $cosmosDbContext -CollectionId $collectionId -DocumentBody $documentJson -PartitionKey $document.Id
			}
			catch [Microsoft.PowerShell.Commands.HttpResponseException] {
				if ($errors[$document.Id]) {
					$errors[$document.Id] = $Error[0].Exception.Response.ReasonPhrase
				}
				else {
					$errors.Add($document.Id, $Error[0].Exception.Response.ReasonPhrase)
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

Get-ChildItem $sourceFolderName -Filter *_archive.json | Foreach-Object {
    $filePath = $_.FullName

	# Nettoyer le fichier JSON
	Write-Host "Preparation du fichier : $($filePath)"
	dotnet script ./MMM_json_sanitizer.csx -- $filePath

	# Charger le contenu du fichier dans la DB
	Write-Host "Chargement du contenu en DB : $($filePath)"
	$result = Load_MMM_EcoCompt $filePath
	$destinationDirectory = "$($sourceFolderName)\$($result -eq 0 ? 'done' : 'error')"
 
	# Déplacement du fichier dans le répertoire done / error en fonction du résultat
	Move-Item -Path $filePath -Destination $destinationDirectory -force
}
