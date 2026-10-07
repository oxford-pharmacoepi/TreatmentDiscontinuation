**Comparing methods to describe treatment persistence after acute myocardial infarction: a beta-blocker use case**

Elin Rowlands<sup>1</sup>, Cecilia Campanile<sup>1</sup>, Danielle Newby<sup>1</sup>, Anna Saura-Lazaro<sup>1</sup>, Edward Burn<sup>1</sup>, Daniel Prieto-Alhambra<sup>1</sup>, Martí Català<sup>1,\*</sup>

<sup>1</sup> Health Data Sciences Section, Nuffield Department of Orthopaedics, Rheumatology and Musculoskeletal Sciences, University of Oxford, Oxford, United Kingdom

<sup>\*</sup> Corresponding author: [marti.catalasabate\@ndorms.ox.ac.uk](mailto:marti.catalasabate@ndorms.ox.ac.uk)

#### Abstract

##### Background

Treatment persistence can be described using methods that address different questions, particularly when treatment may restart or death precludes discontinuation. We compared four methods for describing beta-blocker persistence after acute myocardial infarction (AMI).

##### Methods

We conducted a retrospective cohort study using CPRD GOLD data mapped to the Observational Medical Outcomes Partnership Common Data Model. Individuals with a first recorded AMI between 1987 and 2025 who initiated a beta-blocker within 28 days were followed for up to two years. We compared: (1) Kaplan–Meier analysis of time to the first treatment break; (2) competing-risk analysis with death as a competing event; (3) the proportion covered among individuals under observation, allowing treatment re-entry; and (4) a multistate model with treated, untreated, and dead states. Analyses were repeated using allowable gaps of 0 to 120 days in 10-day increments and were stratified by heart failure recorded on or before the AMI date.

##### Results

Among 209,765 individuals with AMI, 62,412 initiated a beta-blocker within 28 days. With no allowable gap, two-year estimates were 0.5% for continuous persistence by Kaplan–Meier analysis, 1.3% for freedom from discontinuation in the competing-risk analysis, 74.4% for current treatment coverage, and 69.3% for the multistate probability of being treated. With a 90-day allowable gap, the corresponding estimates were 73.4%, 74.2%, 83.0%, and 75.1%, respectively.

Of the included individuals, 2,671 (4.3%) had prior heart failure. In this subgroup, two-year estimates using a 90-day allowable gap were 71.7%, 73.8%, 85.1%, and 67.5%, respectively. The two-year multistate probability of death was 18.2% among individuals with prior heart failure and 6.2% among those without prior heart failure.

##### Conclusions

Persistence methods are not interchangeable: first-break analyses quantify uninterrupted treatment, whereas coverage and multistate approaches incorporate restarts, and competing-risk and multistate methods account for death. The method and allowable gap should be selected according to the clinical question and reported transparently. Sensitivity analyses across clinically plausible gap definitions are recommended.

#### App structure

The Shiny app is organised into three main panels:

-   **Databases** describes the data sources used in this study:

    -   *Data Source Description*: details of each data source.
    -   *Snapshot*: metadata about each data snapshot, including the number of individuals, data extraction date, and vocabulary version.
    -   *Observation Period Summary*: a summary of the observation periods.

-   **Characterisation** describes the cohorts used in this study:

    -   *Code Use*: a breakdown of how the codelists were used to create the cohorts of interest.
    -   *Cohort Count*: counts of the study cohorts.
    -   *Cohort Attrition*: attrition within the study cohorts.
    -   *Cohort Characteristics*: demographic characteristics of the study cohorts.

-   **Discontinuation** presents the different methods used to analyse treatment discontinuation:

    -   *Single Survival Estimates*: estimates from a standard survival analysis.
    -   *Competing Survival Estimates*: estimates from a competing-risk analysis.
    -   *Proportion of Patients Covered*: estimates based on the proportion of patients covered.
    -   *Multistate Analysis*: estimates from a multistate analysis.
    -   *Compare*: a comparison of results across the different methods.

<center>![](ohdsi_logo.svg){width="100px"} ![](hds_logo.svg){width="100px"}</center>
