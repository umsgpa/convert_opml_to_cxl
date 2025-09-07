# OPML to CXL Converter

A PowerShell script that converts hierarchical OPML (Outline Processor Markup Language) files into CXL concept maps compatible with CMapTools.

> Want to know the story behind this tool? Read on to discover why it was developed: [When AI Becomes the Curator of Corporate Knowledge: From Transcription to "Vibe Coding"](https://www.linkedin.com/pulse/when-ai-becomes-curator-corporate-knowledge-from-vibe-pancani-ccfaf/)

## Table of Contents

- [Overview](#overview)
- [What is OPML?](#what-is-opml)
- [What is CXL?](#what-is-cxl)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Technical Details](#technical-details)
- [Limitations](#limitations)
- [Contributing](#contributing)
- [License](#license)

## Overview

This script bridges the gap between outline-based thinking tools and visual concept mapping by converting OPML files into CMapTools-compatible CXL format. It transforms hierarchical outline structures into connected concept maps with proper linking phrases and visual layout.

## What is OPML?

**OPML (Outline Processor Markup Language)** is an XML format designed for exchanging outline-structured information between different applications. Originally developed by Dave Winer, OPML has become a standard for sharing hierarchical data.

### OPML Structure

OPML files consist of two main sections:

1. **Head Section**: Contains metadata about the outline
   - Title of the document
   - Creation/modification dates
   - Owner information
   - Expansion states

2. **Body Section**: Contains the actual outline structure
   - Nested `<outline>` elements
   - Each outline has a `text` attribute containing the content
   - Hierarchical relationships through XML nesting

### Example OPML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>My Project Plan</title>
    <dateCreated>Mon, 01 Jan 2024 10:00:00 GMT</dateCreated>
  </head>
  <body>
    <outline text="Software Development">
      <outline text="Planning Phase">
        <outline text="Requirements Gathering"/>
        <outline text="Architecture Design"/>
      </outline>
      <outline text="Development Phase">
        <outline text="Frontend Development"/>
        <outline text="Backend Development"/>
      </outline>
    </outline>
  </body>
</opml>
```

### Common OPML Use Cases

- **Mind Mapping Tools**: Exporting hierarchical thoughts and ideas
- **RSS/Feed Aggregators**: Organizing subscription lists
- **Project Planning**: Structuring tasks and deliverables
- **Knowledge Management**: Organizing research and notes
- **Presentation Outlines**: Structuring speech and presentation content

## What is CXL?

**CXL (Concept Map XML)** is the native file format used by CMapTools, a popular concept mapping software developed by the Institute for Human and Machine Cognition (IHMC). CXL files store concept maps as structured XML documents.

### CXL Structure

CXL files represent concept maps using three primary elements:

1. **Concepts**: The main ideas or topics in the map
   - Represented as nodes with labels
   - Have unique identifiers and visual properties

2. **Linking Phrases**: Descriptive text that explains relationships
   - Connect concepts to form meaningful statements
   - Examples: "is a type of", "leads to", "consists of"

3. **Connections**: Directional links between concepts and linking phrases
   - Form propositions: Concept → Linking Phrase → Concept
   - Create the semantic network structure

### CXL Document Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<cmap xmlns="http://cmap.ihmc.us/xml/cmap/">
  <res-meta>
    <!-- Metadata about the concept map -->
  </res-meta>
  <map width="800" height="600">
    <concept-list>
      <!-- All concepts in the map -->
    </concept-list>
    <linking-phrase-list>
      <!-- All linking phrases -->
    </linking-phrase-list>
    <connection-list>
      <!-- All connections between elements -->
    </connection-list>
    <concept-appearance-list>
      <!-- Visual styling for concepts -->
    </concept-appearance-list>
    <!-- Additional appearance and style elements -->
  </map>
</cmap>
```

### Benefits of Concept Maps

- **Visual Learning**: Represent knowledge graphically
- **Relationship Mapping**: Show explicit connections between ideas
- **Knowledge Assessment**: Evaluate understanding of topics
- **Collaborative Learning**: Share and build upon conceptual understanding
- **Research Organization**: Structure complex information domains

## Features

-  **Complete OPML Parsing**: Handles nested outline structures
-  **Automatic Layout Generation**: Creates visually organized concept maps
-  **Customizable Linking Phrases**: Define relationship descriptions
-  **CMapTools Compatibility**: Generates valid CXL files
-  **Metadata Preservation**: Transfers OPML title and information
-  **Visual Styling**: Includes default CMapTools-compatible styles
-  **Unique ID Generation**: Ensures proper element identification

## Requirements

- PowerShell 5.1 or higher
- Windows, macOS, or Linux with PowerShell Core
- Read access to source OPML files
- Write access to destination directory

## Installation

1. **Download the script**:
   ```bash
   git clone https://github.com/yourusername/opml-to-cxl-converter.git
   cd opml-to-cxl-converter
   ```

2. **Make executable** (if needed):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## Usage

### Basic Syntax

```powershell
.\Convert-OpmlToCxl.ps1 -SourcePath "path\to\file.opml"
```

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `SourcePath` | String | Yes | - | Full path to the source OPML file |
| `DestinationPath` | String | No | Auto-generated | Full path for output CXL file |
| `LinkingPhrase` | String | No | "is a part of" | Text for relationship descriptions |

### Examples

#### Basic Conversion
```powershell
.\Convert-OpmlToCxl.ps1 -SourcePath "C:\Documents\outline.opml"
```

#### Custom Destination
```powershell
.\Convert-OpmlToCxl.ps1 -SourcePath "outline.opml" -DestinationPath "concept-map.cxl"
```

#### Custom Linking Phrase
```powershell
.\Convert-OpmlToCxl.ps1 -SourcePath "outline.opml" -LinkingPhrase "contains"
```

## Examples

### Input OPML File
```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>Learning Management System</title>
  </head>
  <body>
    <outline text="User Management">
      <outline text="Students"/>
      <outline text="Instructors"/>
      <outline text="Administrators"/>
    </outline>
    <outline text="Course Management">
      <outline text="Course Creation"/>
      <outline text="Content Management"/>
    </outline>
  </body>
</opml>
```

### Generated Concept Map Structure
The script creates a concept map where:
- "Learning Management System" becomes the root concept
- "User Management" and "Course Management" are connected via "is a part of"
- Sub-items like "Students", "Instructors" connect to their parent concepts
- Visual layout automatically positions elements for readability

## Technical Details

### Conversion Process

1. **OPML Parsing**: Loads and validates the XML structure
2. **Root Concept Creation**: Establishes a central concept from the OPML title
3. **Recursive Processing**: Traverses the outline hierarchy
4. **Relationship Building**: Creates concept-linking phrase-concept triads
5. **Layout Calculation**: Positions elements using algorithmic spacing
6. **Style Application**: Applies default CMapTools styling
7. **XML Generation**: Outputs valid CXL format

### Visual Layout Algorithm

- **Hierarchical Positioning**: Lower levels are offset horizontally
- **Vertical Spacing**: Siblings are separated vertically
- **Dynamic Sizing**: Element dimensions adjust to content length
- **Connection Routing**: Links are positioned between element centers

### Generated Elements

For each OPML outline item, the script creates:
- A **concept** with unique ID and label
- A **linking phrase** connecting to parent
- Two **connections** (parent→phrase, phrase→concept)
- **Appearance elements** for visual styling

## Limitations

- **One-way Conversion**: Does not convert CXL back to OPML
- **Simple Relationships**: All relationships use the same linking phrase
- **Linear Hierarchy**: Cannot represent cross-references or cycles
- **Basic Styling**: Uses default CMapTools appearance only
- **Text Only**: Does not preserve OPML attributes beyond text content

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with various OPML files
5. Submit a pull request

### Testing

Test the script with various OPML sources:
- Mind mapping exports (FreeMind, XMind)
- Outlining tools (Workflowy, Dynalist)
- RSS feed lists
- Project planning hierarchies

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- CMapTools by IHMC for the CXL format specification
- Dave Winer for creating the OPML standard
- The PowerShell community for XML processing guidance

---

**Need Help?** Open an issue on GitHub or check the [CMapTools documentation](http://cmap.ihmc.us/) for concept mapping best practices.