
**Comparing methods to describe treatment persistence: A use case of beta-blocker adherence after acute myocardial infarction**

Elin Rowlands<sup>1</sup>, Cecilia Campanile<sup>1</sup>, Danielle Newby<sup>1</sup>, Anna Saura-Lazaro<sup>1</sup>, Edward Burn<sup>1</sup>, Daniel Prieto-Alhambra<sup>1</sup>, Martí Català<sup>1,*</sup>

<sup>1</sup> Health Data Sciences Section, Nuffield Department of Orthopaedics, Rheumatology and Musculoskeletal Sciences, University of Oxford, Oxford, United Kingdom

<sup>*</sup> Corresponding author: [marti.catalasabate@ndorms.ox.ac.uk](mailto:marti.catalasabate@ndorms.ox.ac.uk)

#### Abstract

##### Background

##### Methods

##### Results

##### Conclusion

#### App structure

The Shiny app is organised into three main panels:

- **Databases** describes the data sources used in this study:

   - *Data Source Description*: details of each data source.
   - *Snapshot*: metadata about each data snapshot, including the number of individuals, data extraction date, and vocabulary version.
   - *Observation Period Summary*: a summary of the observation periods.
   
- **Characterisation** describes the cohorts used in this study:

   - *Code Use*: a breakdown of how the codelists were used to create the cohorts of interest.
   - *Cohort Count*: counts of the study cohorts.
   - *Cohort Attrition*: attrition within the study cohorts.
   - *Cohort Characteristics*: demographic characteristics of the study cohorts.
   
- **Discontinuation** presents the different methods used to analyse treatment discontinuation:

   - *Single Survival Estimates*: estimates from a standard survival analysis.
   - *Competing Survival Estimates*: estimates from a competing-risk analysis.
   - *Proportion of Patients Covered*: estimates based on the proportion of patients covered.
   - *Multistate Analysis*: estimates from a multistate analysis.
   - *Compare*: a comparison of results across the different methods.

<center>

![](ohdsi_logo.svg){width=100px}
![](hds_logo.svg){width=100px}

</center>
