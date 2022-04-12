$primaryKey = "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
$primaryKeySs = ConvertTo-SecureString -String $primaryKey -AsPlainText

$database = "MMM"
$cosmosDbContext = New-CosmosDbContext -Emulator -Database $database -Key $primaryKeySs
$collectionId = "EcoCompt"
$id = "MMM_EcoCompt_X2H20042635_202105120000x"

$errors = @{}

try {
    Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId $collectionId -Id $id -PartitionKey $id
}
catch [Microsoft.PowerShell.Commands.HttpResponseException] {
    $errors.Add($id, $Error[0].Exception.Response.ReasonPhrase)
}
catch {
    Write-Host $Error[0].Exception
}

ConvertTo-Json $errors | Write-host