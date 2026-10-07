
**Comparing methods to describe treatment persistence. Use case: beta blockers adherence after Acute Myocardial Infarction**

Elin Rowlands^1, Cecilia Campanile^1, Danielle Newby^1, Anna Saura-Lazaro^1, Edward Burn^1, Daniel Prieto-Alhambra^1, Martí Català^1*

1 Health Data Sciences Section, Nuffield Department of Orthopedics, Reumathology and Muscoloskeletal Sciences, University of Oxford, Oxford, United Kingdom

*Corresponding: [marti.catalasabate@ndorms.ox.ac.uk]([mailto: marti.catalasabate@ndorms.ox.ac.uk])

#### Abstract

##### Background

##### Methods

##### Results

##### Conclusion

#### Shiny structure

The shiny is structured in 4 main panels:

- **Databases** that describes the data sources used in this study:

   - *Database Description*: description of the Data Source.
   - *Snapshot*: metadata extraction about the datacut, contains information such as, number of individuals, date of data extraction or vocabulary version used.
   - *Observation Period Summary*: description of the observation periods.
   
- **Characterisation** that describes the cohorts used in this study:

   - *Code Use*: breakdown of the different use of the codelist that were used to create the cohorts of interest.
   - *Cohort Count*: counts of the study cohorts.
   - *Cohort Attrition*: attrition of the study cohorts.
   - *Cohort Characteristics*: demographics characterisation of the study cohorts.
   
- **Discontinuation** that shows the different methods to analyse discontinuation:

   - *Single Survival Estimates*: discontinuation analysis as a single survival analysis.
   - *Competing Survival Estimates*: discontinuation analysis as a competing risk analysis.
   - *Proportion of Patients Covered*: discontinuation analysis as a proportion of patients covered.
   - *Multistate Analysis*: discontinuation analysis as a multi state analysis.
   - *Compare*: compare the different methods between them.

![](ohdsi_logo.svg){width=100px}
![](hds_logo.svg){width=100px}

