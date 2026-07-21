# LSMS Gender Dynamics

This README describes the directory structure and code used in the project examining the relationship between the gender of the plot owner and manager and plot productivity, plot sales, and household food security.

This README was last updated on 4 September 2025. 

 ## Index

 - [Project Team](#project-team)
 - [Data cleaning](#data-cleaning)
 - [Pre-requisites](#pre-requisites)
 - [Folder structure](#folder-structure)

## Project team

Contributors:
* Jeffrey D. Michler [jdmichler@arizona.edu] (Conceptualizaiton, Supervision, Visualization, Writing)
* Anna Josephson [aljosephson@arizona.edu] (Conceptualizaiton, Supervision, Visualization, Writing)
* George Hyland (Data curation, Visualization)
* Joss Tijerina (Data curation)
* Nelson Semidey (Data curation)

## Data cleaning

The code in this repository is primarily for replicating the cleaning of the household LSMS-ISA data. This requires downloading this repo and the household data from the World Bank webiste. The `projectdo.do` should then replicate the data cleaning process.

## Pre-requisites

### Stata req's

  * The data processing and analysis requires a number of user-written
    Stata programs:
    1. `blindschemes`
    2. `unique`
    3. `mdesc`
    4. `estout`
    5. `palettes`
    6. `distinct`
    7. `winsor2`
    8. `catplot`
    9. `colrspace`
    10. `coefplot`

## Folder structure

### Repo folder structure

The structure of the code in this repository is designed to mimic the data folder structure:<br>

```stata
lsms-gender
├──01-refined            /* inputs raw data, cleans it, outputs to refined folders */      
│  └──country            /* one dir for each country */
│     └──wave            /* one dir for each wave */
├──02-merged             /* inputs refined data, merges it, and outputs to merged folders */
│  └──country            /* one dir for each country */
├──03-regressions        /* inputs merged data, runs regressions, outputs to analysis folder */
└──04-analysis           /* inputs results data and generates tables and figures */
     ├──tables
     └──figures
```

### Data folder structure

For the household cleaning code to run, the public use microdata must be downloaded from the [World Bank Microdata Library][2]. Furthermore, the data needs to be placed in the following folder structure:<br>

```stata
weather_and_agriculture
├──raw-lsms-data         /* folder for raw LSMS-ISA data downloaded from WB */  
│  └──country            /* one dir for each country */
│     ├──wave            /* one dir for each wave */
│     └──logs
├──lsms-base             /* folder containing replication data for Wollburg et al. (2024) */  
│  └──Final data       
└──lsms-gender-data      /* folder for refined data used on this project */
   ├──01-refined_data    /* holds refined data coming from raw data */
   │  └──country         /* one dir for each country */
   │     ├──wave         /* one dir for each wave */
   │     └──logs
   ├──02-merged_data     /* holds merged data coming from refined */
   │  ├──country         /* one dir for each country */
   │  └──logs
   ├──03-regression_data /* holds regression ready data coming from merged */
   │  └──logs
   └──04-results_data    /* holds results coming from regression data */
      ├──tables
      ├──figures
      └──logs
```

  [2]: https://www.worldbank.org/en/programs/lsms/initiatives/lsms-ISA
