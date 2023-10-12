<#
.SYNOPSIS
Converts names into title case and identifies names with the "Mc" or "Mac" prefixes.

.DESCRIPTION
The Out-Human function takes a list of names, converts the first names into title case, 
and identifies whether each name has the "Mc" or "Mac" prefix.

.PARAMETER Human
A name string to process.

.PARAMETER ExceptionList
An optional list of names that should not be processed with the "Mc" or "Mac" rule. 
These names will just get the regular title case treatment.

.EXAMPLE
@("sally smith", "don donaldson", "chester arthur", "john macarthur", "marty mcfly") | 
Out-Human -ExceptionList @('marty mcfly')

.EXAMPLE
# This example demonstrates how to filter and get names that fit the "Mc" or "Mac" criteria.
@("sally smith", "don donaldson", "chester arthur", "john macarthur", "marty mcfly") | 
Out-Human | Where-Object { $_.McOrMac }

#>

Function Out-Human {
    Param(
        # Name string to process
        [parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Human,

        # List of names that should not undergo the "Mc" or "Mac" transformation
        [string[]]
        $ExceptionList = @()
    )

    process {
        $textInfo = (Get-Culture).TextInfo
        $words = $Human -split ' '

        # Apply ToTitleCase to the first name
        $words[0] = $textInfo.ToTitleCase($words[0])

        # We only focus on the last name for the "Mc" and "Mac" transformation
        $lastNameIndex = $words.Length - 1
        $mcMacEncountered = $false

        if (-not ($ExceptionList -contains $words[$lastNameIndex])) {
            # Check for "mc" prefix in last name (case insensitive)
            if ($words[$lastNameIndex] -clike "mc*") {
                $words[$lastNameIndex] = "Mc" + $textInfo.ToTitleCase($words[$lastNameIndex].Substring(2))
                $mcMacEncountered = $true
            }
            # Check for "mac" prefix in last name (case insensitive)
            elseif ($words[$lastNameIndex] -clike "mac*") {
                $words[$lastNameIndex] = "Mac" + $textInfo.ToTitleCase($words[$lastNameIndex].Substring(3))
                $mcMacEncountered = $true
            } 
            else {
                $words[$lastNameIndex] = $textInfo.ToTitleCase($words[$lastNameIndex])
            }
        } else {
            $words[$lastNameIndex] = $textInfo.ToTitleCase($words[$lastNameIndex])
        }

        # Return a custom object
        [PSCustomObject]@{
            Name = ($words -join ' ')
            McOrMac = $mcMacEncountered
        }
    }
}

# Test
@("sally smith", "don donaldson", "chester arthur", "john macarthur", "marty mcfly") | Out-Human
@("sally smith", "don donaldson", "chester arthur", "john macarthur", "marty mcfly") | Out-Human -ExceptionList @('mcfly')
@("sally smith", "don donaldson", "chester arthur", "john macarthur", "marty mcfly") | Out-Human | Where-Object { $_.McOrMac }