# Heart Health EDA in R by Justin Carlou Lim

This project explores and analyzes the Heart Health Dataset found at the following:
https://www.kaggle.com/datasets/mahad049/heart-health-stats-dataset

Main Question: How does bmi affect risk of hypertension?
* What about by gender?
* What about smoking?

### Table of Contents ###
  1. Data Cleaning
  2. BMI and Hypertension
  3. Gender, Smoking and Hypertension

## Data cleaning
First, I reworked the dataset so it'd be more usable for my analyses. 
* Changed Smoker and Gender column data from character to factor.
* Separate character variable "Blood.Pressure.mmHg." to systolic and diastolic blood pressure. Then, convert to numeric.
* Separate entries by blood pressure categories as described in American Heart Association chart (attached).
* Calculate BMI using Height (converted to m) and Weight (kg).
* Create separate datasets for Smoker/Nonsmoker and Male/Female.

The cleaning process is documented in the code. 
