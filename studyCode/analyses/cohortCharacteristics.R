
logMessage("Get counts of cohorts of interest")
result$counts <- summariseCohortCounts(cohort = cdm$study_cohorts)

logMessage("Get attrition of cohorts of interest")
result$attrition <- summariseCohortAttrition(cohort = cdm$study_cohorts)

logMessage("Characterise study cohorts")
result$characteristics <- summariseCharacteristics(cohort = cdm$study_cohorts)
