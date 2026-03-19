

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
- A simple baseline model explained almost none of the variation in ratings
- A Random Forest Regressor with engineered features achieved **Test R² = 0.4008**
- The strongest predictors were **nutritional density** and **recipe efficiency**, not just the healthy label itself

</div>

## <span style="color:#2a5298;">Overview</span>

This project investigates whether recipes labeled as **healthy** tend to receive lower ratings than other recipes on Food.com. I combined recipe metadata with user interaction data, explored nutritional and structural recipe features, conducted a permutation test, and built regression models to predict average recipe ratings.

The project has two goals:

1. **Inference:** Determine whether healthy-tagged recipes are rated differently from non-healthy recipes.
2. **Prediction:** Predict a recipe’s average rating using structured recipe and nutrition-based features.

---

## <span style="color:#2a5298;">Research Question</span>

> **Do recipes tagged as healthy receive lower average ratings than other recipes?**

This question is interesting because healthy foods are sometimes perceived as less indulgent or less flavorful, which could affect user ratings. At the same time, users may value healthier meals when they are efficient, balanced, and practical. This project studies whether the “healthy” label itself is associated with lower ratings and what recipe features actually matter most for prediction.

---

## <span style="color:#2a5298;">Datasets</span>

I used two Food.com datasets:

### 1. `RAW_recipes.csv`
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

### 2. `interactions.csv`
This dataset contains user-level interactions, including:

- `user_id` — user ID
- `recipe_id` — recipe ID
- `date` — review date
- `rating` — user rating
- `review` — review text

---

## <span style="color:#1b9e77;">Data Cleaning and Preparation</span>

To prepare the data for analysis, I:

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
- created transformed features such as:
  - `log_minutes`
  - `log_calories`

### Defining Healthy Recipes

I created a boolean feature called `is_healthy_tag` by checking whether a recipe’s tags contain keywords such as:

- `healthy`
- `low-fat`
- `low-carb`
- `low-calorie`
- `high-protein`
- `low-sugar`

This is a tag-based platform definition of “healthy,” rather than a medical definition. That is appropriate here because the project studies how users respond to recipes that are presented as healthy on the platform.

---

## <span style="color:#1b9e77;">Exploratory Data Analysis</span>

I first explored the distributions of calories and cooking time. Since both variables were strongly right-skewed, I used `log(1 + x)` transformations to make the distributions easier to interpret.

### Distribution of Recipe Calories

<div style="text-align: center; margin: 30px 0;">
<img src="calories_distribution.png" width="72%">
<p style="color: gray; font-size: 14px;">
Figure 1: Distribution of recipe calories after log transformation.
</p>
</div>

The log-transformed calorie distribution is unimodal and roughly bell-shaped, which shows that the original calorie feature was heavily skewed but becomes much easier to analyze after transformation.

### Distribution of Recipe Cooking Time

<div style="text-align: center; margin: 30px 0;">
<img src="cooking_time_distribution.png" width="72%">
<p style="color: gray; font-size: 14px;">
Figure 2: Distribution of recipe cooking time after log transformation.
</p>
</div>

Cooking time is also strongly right-skewed. Most recipes take a relatively short or moderate amount of time, while a smaller number of recipes take much longer.

These plots suggest that transformations are important before modeling and that outliers likely matter when building predictive models.

---

## <span style="color:#d95f02;">Hypothesis Testing</span>

To test whether healthy-tagged recipes receive lower ratings, I performed a **one-sided permutation test**.

### Null Hypothesis
Healthy and non-healthy recipes come from the same distribution of average ratings, and any observed difference is due to chance.

### Alternative Hypothesis
Healthy recipes receive lower average ratings than non-healthy recipes.

### Test Statistic


mean average rating of healthy recipes - mean average rating of non-healthy recipes


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
Figure 3: Permutation distribution of the difference in average rating between healthy and non-healthy recipes.
</p>
</div>

### Interpretation

The observed difference is slightly negative, meaning healthy-tagged recipes were rated a little lower on average. However, the p-value is approximately **0.0653**, which is greater than the conventional significance threshold of 0.05.

Therefore, I **fail to reject the null hypothesis**. The data suggests a small negative association, but the evidence is not strong enough to conclude that healthy-tagged recipes are rated lower.

---

## <span style="color:#7570b3;">Framing a Prediction Problem</span>

In addition to inference, I framed a supervised learning problem where the goal is to predict:

- **`average_rating`**

This is a **regression problem**, because the response variable is numeric and continuous.

### Why regression?
Average recipe ratings can take values such as 3.8, 4.2, or 4.75, so the task is to predict a number rather than assign a category.

### Evaluation Metric
I used **R²** to evaluate model performance.

R² measures how much of the variation in average recipe ratings is explained by the model on unseen test data.

---

## <span style="color:#7570b3;">Baseline Model</span>

As a baseline, I used simple regression models with basic structured recipe features such as:

- `log_minutes`
- `n_steps`
- `n_ingredients`
- `log_calories`

The baseline model performed poorly, with R² near zero. This suggests that simple recipe structure alone explains very little of the variation in recipe ratings.

---

## <span style="color:#7570b3;">Final Model</span>

To improve performance, I engineered richer features that capture nutritional density and recipe efficiency, including:

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

I then trained a **Random Forest Regressor**, which can capture nonlinear relationships between recipe features and average rating.

### Final Model Performance

<div style="background: #f7f4ff; padding: 18px; border-left: 6px solid #7570b3; margin: 20px 0 30px 0; border-radius: 8px;">

- **Train R²:** `0.4236028323292136`
- **Test R²:** `0.40076260064006985`

</div>

This is a major improvement over the baseline and shows that the model explains a meaningful portion of the variation in average recipe ratings.

---

## <span style="color:#7570b3;">Model Validation and Sanity Checks</span>

I performed several checks to make sure the model was valid.

### Leakage Check
I removed suspicious features such as `rating_count`, and the model still achieved:

- **R² without leakage:** `0.40076260064006985`

This suggests that the strong performance is not driven by obvious leakage.

### Baseline Comparison
A naive model that always predicts the mean rating achieved:

- **Baseline R²:** `-1.7769007223833455e-05`

This confirms that the Random Forest is learning meaningful structure rather than relying on trivial prediction behavior.

### Generalization Check
The training and test R² values are very close:

- Train R² = `0.4236`
- Test R² = `0.4008`

This indicates that the model is **not overfitting significantly** and generalizes well.

---

## <span style="color:#e7298a;">Feature Importance</span>

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
Figure 4: Top feature importances from the Random Forest Regressor.
</p>
</div>

### Interpretation

These results suggest that both **nutritional density** and **recipe efficiency** are important for predicting user ratings.

In particular:

- nutritional composition matters more than a simple healthy/non-healthy label
- users may reward recipes that deliver better value relative to their complexity
- the model is learning intuitive and interpretable relationships rather than relying on one suspicious variable

---

## <span style="color:#2a5298;">Main Findings</span>

<div style="background: #eef4ff; padding: 20px; border-left: 6px solid #2a5298; margin: 20px 0 30px 0; border-radius: 8px;">

- Healthy-tagged recipes were rated **slightly lower on average**
- The difference was **not statistically significant** at the 5% level
- Simple baseline models explained almost none of the variation in ratings
- A Random Forest Regressor with engineered features substantially improved predictive performance
- The final model achieved **Test R² ≈ 0.401**
- Nutritional ratios and recipe-efficiency features were the strongest predictors of rating

</div>

---

## <span style="color:#2a5298;">Conclusion</span>

In this project, I investigated whether recipes labeled as healthy receive lower ratings than other recipes. The inferential analysis found a small negative difference in average rating for healthy-tagged recipes, but the p-value was above 0.05, so the evidence was not strong enough to conclude that healthy recipes are rated lower.

On the predictive side, simple baseline models performed poorly, but a Random Forest Regressor with engineered nutritional and efficiency-based features explained a meaningful amount of the variation in recipe ratings. The strongest predictors were not just whether a recipe was tagged as healthy, but how its nutrition and complexity interacted.

A limitation of the project is that “healthy” was defined using tags rather than a rigorous nutrition-based score. Future work could improve this by creating a formal health index, incorporating text features from reviews, or modeling user-specific preferences.

---

## <span style="color:#2a5298;">Project Links</span>

- [GitHub Repository](https://github.com/Raunakss10/Project4)
- [Notebook File](https://github.com/Raunakss10/Project4/blob/main/project4.ipynb)

---

## <span style="color:#2a5298;">Author</span>

**Raunak Saluja - Dhruv Mittal**  
UC San Diego  
Data Science
