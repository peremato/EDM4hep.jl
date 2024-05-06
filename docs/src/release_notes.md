
# Release Notes


## 0.4.0
### New Functionality
- Added function `RootIO.create_getter(reader::Reader, bname::String; selection=nothing)` to create a getter function for a specific branch.
  The optional argument allows to select leaves to be read.
- The overall performance is highly improved (factor 3 with respect previous version)

## 0.3.1
### Bug Fixes
- Legacy podio test fixed

## 0.3.0
### New Functionality
- Optimisations by explicitly generation of StructArrays
- Support for multi-files
- Support for multi-threading
- Support for RNTuple RC2
- Added analysis module ROOT.Analysis (mini-framework for MT analysis)

## 0.2.0
### New Functionality
- Added support for older versions of PODIO file formats
- Added analysis example for FCCAnalysis

## 0.1.0
- First release. It provides the basic functionality to create in memory an event model and be able to read from a ROOT file (supporting both TTree and RNTuple formats).
