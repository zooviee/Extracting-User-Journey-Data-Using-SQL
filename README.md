## User Journey Extraction Query

### Objective

The goal of this query is to build complete **user journey paths** for customers who purchased a subscription plan for the first time within a specific period. These journeys capture all page interactions that happened *before* a user converted, making them ideal for:

* Conversion funnel analysis
* Customer behavior modeling
* Path optimization
* Drop-off detection

Each journey is represented as a **single ordered string** showing how users navigated the website before purchase.

---

### Business Rules Applied

This query follows these core rules:

1. **First-time buyers only**

   * Users whose first subscription purchase occurred between
     **January 1, 2023 and March 31, 2023 (inclusive)**

2. **Paid users only**

   * Test users are excluded
   * Any purchase with a price of `0` is removed

3. **Pre-conversion behavior**

   * Only interactions that happened **before the first purchase date** are included

4. **Session-based journeys**

   * Interactions are grouped by:

     * `user_id`
     * `session_id`

5. **URL aliasing**

   * Long and complex URLs are converted into readable page names:

     * `Homepage`
     * `Login`
     * `Courses`
     * `Pricing`
     * `Checkout`
     * `Coupon`
     * etc.

This ensures journeys are human-readable and analytics-friendly.

---

### Logical Flow of the Query

The query is built using several Common Table Expressions (CTEs):

1. **`paid_users`**
   Identifies users who:

   * Made their **first purchase** in the target period
   * Paid a **non-zero amount**
   * Categorizes subscription types:

     * Monthly
     * Quarterly
     * Annual

2. **`user_interactions`**
   Links:

   * Paid users → front visitors → front interactions
   * Filters interactions that happened **before** the first purchase date

3. **`aliased_user_interactions`**
   Converts raw URLs into readable page aliases using `CASE` statements:

   * Example:

     ```
     https://365datascience.com/pricing/ → Pricing
     https://365datascience.com/checkout?coupon=... → Coupon
     ```

4. **`user_session_journey`**
   Creates directional page transitions:

   ```
   Homepage → Courses
   Courses → Pricing
   Pricing → Checkout
   ```

5. **`mod_session_journey`**
   Combines all page transitions for a session into one journey string using:

   ```
   GROUP_CONCAT(event_url SEPARATOR '->')
   ```

---

### Final Output

Each row represents **one complete session journey** for a user.

| Column Name         | Description                         |
| ------------------- | ----------------------------------- |
| `user_id`           | Unique identifier of the user       |
| `session_id`        | Unique session identifier           |
| `subscription_type` | Monthly, Quarterly, or Annual       |
| `user_journey`      | Full navigation path of the session |

Example output:

```
12345 | abcd-001 | Monthly | Homepage->Courses->Pricing->Checkout
```

---

### Export Format

The final result is exported as a **CSV file** containing:

```
user_id, session_id, subscription_type, user_journey
```

This dataset is ready for:

* Sequence analysis
* Sankey diagrams
* Markov chain modeling
* Funnel optimization
* User behavior clustering

---

### Why This Design Matters

This approach shows strong analytical engineering practice:

* Separates user selection, interaction filtering, and transformation logic.
* Handles URL normalization for interpretability.
* Builds reproducible session-level behavior paths.
* Produces modeling-ready data in a single extract.

