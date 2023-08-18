# ADF2023GP-tweets-6

This is Tweets6's repository for the group assignment of the course Analyzing Digital Footprings.

In the `data_collection` folder you can find the files related to the collection of data and the collected data:

-   `Aviation_collection_data.R`: file used for data collection from the API
-   `Aviation_process_data.R`: file to process the raw datafile
-   `raw_dataset.Rdata`: include the raw data from four airlines: RyanAir, United, Qatar, and Emirates
-   `raw_dataset_TKA.Rdata`: include the raw data from the airline Turkish Airlines
-   `raw_dataset_finalEJ.Rdata`: include the raw data from the airline EasyJet
-   `processed_data.Rdata`: includes all processed data from RyanAir, United, Qatar, and Emirates
-   `processed_data_TKA.Rdata`: includes processed data from Turkish Airlines
-   `processed_Data_EJ.Rdata`: includes processed data from EasyJet

We did not collect all the data for all of the airlines at once (since it was unsure how many tweets we would get with each pull), but rather started with the 4 airlines listed above and then collected additional airlines from there. The `Aviation_collection_data.R` and `Aviation_process_data.R` were used for all the airlines only with changed parameters each time.

In the `data_analysis` folder you can find all the files related to the analysis and its results:

-   `analysis.R` stores the actual code used to run the analyses and store the results and visualizations

-   `visualizations\` contains all the generated visualizations from our analysis, with charts showcasing the interaction effects of anthropomorphism on the different engagement metrics and bar charts showing the difference in averages across the anthropomorphic and non-anthropomorphic groups

-   `linear_models.Rdata` contains the results of all the linear regression models run and `results.csv` stores the results of our t-tests

The `sections` folder holds the Rmd's for each of our sections, with the exception of the Introduction and References, which are included in the final report file.

The `Final_report.Rmd` file knits our entire report together.

**Important Note**: The `Final_report.Rmd` file does not run any code for analysis, it only loads in the processed data and the final results (from the `data_analysis` folder), which are an output of the `analysis` file. If you want to check the reproducibility of our results, please run the `analysis.R` file first to re-generate all the results based on the collected data and then knit the `Final_report.Rmd`.
