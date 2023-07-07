-- In this SQL script all the requirements for the case study
-- have been fullfilled. ALl required columns appear as intented
--and I have added 2 extra columns which account for the total amount of
--orders of each city and for the total amount of breakfast orders of each city
--and are the total_orders and breakfast_sum respectively
-- This code has been formatted with a certain extension I am used to. I hope it is acceptable.
--A screenshot with the results and a csv file are attached
--IMPORTANT: Please remember to adjust the FROM statement accordingly


SELECT
  t1.city,
  t1.total_orders,
  t1.efood_basket,
  t2.breakfast_basket,
  t1.frequency,
  t2.breakfast_frequency,
  t2.breakfast_sum,
  t3.Breakfas3t_eaters / t4.OverallCityBreakfast_users as breakfast_users3freq_perc,
  t6.Overall3_eaters / t7.OverallCity_eaters as efood_users3freq_perc
FROM
  (--calculating total orders and gathering the users in order to make the frequency statistic
    SELECT
      city,
      COUNT(*) AS total_orders,
      SUM(amount) / COUNT(*) AS efood_basket,
      COUNT(*) / COUNT(DISTINCT user_id) AS frequency,
      COUNT(DISTINCT user_id) AS total_users
    FROM
      `efood2022.main_assessment.orders`

    WHERE
      city IN (--using only the cities with >1000 orders
        SELECT
          city
        FROM
          `efood2022.main_assessment.orders`

        GROUP BY
          city
        HAVING
          COUNT(*) > 1000
      )
    GROUP BY
      city
  ) AS t1
  JOIN (--finding the breakfast frequency for each city and the total amount of breakfast orders in order to order correctly (DESC)    SELECT
      city,
      SUM(amount) / COUNT(*) AS breakfast_basket,
      COUNT(*) / COUNT(DISTINCT user_id) AS breakfast_frequency,
      COUNT (*) AS breakfast_sum
    FROM
      `efood2022.main_assessment.orders`

    WHERE
      cuisine = 'Breakfast'
    GROUP BY
      city
  ) AS t2 ON t1.city = t2.city
  JOIN (--finding the >3 distinct breakfast users
    SELECT
      city,
      COUNT(DISTINCT user_id) AS OverallCityBreakfast_users
    FROM
      `efood2022.main_assessment.orders`

    WHERE
      cuisine = 'Breakfast'
    GROUP BY
      city
  ) t4 ON t1.city = t4.city
  JOIN ( 
    SELECT
      t5.city,
      COUNT(DISTINCT t5.user_id) AS Breakfas3t_eaters
    FROM
      (
        SELECT
          city,
          user_id,
          COUNT(*)
        FROM
          `efood2022.main_assessment.orders`

        WHERE
          cuisine = 'Breakfast'
        GROUP BY
          city,
          user_id
        HAVING
          COUNT(*) > 3
      ) t5
    GROUP BY
      t5.city
  ) t3 ON t1.city = t3.city
  JOIN (-- finding the >3 distinct overall users
    SELECT
      city,
      COUNT(DISTINCT user_id) AS OverallCity_eaters
    FROM
      `efood2022.main_assessment.orders`

    GROUP BY
      city
  ) t7 ON t1.city = t7.city
  JOIN (
    SELECT
      t8.city,
      COUNT(DISTINCT t8.user_id) AS Overall3_eaters
    FROM
      (
        SELECT
          city,
          user_id,
          COUNT(*)
        FROM
          `efood2022.main_assessment.orders`

        GROUP BY
          city,
          user_id
        HAVING
          COUNT(*) > 3
      ) t8
    GROUP BY
      t8.city
  ) t6 ON t1.city = t6.city
ORDER BY
  t2.breakfast_sum DESC
LIMIT
  5;
