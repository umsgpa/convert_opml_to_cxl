# Requires -Version 5.1
# © 2025 Gabriele PANCANI

function Convert-OpmlToCxl {
    <#
   .SYNOPSIS
        Converts a hierarchical OPML file to a CMap CXL concept map.
   .DESCRIPTION
        This script takes a single OPML file as input, parses its outline structure,
        and generates a new CXL XML file. It translates the parent-child relationships
        of the OPML tree into CXL propositions (Concept - Linking Phrase - Concept).
        The CXL file is programmatically built using the System.Xml.XmlDocument class
        to ensure schema compliance.
   .PARAMETER SourcePath
        The full path to the source.opml file.
   .PARAMETER DestinationPath
        The full path for the output.cxl file. If not specified, the script will
        create a.cxl file in the same directory as the source.
   .PARAMETER LinkingPhrase
        The text to use for the linking phrases. Defaults to "is a part of".
    #>
   
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,

        [string]$DestinationPath,

        [string]$LinkingPhrase = "is a part of"
    )

    # Helper function to generate a unique GUID for a CXL element ID
    function New-CxlId {
        return [guid]::NewGuid().ToString()
    }

    # Variables to track positions for visual layout
    $script:currentX = 100
    $script:currentY = 100
    $script:levelOffsetX = 200
    $script:levelOffsetY = 80

    # Recursive function to traverse the OPML tree and build the CXL document
    function Process-OpmlOutline {
        param(
           $OpmlNode,
            [string]$ParentConceptId,
            [int]$Level = 0
        )
        
        # Check if the OPML node has children (sub-outlines)
        if ($OpmlNode.HasChildNodes) {
            $childIndex = 0
            foreach ($ChildNode in $OpmlNode.ChildNodes) {
                if ($ChildNode.Name -eq 'outline') {
                    # Create the new CXL concept for the child OPML node
                    $childConceptId = New-CxlId
                    $childConceptLabel = $ChildNode.text
                    $childConcept = $CxlDocument.CreateElement('concept')
                    $childConcept.SetAttribute('id', $childConceptId)
                    $childConcept.SetAttribute('label', $childConceptLabel)
                    $CxlConceptList.AppendChild($childConcept)

                    # Calculate position for this concept
                    $conceptX = 100 + ($Level * $levelOffsetX)
                    $conceptY = 100 + ($childIndex * $levelOffsetY) + ($Level * 50)
                    
                    # Create concept appearance
                    $conceptAppearance = $CxlDocument.CreateElement('concept-appearance')
                    $conceptAppearance.SetAttribute('id', $childConceptId)
                    $conceptAppearance.SetAttribute('x', $conceptX.ToString())
                    $conceptAppearance.SetAttribute('y', $conceptY.ToString())
                    $conceptAppearance.SetAttribute('width', ([Math]::Max(60, $childConceptLabel.Length * 8)).ToString())
                    $conceptAppearance.SetAttribute('height', '25')
                    $CxlConceptAppearanceList.AppendChild($conceptAppearance)

                    # Create the linking phrase between the parent and child concepts
                    $linkingPhraseId = New-CxlId
                    $linkingPhrase = $CxlDocument.CreateElement('linking-phrase')
                    $linkingPhrase.SetAttribute('id', $linkingPhraseId)
                    $linkingPhrase.SetAttribute('label', $LinkingPhrase)
                    $CxlLinkingPhraseList.AppendChild($linkingPhrase)

                    # Calculate position for linking phrase (between parent and child)
                    $linkingPhraseX = $conceptX - 100
                    $linkingPhraseY = $conceptY - 20
                    
                    # Create linking phrase appearance
                    $linkingPhraseAppearance = $CxlDocument.CreateElement('linking-phrase-appearance')
                    $linkingPhraseAppearance.SetAttribute('id', $linkingPhraseId)
                    $linkingPhraseAppearance.SetAttribute('x', $linkingPhraseX.ToString())
                    $linkingPhraseAppearance.SetAttribute('y', $linkingPhraseY.ToString())
                    $linkingPhraseAppearance.SetAttribute('width', ([Math]::Max(40, $LinkingPhrase.Length * 6)).ToString())
                    $linkingPhraseAppearance.SetAttribute('height', '16')
                    $CxlLinkingPhraseAppearanceList.AppendChild($linkingPhraseAppearance)

                    # Create the first connection: parent concept to linking phrase
                    $connection1Id = New-CxlId
                    $connection1 = $CxlDocument.CreateElement('connection')
                    $connection1.SetAttribute('id', $connection1Id)
                    $connection1.SetAttribute('from-id', $ParentConceptId)
                    $connection1.SetAttribute('to-id', $linkingPhraseId)
                    $CxlConnectionList.AppendChild($connection1)

                    # Create connection appearance for first connection
                    $connectionAppearance1 = $CxlDocument.CreateElement('connection-appearance')
                    $connectionAppearance1.SetAttribute('id', $connection1Id)
                    $connectionAppearance1.SetAttribute('from-pos', 'center')
                    $connectionAppearance1.SetAttribute('to-pos', 'center')
                    $CxlConnectionAppearanceList.AppendChild($connectionAppearance1)

                    # Create the second connection: linking phrase to child concept
                    $connection2Id = New-CxlId
                    $connection2 = $CxlDocument.CreateElement('connection')
                    $connection2.SetAttribute('id', $connection2Id)
                    $connection2.SetAttribute('from-id', $linkingPhraseId)
                    $connection2.SetAttribute('to-id', $childConceptId)
                    $CxlConnectionList.AppendChild($connection2)

                    # Create connection appearance for second connection
                    $connectionAppearance2 = $CxlDocument.CreateElement('connection-appearance')
                    $connectionAppearance2.SetAttribute('id', $connection2Id)
                    $connectionAppearance2.SetAttribute('from-pos', 'center')
                    $connectionAppearance2.SetAttribute('to-pos', 'center')
                    $CxlConnectionAppearanceList.AppendChild($connectionAppearance2)

                    # Recursively call the function for the child node
                    Process-OpmlOutline -OpmlNode $ChildNode -ParentConceptId $childConceptId -Level ($Level + 1)
                    
                    $childIndex++
                }
            }
        }
    }

    # Function to create the default style sheet
    function Add-DefaultStyleSheet {
        $styleSheet = $CxlDocument.CreateElement('style-sheet')
        $styleSheet.SetAttribute('id', '_Default_')
        
        # Map style
        $mapStyle = $CxlDocument.CreateElement('map-style')
        $mapStyle.SetAttribute('background-color', '255,255,255,0')
        $styleSheet.AppendChild($mapStyle)
        
        # Concept style
        $conceptStyle = $CxlDocument.CreateElement('concept-style')
        $conceptStyle.SetAttribute('font-name', 'Verdana')
        $conceptStyle.SetAttribute('font-size', '12')
        $conceptStyle.SetAttribute('font-style', 'plain')
        $conceptStyle.SetAttribute('font-color', '0,0,0,255')
        $conceptStyle.SetAttribute('text-margin', '4')
        $conceptStyle.SetAttribute('background-color', '237,244,246,255')
        $conceptStyle.SetAttribute('background-image-style', 'full')
        $conceptStyle.SetAttribute('border-color', '0,0,0,255')
        $conceptStyle.SetAttribute('border-style', 'solid')
        $conceptStyle.SetAttribute('border-thickness', '1')
        $conceptStyle.SetAttribute('border-shape', 'rounded-rectangle')
        $conceptStyle.SetAttribute('border-shape-rrarc', '15.0')
        $conceptStyle.SetAttribute('text-alignment', 'center')
        $conceptStyle.SetAttribute('shadow-color', 'none')
        $conceptStyle.SetAttribute('min-width', '-1')
        $conceptStyle.SetAttribute('min-height', '-1')
        $conceptStyle.SetAttribute('max-width', '-1.0')
        $styleSheet.AppendChild($conceptStyle)
        
        # Linking phrase style
        $linkingPhraseStyle = $CxlDocument.CreateElement('linking-phrase-style')
        $linkingPhraseStyle.SetAttribute('font-name', 'Verdana')
        $linkingPhraseStyle.SetAttribute('font-size', '12')
        $linkingPhraseStyle.SetAttribute('font-style', 'plain')
        $linkingPhraseStyle.SetAttribute('font-color', '0,0,0,255')
        $linkingPhraseStyle.SetAttribute('text-margin', '1')
        $linkingPhraseStyle.SetAttribute('background-color', '0,0,255,0')
        $linkingPhraseStyle.SetAttribute('background-image-style', 'full')
        $linkingPhraseStyle.SetAttribute('border-color', '0,0,0,0')
        $linkingPhraseStyle.SetAttribute('border-style', 'solid')
        $linkingPhraseStyle.SetAttribute('border-thickness', '1')
        $linkingPhraseStyle.SetAttribute('border-shape', 'rectangle')
        $linkingPhraseStyle.SetAttribute('border-shape-rrarc', '15.0')
        $linkingPhraseStyle.SetAttribute('text-alignment', 'center')
        $linkingPhraseStyle.SetAttribute('shadow-color', 'none')
        $styleSheet.AppendChild($linkingPhraseStyle)
        
        # Connection style
        $connectionStyle = $CxlDocument.CreateElement('connection-style')
        $connectionStyle.SetAttribute('color', '0,0,0,255')
        $connectionStyle.SetAttribute('style', 'solid')
        $connectionStyle.SetAttribute('thickness', '1')
        $connectionStyle.SetAttribute('type', 'straight')
        $connectionStyle.SetAttribute('arrowhead', 'if-to-concept-and-slopes-up')
        $styleSheet.AppendChild($connectionStyle)
        
        # Resource style
        $resourceStyle = $CxlDocument.CreateElement('resource-style')
        $resourceStyle.SetAttribute('font-name', 'SanSerif')
        $resourceStyle.SetAttribute('font-size', '12')
        $resourceStyle.SetAttribute('font-style', 'plain')
        $resourceStyle.SetAttribute('font-color', '0,0,0,255')
        $resourceStyle.SetAttribute('background-color', '192,192,192,255')
        $styleSheet.AppendChild($resourceStyle)
        
        $CxlStyleSheetList.AppendChild($styleSheet)
    }

    # Function to add metadata
    function Add-Metadata {
        $resMeta = $CxlDocument.CreateElement('res-meta')
        
        # Title
        $title = $CxlDocument.CreateElement('title', 'http://purl.org/dc/elements/1.1/')
        $titleText = $opmlXml.opml.head.title
        if (-not $titleText) { $titleText = "Converted from OPML" }
        $title.InnerText = $titleText
        $resMeta.AppendChild($title)
        
        # Language
        $language = $CxlDocument.CreateElement('language', 'http://purl.org/dc/elements/1.1/')
        $language.InnerText = 'en'
        $resMeta.AppendChild($language)
        
        # Format
        $format = $CxlDocument.CreateElement('format', 'http://purl.org/dc/elements/1.1/')
        $format.InnerText = 'x-cmap/x-storable'
        $resMeta.AppendChild($format)
        
        # Publisher
        $publisher = $CxlDocument.CreateElement('publisher', 'http://purl.org/dc/elements/1.1/')
        $publisher.InnerText = 'PowerShell OPML to CXL Converter'
        $resMeta.AppendChild($publisher)
        
        $cmapRoot.AppendChild($resMeta)
    }

    # --- Main Script Body ---

    Write-Host "Starting conversion from OPML to CXL..."

    # Validate source file path
    $resolvedSourcePath = Resolve-Path -Path $SourcePath -ErrorAction Stop
    Write-Host "Found source file: $resolvedSourcePath"

    # Define destination path if not provided
    if (-not $DestinationPath) {
        $DestinationPath = [System.IO.Path]::ChangeExtension($resolvedSourcePath.Path, '.cxl')
    }
    Write-Host "Destination file will be: $DestinationPath"

    # Load the OPML file into a PowerShell XML object
    try {
        [xml]$opmlXml = Get-Content -Path $resolvedSourcePath.Path -Raw
    }
    catch {
        Write-Error "Failed to load OPML file. Ensure it is a valid XML document."
        return
    }

    # Initialize the new CXL XmlDocument object
    $CxlDocument = New-Object System.Xml.XmlDocument
    $declaration = $CxlDocument.CreateXmlDeclaration('1.0', 'UTF-8', $null)
    $CxlDocument.AppendChild($declaration)

    # Create the root <cmap> element and its namespaces
    $cmapRoot = $CxlDocument.CreateElement('cmap', 'http://cmap.ihmc.us/xml/cmap/')
    $cmapRoot.SetAttribute('xmlns:dc', 'http://purl.org/dc/elements/1.1/')
    $cmapRoot.SetAttribute('xmlns:dcterms', 'http://purl.org/dc/terms/')
    $cmapRoot.SetAttribute('xmlns:vcard', 'http://www.w3.org/2001/vcard-rdf/3.0#')
    $CxlDocument.AppendChild($cmapRoot)

    # Add metadata section
    Add-Metadata

    # Create the <map> container element
    $mapElement = $CxlDocument.CreateElement('map')
    $mapElement.SetAttribute('width', '800')
    $mapElement.SetAttribute('height', '600')
    $cmapRoot.AppendChild($mapElement)

    # Create the concept, linking phrase, and connection lists
    $CxlConceptList = $CxlDocument.CreateElement('concept-list')
    $CxlLinkingPhraseList = $CxlDocument.CreateElement('linking-phrase-list')
    $CxlConnectionList = $CxlDocument.CreateElement('connection-list')
    $CxlConceptAppearanceList = $CxlDocument.CreateElement('concept-appearance-list')
    $CxlLinkingPhraseAppearanceList = $CxlDocument.CreateElement('linking-phrase-appearance-list')
    $CxlConnectionAppearanceList = $CxlDocument.CreateElement('connection-appearance-list')
    $CxlStyleSheetList = $CxlDocument.CreateElement('style-sheet-list')

    $mapElement.AppendChild($CxlConceptList)
    $mapElement.AppendChild($CxlLinkingPhraseList)
    $mapElement.AppendChild($CxlConnectionList)
    $mapElement.AppendChild($CxlConceptAppearanceList)
    $mapElement.AppendChild($CxlLinkingPhraseAppearanceList)
    $mapElement.AppendChild($CxlConnectionAppearanceList)
    $mapElement.AppendChild($CxlStyleSheetList)

    # Add default style sheet
    Add-DefaultStyleSheet

    # Process the root of the OPML document's body
    # The OPML head is intentionally skipped as it contains no mapable content.
    $opmlBody = $opmlXml.opml.body
    if ($opmlBody) {
        # Create a "virtual" root concept to link all top-level OPML outlines to.
        # This is required for a valid CXL structure where all concepts are connected.
        $rootConceptId = New-CxlId
        $rootConceptLabel = $opmlXml.opml.head.title
        if (-not $rootConceptLabel) {
            $rootConceptLabel = "Outline Root"
        }
        $rootConcept = $CxlDocument.CreateElement('concept')
        $rootConcept.SetAttribute('id', $rootConceptId)
        $rootConcept.SetAttribute('label', $rootConceptLabel)
        $CxlConceptList.AppendChild($rootConcept)

        # Create root concept appearance
        $rootConceptAppearance = $CxlDocument.CreateElement('concept-appearance')
        $rootConceptAppearance.SetAttribute('id', $rootConceptId)
        $rootConceptAppearance.SetAttribute('x', '50')
        $rootConceptAppearance.SetAttribute('y', '50')
        $rootConceptAppearance.SetAttribute('width', ([Math]::Max(80, $rootConceptLabel.Length * 8)).ToString())
        $rootConceptAppearance.SetAttribute('height', '30')
        $CxlConceptAppearanceList.AppendChild($rootConceptAppearance)

        # Iterate through all top-level outlines and begin the recursive process
        foreach ($outline in $opmlBody.outline) {
            Process-OpmlOutline -OpmlNode $outline -ParentConceptId $rootConceptId -Level 1
        }
    }
    
    # Save the CXL document
    try {
        $CxlDocument.Save($DestinationPath)
        Write-Host "Successfully converted and saved CXL file to: $DestinationPath"
    }
    catch {
        Write-Error "Failed to save CXL file. Check write permissions."
    }
}

# Call the function with the provided parameters
Convert-OpmlToCxl @args