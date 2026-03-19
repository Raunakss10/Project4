---
layout: default
title: Recipe Ratings Project
---

<div style="text-align: center; padding: 60px 20px; background: linear-gradient(135deg, #1e3c72, #2a5298); color: white; border-radius: 12px;">

<h1 style="font-size: 42px; margin-bottom: 10px;">
Do Healthy Recipes Get Lower Ratings?
</h1>

<p style="font-size: 18px; opacity: 0.9;">
A Data Science Investigation using Food.com Data
</p>

<a href="https://github.com/Raunakss10/Project4" 
style="display: inline-block; margin-top: 20px; padding: 10px 20px; background: white; color: #2a5298; border-radius: 6px; text-decoration: none; font-weight: bold;">
View on GitHub
</a>

</div>



# Do Healthy Recipes Get Lower Ratings?
### A Data Science Investigation of Recipe Tags, Nutrition, and User Preferences


---

## <span style="color:#2a5298;">Overview</span>

This project investigates whether recipes labeled as **healthy** tend to receive lower ratings than other recipes on Food.com. To answer this question, I combined recipe metadata with user interaction data, explored nutritional and structural recipe features, conducted a permutation test, and built predictive regression models for average recipe rating.

The project focuses on two main goals:

1. **Inference:** Determine whether healthy-tagged recipes are rated differently from non-healthy recipes.
2. **Prediction:** Predict a recipe’s average rating using structured recipe and nutrition-related features.

---

## Introduction

Food ratings are influenced by many factors beyond taste alone. Recipes that are marketed as *healthy* may be perceived as less indulgent, less flavorful, or more restrictive, which could affect how users rate them. At the same time, users may also value healthier meals, especially if they are efficient, practical, and nutritionally balanced.

This project investigates the following research question:

> **Do recipes tagged as healthy receive lower average ratings than other recipes?**

To answer this, I use two Food.com datasets:

- **RAW_recipes.csv** — recipe-level metadata such as cooking time, tags, ingredients, and nutrition
- **interactions.csv** — user-level reviews and ratings for recipes

I also build predictive models to determine how well recipe features can explain variation in ratings.

---

## Datasets

### 1. Recipes dataset
This dataset contains recipe-level metadata, including:

- `name` — recipe name  
- `id` — recipe ID  
- `minutes` — preparation time  
- `submitted` — submission date  
- `tags` — Food.com tags  
- `nutrition` — nutritional information  
- `n_steps` — number of steps  
- `ingredients` — recipe ingredients  
- `n_ingredients` — number of ingredients  

### 2. Interactions dataset
This dataset contains user interactions, including:

- `user_id` — user ID  
- `recipe_id` — recipe ID  
- `date` — review date  
- `rating` — user rating  
- `review` — review text  

---

## Data Cleaning and Preparation

To prepare the data for analysis, I performed the following steps:

- merged the recipes and interactions datasets using recipe IDs
- replaced ratings of `0` with `NaN`, since valid ratings are on a 1–5 scale
- converted `submitted` and `date` to datetime format
- computed an `average_rating` for each recipe
- expanded the `nutrition` column into separate numeric columns:
  - `calories`
  - `total_fat_PDV`
  - `sugar_PDV`
  - `sodium_PDV`
  - `protein_PDV`
  - `saturated_fat_PDV`
  - `carbs_PDV`
- created transformed variables such as:
  - `log_minutes`
  - `log_calories`

### Defining Healthy Recipes

To classify recipes as healthy, I used keyword matching on the `tags` column. A recipe was labeled as healthy if its tags included terms such as:

- `healthy`
- `low-fat`
- `low-carb`
- `low-calorie`
- `high-protein`
- `low-sugar`

This is a **platform-based definition** of healthy rather than a medical one. That is appropriate here because the goal is to measure how recipes *presented* as healthy are perceived by users.

---

## Exploratory Data Analysis

I first explored the distributions of key numeric variables such as calories and cooking time. Since both variables were strongly right-skewed, I used log transformations to make the distributions easier to interpret.

From the exploratory analysis:

- recipe calories are highly skewed, with many lower-calorie recipes and a long right tail
- cooking time is also right-skewed, with many short-to-moderate recipes and relatively few very long recipes
- healthy-tagged recipes form only a subset of the overall recipe population
- the difference in average rating between healthy and non-healthy recipes appears visually small

These observations suggested that any difference in ratings might exist, but is likely modest in magnitude.

---

## Hypothesis Testing

To test whether healthy-tagged recipes receive lower ratings, I performed a **one-sided permutation test**.

### Null Hypothesis
Healthy and non-healthy recipes come from the same distribution of average ratings, and any observed difference is due to chance.

### Alternative Hypothesis
Healthy recipes receive lower average ratings than non-healthy recipes.

### Test Statistic
\[
\text{mean average rating of healthy recipes} - \text{mean average rating of non-healthy recipes}
\]

A more negative value supports the alternative hypothesis.

### Result

The observed difference in average rating was slightly negative, indicating that healthy recipes were rated a bit lower on average. However, the p-value was approximately:

- **p ≈ 0.07**

Since this is greater than the standard significance level of 0.05, I **fail to reject the null hypothesis**.

### Interpretation

This means there is **not strong enough statistical evidence** to conclude that healthy-tagged recipes are rated lower. While the observed difference is in the expected direction, the effect is very small and could plausibly be due to chance.

---

## Framing a Prediction Problem

In addition to inference, I framed a supervised learning problem where the goal is to predict a recipe’s:

- **`average_rating`**

This is a **regression problem**, because the response variable is numeric and continuous.

### Why regression?
Average recipe ratings can take values such as 3.8, 4.2, or 4.75, so the task is to predict a number rather than assign a category.

### Evaluation Metric
I used **R²** as the primary metric.

R² measures how much of the variation in average recipe rating is explained by the model on unseen test data.

---

## Baseline Model

As a baseline, I used simple regression models with a small set of intuitive numeric features:

- `log_minutes`
- `n_steps`
- `n_ingredients`
- `log_calories`

This baseline model performed poorly, with an R² near zero. That result suggests that basic recipe structure alone does not explain much of the variation in average ratings.

---

## Final Model

To improve performance, I engineered richer features capturing recipe efficiency and nutritional composition, including:

- `fat_per_calorie`
- `protein_per_calorie`
- `sugar_per_calorie`
- `calories_per_step`
- `steps_per_min`
- `calories_per_ingredient`
- `ingredients_per_min`
- `log_minutes`
- `log_calories`
- `log_steps`

I then trained a **Random Forest Regressor**, which can capture nonlinear relationships between features and average rating.

### Final Model Performance

The final model achieved approximately:

- **Train R² = 0.424**
- **Test R² = 0.401**

This is a large improvement over the baseline and indicates that the model explains a meaningful portion of variation in average recipe ratings.

---

## Model Validation and Sanity Checks

To ensure the model’s performance was reliable, I performed multiple sanity checks.

### 1. Leakage Check
I removed potentially suspicious features such as `rating_count`. Even without that feature, the model still achieved:

- **R² ≈ 0.401**

This suggests the model performance is not driven by obvious leakage.

### 2. Train vs Test Performance
The training and test R² values are very close:

- Train R² = 0.424
- Test R² = 0.401

This indicates that the model is **not overfitting significantly** and generalizes well.

### 3. Baseline Comparison
A naive predictor that always predicts the mean rating produced an R² near zero, while the Random Forest performed much better. This confirms that the model is learning meaningful structure rather than relying on trivial prediction behavior.

---

## Feature Importance

The most important features in the final model were:

- `fat_per_calorie`
- `protein_per_calorie`
- `calories_per_step`
- `log_calories`
- `sugar_per_calorie`
- `steps_per_min`

### Interpretation

These results suggest that both **nutritional density** and **recipe efficiency** matter for user ratings. In particular:

- nutritional composition appears to play a large role in how users evaluate a recipe
- users may respond not just to “healthy” labeling, but to how balanced and efficient a recipe appears
- recipes that deliver more value relative to complexity may be rated more favorably

Importantly, these feature importance rankings are intuitive and consistent with real-world food preferences.

---

## Main Findings

The main findings of the project are:

- healthy-tagged recipes were rated slightly lower on average
- the rating difference was **not statistically significant** at the 5% level
- simple linear models explained almost none of the variation in ratings
- a Random Forest Regressor with engineered nutrition and complexity features substantially improved performance
- the final model achieved **test R² ≈ 0.40**
- nutritional ratios and efficiency-based features were the strongest predictors of rating

---

## Conclusion

In this project, I investigated whether recipes labeled as healthy receive lower ratings than other recipes. Using Food.com recipe and interaction data, I created a healthy-tag indicator, compared ratings with a permutation test, and built predictive models for average recipe rating.

The inferential result showed that healthy recipes were rated slightly lower on average, but the difference was not statistically significant. This means the data does not provide strong enough evidence to conclude that healthy labeling alone lowers user ratings.

On the predictive side, simple baseline models performed poorly, but a Random Forest Regressor with engineered nutrition and efficiency features explained a meaningful amount of variation in ratings. The final model suggests that nutritional density and recipe complexity are more informative than a simple healthy/non-healthy distinction.

A limitation of the project is that “healthy” was defined using tags rather than a rigorous nutritional scoring system. Future work could improve this by constructing a more principled health index, incorporating text features from reviews, or analyzing user-specific preferences.
