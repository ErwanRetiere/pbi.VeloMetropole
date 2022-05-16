$primaryKey = "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
$primaryKeySs = ConvertTo-SecureString -String $primaryKey -AsPlainText

$database = "MMM"
$cosmosDbContext = New-CosmosDbContext -Emulator -Database $database -Key $primaryKeySs
$collectionId = "GeolocCompteurs"
$id = "563115296"

$errors = @{}

try {
    $document = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId $collectionId -Id $id -PartitionKey $id
    Write-Host $document | ConvertFrom-Json
}
catch [Microsoft.PowerShell.Commands.HttpResponseException] {
    $errors.Add($id, $Error[0].Exception.Response.ReasonPhrase)
}
catch {
    Write-Host $Error[0].Exception
}

ConvertTo-Json $errors | Write-host