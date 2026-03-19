<div style="text-align: center; padding: 70px 20px; background: linear-gradient(135deg, #1e3c72, #1b9e77); color: white; border-radius: 14px; margin-bottom: 40px;">

<h1 style="font-size: 50px; margin-bottom: 12px; line-height: 1.2;">
Do Healthy Recipes Get Lower Ratings?
</h1>

<p style="font-size: 22px; margin-top: 0; opacity: 0.95;">
A Data Science Investigation of Recipe Tags, Nutrition, and User Preferences
</p>

<p style="font-size: 17px; margin-top: 18px;">
<strong>Raunak Saluja and Dhruv Mittal</strong> · UC San Diego
</p>

<a href="https://github.com/Raunakss10/Project4"
style="display: inline-block; margin-top: 22px; padding: 12px 24px; background: white; color: #1e3c72; border-radius: 8px; text-decoration: none; font-weight: 700;">
View on GitHub
</a>

</div>

## <span style="color:#e7298a;">TL;DR</span>

<div style="background: #f8f9fa; padding: 20px; border-left: 6px solid #e7298a; margin: 20px 0 35px 0; border-radius: 8px;">

- Healthy-tagged recipes were rated **slightly lower on average**
- The difference was **not statistically significant** at the 5% level
- Missingness in `rating` depends on observed variables such as cooking time and calories
- A simple baseline model explained almost none of the variation in ratings
- A Random Forest Regressor with engineered features achieved **Test R² = 0.4008**
- The strongest predictors were **nutritional density** and **recipe efficiency**
- The model showed **no significant fairness difference** between healthy and non-healthy recipes

</div>

## <span style="color:#2a5298;">Step 1: Introduction</span>

This project investigates whether recipes labeled as **healthy** tend to receive lower ratings than other recipes on Food.com. We combined recipe metadata with user interaction data, explored nutritional and structural recipe features, conducted permutation tests, and built regression models to predict average recipe ratings.

Our project has two main goals:

1. **Inference:** Determine whether healthy-tagged recipes are rated differently from non-healthy recipes.
2. **Prediction:** Predict a recipe’s average rating using structured recipe and nutrition-based features.

### Research Question

> **Do recipes tagged as healthy receive lower average ratings than other recipes?**

This question is interesting because healthy foods are sometimes perceived as less indulgent or less flavorful, which could affect user ratings. At the same time, users may value healthier meals when they are efficient, balanced, and practical. Our project studies whether the “healthy” label itself is associated with lower ratings and what recipe features actually matter most for prediction.

### Datasets

We used two Food.com datasets.

#### `RAW_recipes.csv`
This dataset contains recipe-level information, including:

- `name` — recipe name
- `id` — recipe ID
- `minutes` — preparation time
- `submitted` — submission date
- `tags` — Food.com tags
- `nutrition` — nutritional information
- `n_steps` — number of preparation steps
- `ingredients` — ingredients list
- `n_ingredients` — number of ingredients

#### `interactions.csv`
This dataset contains user-level interactions, including:

- `user_id` — user ID
- `recipe_id` — recipe ID
- `date` — review date
- `rating` — user rating
- `review` — review text

---

## <span style="color:#1b9e77;">Step 2: Data Cleaning and Exploratory Data Analysis</span>

### Data Cleaning

To prepare the data for analysis, we:

- merged the recipes and interactions datasets on recipe ID
- replaced ratings of `0` with `NaN`
- converted `submitted` and `date` to datetime
- computed `average_rating` for each recipe
- split the `nutrition` column into separate numeric columns:
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

We created a boolean feature called `is_healthy_tag` by checking whether a recipe’s tags contain keywords such as:

- `healthy`
- `low-fat`
- `low-carb`
- `low-calorie`
- `high-protein`
- `low-sugar`

This is a tag-based platform definition of healthy, rather than a medical definition. That is appropriate here because the project studies how users respond to recipes that are presented as healthy.

### Univariate Analysis

We first explored the distributions of calories and cooking time. Since both variables were strongly right-skewed, we used `log(1 + x)` transformations to make the distributions easier to interpret.

#### Distribution of Recipe Calories

<div style="text-align: center; margin: 30px 0;">
<img src="calories_distribution.png" width="72%">
<p style="color: gray; font-size: 14px;">
Figure 1: Distribution of recipe calories after log transformation.
</p>
</div>

The log-transformed calorie distribution is unimodal and roughly bell-shaped, which shows that the original calorie feature was heavily skewed but becomes much easier to analyze after transformation.

#### Distribution of Recipe Cooking Time

<div style="text-align: center; margin: 30px 0;">
<img src="cooking_time_distribution.png" width="72%">
<p style="color: gray; font-size: 14px;">
Figure 2: Distribution of recipe cooking time after log transformation.
</p>
</div>

Cooking time is also strongly right-skewed. Most recipes take a relatively short or moderate amount of time, while a smaller number of recipes take much longer.

### Bivariate Analysis

To directly connect exploratory analysis to our research question, we compared healthy and non-healthy recipes on average rating. The difference appeared visually small, suggesting that any relationship between healthy labeling and rating would likely be modest in size.

We also examined relationships between key predictors and recipe ratings, such as:
- calories and average rating
- cooking time and average rating
- healthy tag and average rating

These comparisons suggested that nutritional structure and recipe efficiency may matter more than the healthy label alone.

### Interesting Aggregates

We also examined grouped summaries of recipe features. For example, we compared mean average rating by healthy tag and summarized key numeric variables such as:
- `average_rating`
- `minutes`
- `n_steps`
- `n_ingredients`
- `calories`
- `is_healthy_tag`

These aggregates showed that:
- healthy-tagged recipes form a minority of the sample
- rating differences between healthy and non-healthy recipes are small
- calories, time, and recipe structure vary substantially across recipes and likely play a role in prediction

---

## <span style="color:#d95f02;">Step 3: Assessment of Missingness</span>

We investigated whether missingness in the `rating` variable depends on other observed variables.

### NMAR Discussion

We believe that missingness in the `review` column could plausibly be **NMAR**. Users who feel neutral or indifferent about a recipe may be less likely to leave a written review, while users with especially positive or negative reactions may be more motivated to write one. Since this motivation may depend on unobserved sentiment, the missingness of `review` may depend on the missing value itself or on unobserved information, which is consistent with an NMAR interpretation.

### Missingness Test 1: Rating vs Minutes

We tested whether missingness in `rating` depends on `minutes`.

#### Null Hypothesis
Missingness in `rating` does not depend on cooking time.

#### Alternative Hypothesis
Missingness in `rating` does depend on cooking time.

#### Test Statistic
Absolute difference in mean `minutes` between rows with missing ratings and rows with non-missing ratings.

<div style="background: #fff7f0; padding: 18px; border-left: 6px solid #d95f02; margin: 20px 0 30px 0; border-radius: 8px;">

- **Observed statistic:** `11.50990532844287`
- **p-value:** `0.0`

</div>

<div style="text-align: center; margin: 30px 0;">
<img src="missingness_minutes.png" width="72%">
<p style="color: gray; font-size: 14px;">
Figure 3: Permutation distribution for the dependence of rating missingness on cooking time.
</p>
</div>

#### Interpretation
The p-value is effectively 0, which is far below 0.05. We reject the null hypothesis and conclude that missingness in `rating` depends on cooking time. This suggests that recipes with missing ratings tend to have systematically different preparation times.

### Missingness Test 2: Rating vs Calories

We tested whether missingness in `rating` depends on `calories`.

#### Null Hypothesis
Missingness in `rating` does not depend on calories.

#### Alternative Hypothesis
Missingness in `rating` does depend on calories.

#### Test Statistic
Absolute difference in mean `calories` between rows with missing ratings and rows with non-missing ratings.

<div style="background: #fff7f0; padding: 18px; border-left: 6px solid #d95f02; margin: 20px 0 30px 0; border-radius: 8px;">

- **Observed statistic:** `67.977786093818`
- **p-value:** `0.0`

</div>

<div style="text-align: center; margin: 30px 0;">
<img src="missingness_calories.png" width="72%">
<p style="color: gray; font-size: 14px;">
Figure 4: Permutation distribution for the dependence of rating missingness on calories.
</p>
</div>

#### Interpretation
Again, the p-value is effectively 0, so we reject the null hypothesis. This indicates that missingness in ratings also depends on calorie content.

### Missingness Conclusion

Since missingness in `rating` depends on observed variables such as `minutes` and `calories`, the data is **not Missing Completely At Random (MCAR)**. Instead, the missingness mechanism is more consistent with **MAR**, where missingness is related to observed features.

---

## <span style="color:#d95f02;">Step 4: Hypothesis Testing</span>

To test whether healthy-tagged recipes receive lower ratings, we performed a **one-sided permutation test**.

### Relevant Columns

The most relevant columns for this question were:
- `average_rating`
- `is_healthy_tag`

### Null Hypothesis
Healthy and non-healthy recipes come from the same distribution of average ratings, and any observed difference is due to chance.

### Alternative Hypothesis
Healthy recipes receive lower average ratings than non-healthy recipes.

### Test Statistic

`mean average rating of healthy recipes - mean average rating of non-healthy recipes`

A more negative value supports the alternative hypothesis.

### Actual Results

<div style="background: #fff7f0; padding: 18px; border-left: 6px solid #d95f02; margin: 20px 0 30px 0; border-radius: 8px;">

- **Observed difference:** `-0.0033591948955473683`
- **p-value:** `0.06533333333333333`

</div>

### Permutation Distribution

<div style="text-align: center; margin: 30px 0;">
<img src="permutation_distribution.png" width="72%">
<p style="color: gray; font-size: 14px;">
Figure 5: Permutation distribution of the difference in average rating between healthy and non-healthy recipes.
</p>
</div>

### Decision and Interpretation

The observed difference is slightly negative, meaning healthy-tagged recipes were rated a little lower on average. However, the p-value is approximately **0.0653**, which is greater than the conventional significance threshold of 0.05.

Therefore, we **fail to reject the null hypothesis**. The evidence is not strong enough to conclude that healthy-tagged recipes are rated lower.

---

## <span style="color:#7570b3;">Step 5: Framing a Prediction Problem</span>

In addition to inference, we framed a supervised learning problem where the goal is to predict:

- **`average_rating`**

This is a **regression problem**, because the response variable is numeric and continuous.

### Why This Response Variable?

We chose `average_rating` because it summarizes how users collectively evaluate a recipe and provides a more stable target than a single individual rating.

### Features Available at Prediction Time

We only used recipe-level features that would be available before observing the target rating, such as:
- cooking time
- number of steps
- number of ingredients
- calories
- engineered nutrition ratios
- healthy tag indicator

### Evaluation Metric

We used **R²** to evaluate model performance.

R² measures how much of the variation in average recipe ratings is explained by the model on unseen test data.

---

## <span style="color:#7570b3;">Step 6: Baseline Model</span>

As a baseline, we used simple regression models with basic structured recipe features such as:

- `log_minutes`
- `n_steps`
- `n_ingredients`
- `log_calories`

These were all numeric features and gave us a simple, interpretable benchmark.

### Baseline Model Performance

The baseline model performed poorly, with R² near zero. This suggests that simple recipe structure alone explains very little of the variation in recipe ratings.

### Baseline Interpretation

This weak performance motivated us to engineer richer features and move to a more flexible final model.

---

## <span style="color:#7570b3;">Step 7: Final Model</span>

To improve performance, we engineered richer features that capture nutritional density and recipe efficiency, including:

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

We then trained a **Random Forest Regressor**, which can capture nonlinear relationships between recipe features and average rating.

### Final Model Performance

<div style="background: #f7f4ff; padding: 18px; border-left: 6px solid #7570b3; margin: 20px 0 30px 0; border-radius: 8px;">

- **Train R²:** `0.4236028323292136`
- **Test R²:** `0.40076260064006985`

</div>

This is a major improvement over the baseline and shows that the model explains a meaningful portion of the variation in average recipe ratings.

### Model Validation and Sanity Checks

We performed several checks to make sure the model was valid.

#### Leakage Check
We removed suspicious features such as `rating_count`, and the model still achieved:

- **R² without leakage:** `0.40076260064006985`

#### Baseline Comparison
A naive model that always predicts the mean rating achieved:

- **Baseline R²:** `-1.7769007223833455e-05`

#### Generalization Check
The training and test R² values are very close:

- Train R² = `0.4236`
- Test R² = `0.4008`

This indicates that the model is **not overfitting significantly** and generalizes well.

### Feature Importance

The most important features in the final model were:

1. `fat_per_calorie` — `0.136059`
2. `protein_per_calorie` — `0.107010`
3. `calories_per_step` — `0.100194`
4. `log_calories` — `0.100135`
5. `sugar_per_calorie` — `0.096890`
6. `steps_per_min` — `0.084464`
7. `calories_per_ingredient` — `0.078194`
8. `ingredients_per_min` — `0.077822`
9. `log_minutes` — `0.073848`
10. `log_steps` — `0.053848`

<div style="text-align: center; margin: 30px 0;">
<img src="feature_importance.png" width="65%">
<p style="color: gray; font-size: 14px;">
Figure 6: Top feature importances from the Random Forest Regressor.
</p>
</div>

### Final Model Interpretation

These results suggest that both **nutritional density** and **recipe efficiency** are important for predicting user ratings. Nutritional composition matters more than a simple healthy/non-healthy label, and the model learns intuitive relationships rather than relying on one suspicious variable.

---

## <span style="color:#e7298a;">Step 8: Fairness Analysis</span>

Because our final model is a **regression model**, we evaluated fairness by comparing model error across groups rather than using classification metrics like precision or recall.

We split recipes into two groups:
- **healthy recipes**
- **non-healthy recipes**

We then compared the model’s **mean absolute error (MAE)** across the two groups.

### Fairness Metric

Our fairness metric was:

`MAE(healthy) - MAE(non-healthy)`

A value far from zero would suggest that the model performs differently across groups.

### Null Hypothesis
The model is fair with respect to healthy vs non-healthy recipes. Any difference in MAE is due to chance.

### Alternative Hypothesis
The model is unfair with respect to healthy vs non-healthy recipes. The difference in MAE is not due to chance.

### Test Procedure

We performed a permutation test by shuffling the healthy/non-healthy labels many times and recomputing the difference in MAE to generate a null distribution.

### Results

<div style="background: #fff7fb; padding: 18px; border-left: 6px solid #e7298a; margin: 20px 0 30px 0; border-radius: 8px;">

- **MAE for healthy recipes:** `0.16935854733336686`
- **MAE for non-healthy recipes:** `0.17119278859934423`
- **Observed MAE difference (healthy − non-healthy):** `-0.0018342412659773655`
- **p-value:** `0.4235`

</div>

<div style="text-align: center; margin: 30px 0;">
<img src="fairness_mae.png" width="72%">
<p style="color: gray; font-size: 14px;">
Figure 7: Permutation distribution for the fairness analysis using MAE difference.
</p>
</div>

### Interpretation

The difference in MAE between healthy and non-healthy recipes is extremely small, and the p-value is well above 0.05. We therefore **fail to reject the null hypothesis**.

This suggests that the model does not perform significantly differently across the two groups and appears fair with respect to the healthy-tag grouping.

---

## <span style="color:#2a5298;">Overall Findings</span>

<div style="background: #eef4ff; padding: 20px; border-left: 6px solid #2a5298; margin: 20px 0 30px 0; border-radius: 8px;">

- Healthy-tagged recipes were rated **slightly lower on average**
- The difference was **not statistically significant** at the 5% level
- Missingness in `rating` depends on observed variables such as cooking time and calories
- Simple baseline models explained almost none of the variation in ratings
- A Random Forest Regressor with engineered features substantially improved predictive performance
- The final model achieved **Test R² ≈ 0.401**
- Nutritional ratios and recipe-efficiency features were the strongest predictors of rating
- The fairness analysis found **no significant difference** in model error across healthy and non-healthy recipes

</div>

---

## <span style="color:#2a5298;">Conclusion</span>

In this project, we investigated whether recipes labeled as healthy receive lower ratings than other recipes. The inferential analysis found a small negative difference in average rating for healthy-tagged recipes, but the p-value was above 0.05, so the evidence was not strong enough to conclude that healthy recipes are rated lower.

On the predictive side, simple baseline models performed poorly, but a Random Forest Regressor with engineered nutritional and efficiency-based features explained a meaningful amount of the variation in recipe ratings. The strongest predictors were not just whether a recipe was tagged as healthy, but how its nutrition and complexity interacted.

We also assessed missingness and fairness to address the full data science workflow. Missingness in ratings depended on observed variables like cooking time and calories, suggesting a MAR mechanism rather than MCAR. Meanwhile, the fairness analysis showed no significant difference in model error across healthy and non-healthy recipes.

A limitation of the project is that “healthy” was defined using tags rather than a rigorous nutrition-based score. Future work could improve this by creating a formal health index, incorporating text features from reviews, or modeling user-specific preferences.

---

## <span style="color:#2a5298;">Authors</span>

**Raunak Saluja and Dhruv Mittal**  
UC San Diego  
Data Science
