# Report Treatment Discontinuation

This project contains the code for the Shiny App and Report and it is organised as follows:
- The `report.qmd` file contains the source code for the Report.
- The `template.docx` file contains the template for the Report where classes such as 'Caption' are defined.
- The files `global.R`, `ui.R` and `server.R` contain the source code for the Shiny App.
- The `background.md` contains the background tab source text of the Shiny App.
- The `functions.R` file contains useful functions used in the data processing and visualisation.
- The `_brand.yml` document is used to control the default appearance of plots and tables.
- The `rawData` folder contains the raw data in csv files and the `preprocess.R` script that preprocess the data adding the output to the `data` folder.
- The `data` folder contains the preprocesed data that is used in Shiny App and Report.
- The `.rscignore` is used to tell `rsconnect` to ignore the `rawData` folder to be ignored when deployed.
