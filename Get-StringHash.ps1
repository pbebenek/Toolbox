function Get-StringHash {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $InputObject,
        [Parameter(Mandatory=$false)]
        [switch]
        $ReturnHashOnly
    )
    $objectStream = [IO.MemoryStream]::new([byte[]][char[]] $InputObject)
    $stringHash = Get-FileHash -InputStream $objectStream

    if ($ReturnHashOnly) {
        $stringHash = Select-Object -InputObject $stringHash -ExpandProperty Hash
    }

    return $stringHash
}