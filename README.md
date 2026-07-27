# README
![DOI](https://img.shields.io/badge/DOI-TBD-4E5B9C?style=flat&logo=DOI&logoColor=white&labelColor=212842) 
![R](https://img.shields.io/badge/4.5-white?style=flat&logo=r&logoColor=white&labelColor=212842) 
![Quarto](https://img.shields.io/badge/Quarto-1.9.38-white?style=flat&logo=quarto&logoColor=white&labelColor=212842) 
![License](https://img.shields.io/badge/License-All_Rights_Reserved_until_published-white?style=flat&labelColor=212842) 

![Method](https://img.shields.io/badge/Method-Distance_Sampling-5C9EAD?style=flat&labelColor=212842) 
![Species](https://img.shields.io/badge/Species-Cetaceans-BF9ACA?style=flat&labelColor=212842) 


This repository contains the code, data, and analyses for my **Master's dissertation** at the **University of Gibraltar**. The project investigates the distribution and abundance of cetaceans within the British Gibraltar Territorial Waters (BGTW) using systematic distance sampling.

The original study was designed as a vessel-based survey. However, due to the unavailability of the research vessel, the methodology was adapted to a land-based distance sampling approach while maintaining the overall research objectives.


The repository documents the complete workflow. From survey design and field data collection to spatial analyses, statistical modelling, and visualisation and aims to provide a transparent and reproducible example of a distance sampling study.


## Repo content
```
== Supplemental chapters ------------------
├── chapters
│   ├── acknowledgements.qmd
│   ├── appendix.qmd
│   ├── comms.qmd
│   ├── definitions.qmd
│   ├── discussion.qmd
│   ├── intro.qmd
│   ├── methods.qmd
│   ├── packages.qmd
│   └── results.qmd

== Shapefiles of the survey area ------------------
├── data
│   ├── GTW_split_acc.gpkg
│   ├── GTW_split.gpkg
│   ├── GTW.shp
│   ├── GTW.shx
│   └── GTWcsv.csv

== Journal article chapters ------------------
├── journal_chapters
│   ├── j_acknowl.qmd
│   ├── j_discussion.qmd
│   ├── j_intro.qmd
│   ├── j_methods.qmd
│   └── j_results.qmd

== Typst templates ------------------
├── typst

== R Scripts (data cleaning) ------------------
├── Data Analysis.qmd
├── Data Visualisation.qmd
├── datacleaning.R
├── GIS.qmd
├── utils.R

== Survey design ------------------
├── Distance Sampling.Rmd
├── land_survey.R
├── Survey Setup.Rmd
├── Research_Project.Rproj
└── visualisation.qmd
```
Within [data](/data), all data especially a detailed shapefile of the British Gibraltar Territorial Waters and the Bay of Algeciras/Gibraltar can be found.

## Method
The study applies systematic distance sampling to estimate cetacean distribution and abundance within the BGTW. A regularly spaced zigzag survey design was initially developed to maximise survey coverage while minimising transit distance and off-effort time.

Following the transition to land-based surveys, the survey protocol was adapted to fixed observation stations around Gibraltar. Distance sampling methods were subsequently applied to estimate detection functions, density, and abundance from these observations.

Detailed descriptions of the methodology, survey area, and analytical workflow are available throughout this repository.

## Reproducibility
This repository is intended to provide a transparent and reproducible workflow for land-based cetacean distance sampling, including survey design, data processing, statistical analysis, and visualisation. Researchers and students are welcome to explore, adapt, and build upon the methods presented here.

---

<img width="150" height="150" alt="Logo" src="https://github.com/user-attachments/assets/c32aa531-7986-4e79-b2fd-6639272037cd" />

© 2026 Simon Gendrisch. All Rights Reserved
