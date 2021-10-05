function Compare-JSON {
<#
.SYNOPSIS
    This is a basic function that compares two JSON files. It's limited to compare objects only on first depth level.
.NOTES

.EXAMPLE
    Compare-JSON -ReferenceJSON ($psobject1 | ConvertTo-Json -Depth 10) -DifferenceJSON ($psobject2 | ConvertTo-Json -Depth 10)
.EXAMPLE
    Compare-JSON -ReferenceJSON (Get-Content C:\file1.json) -DifferenceJSON (Get-Content C:\file2.json)

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ReferenceJSON,
        [Parameter(Mandatory)]
        [string]
        $DifferenceJSON
    )
    $comparisonList = New-Object Collections.Generic.List[psobject]

    $referenceHashtable = ConvertFrom-Json -InputObject $ReferenceJSON -AsHashtable
    $differenceHashtable = ConvertFrom-Json -InputObject $DifferenceJSON -AsHashtable

    $keyList = New-Object Collections.Generic.List[String]
    foreach ($key in ($referenceHashtable.Keys + $differenceHashtable.Keys)) {
        if (! $keyList.Contains($key)) {
            $keyList.Add($key)
        }
    }

    foreach ($item in $keyList) {
        $output = New-Object -TypeName psobject
        $referenceItemValue = $referenceHashtable.Item($item) | ConvertTo-Json -Depth 10
        $differenceItemValue = $differenceHashtable.Item($item) | ConvertTo-Json -Depth 10

        if ($referenceItemValue -eq $differenceItemValue) {
            $output | Add-Member -MemberType NoteProperty -Name Comparison -Value "=="
            $output | Add-Member -MemberType NoteProperty -Name Item -Value $item
            $comparisonList.add($output)
            $output
        }
        else {
            $output | Add-Member -MemberType NoteProperty -Name Comparison -Value "<>"
            $output | Add-Member -MemberType NoteProperty -Name Item -Value $item
            $comparisonList.add($output)
            $output
        }
    }
    return $comparisonList
}