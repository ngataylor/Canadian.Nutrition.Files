# Canadian.Nutrition.Files
Code for Assembling Mah Food Policy Lab Nutrition Files


# Common Script for the Combination and Transformation of CNF files

Nutrient Files can be found here:

https://food-nutrition.canada.ca/cnf-fce/index-eng.jsp

To begin, accumulate CNF files of interest based on 100 gram serving size and store in a single folder. Use the XLS to CSV javascript file included in the repo to facilitate use in R. 

Once folder with all csv files has been established, run the Nutrient File Grouping and Dataframe Creation.R file with the directory containing the csv files of interest. 

This will result in a single dataframe ready for export and use.

The dataframe will contain Food Name, CNF Food Code, Protein content in grams, Fat content in grams, Carbohydrate content in grams, Alcohol content, Energy content in Kilocalories and Kilojoules.

# Common Nutrients of Interest

To assess Sodium/Potassium ratio, or Sugar content specifically see the scripts developed for those molecules of interest. 
