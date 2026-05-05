-- ================================================================================
-- PERFORMANCE OPTIMIZATION SCRIPT FOR KINETIC VAULT (SAVAIO)
-- Run this script in your Supabase SQL Editor to enable real-time analysis.
-- ================================================================================

-- ================================================================================
-- PERFORMANCE TUNING: INDICES
-- ================================================================================

-- Essential composite indices for fast filtering and aggregation
CREATE INDEX IF NOT EXISTS idx_transactions_perf_query 
ON public.transactions (user_id, type, date);

CREATE INDEX IF NOT EXISTS idx_budgets_perf_query 
ON public.budgets (user_id, month, category);

-- ================================================================================
-- UNIFIED ANALYSIS SNAPSHOT SERVICE (OPTIMIZED V2)
-- ================================================================================

CREATE OR REPLACE FUNCTION get_analysis_snapshot(p_user_id UUID, p_month TEXT)
RETURNS JSONB AS $$
DECLARE
    v_total_expense NUMERIC := 0;
    v_target_amount NUMERIC := 0;
    v_category_breakdown JSONB;
    v_daily_trend JSONB;
    v_monthly_trend JSONB;
    v_start_of_month TIMESTAMP;
    v_end_of_month TIMESTAMP;
    v_days_in_month INT;
BEGIN
    v_start_of_month := TO_DATE(p_month || '-01', 'YYYY-MM-DD');
    v_end_of_month := (v_start_of_month + INTERVAL '1 month') - INTERVAL '1 second';
    v_days_in_month := EXTRACT(DAY FROM v_end_of_month);

    -- 1. Get Total Expense & Overall Budget Target
    SELECT COALESCE(SUM(amount), 0) INTO v_total_expense
    FROM public.transactions
    WHERE user_id = p_user_id AND type = 'expense' 
    AND date >= v_start_of_month AND date <= v_end_of_month;

    SELECT COALESCE(amount, 0) INTO v_target_amount
    FROM public.budgets
    WHERE user_id = p_user_id AND category = 'All' AND month = p_month;

    -- 2. Category Breakdown with Limits (Optimized Join)
    SELECT jsonb_agg(t) INTO v_category_breakdown
    FROM (
        WITH cat_sums AS (
            SELECT category, SUM(amount) as amt
            FROM public.transactions
            WHERE user_id = p_user_id 
            AND type = 'expense'
            AND date >= v_start_of_month 
            AND date <= v_end_of_month
            GROUP BY category
        )
        SELECT 
            cs.category as label, 
            cs.amt as amount,
            COALESCE(b.amount, 0) as budget_limit
        FROM cat_sums cs
        LEFT JOIN public.budgets b ON b.user_id = p_user_id 
            AND b.category = cs.category 
            AND b.month = p_month
        ORDER BY cs.amt DESC
    ) t;

    -- 3. Daily Trend (Optimized: Aggregate first, then fill gaps)
    SELECT jsonb_agg(val) INTO v_daily_trend
    FROM (
        WITH daily_sums AS (
            SELECT DATE_TRUNC('day', date) as d, SUM(amount) as amt
            FROM public.transactions
            WHERE user_id = p_user_id 
            AND type = 'expense'
            AND date >= v_start_of_month 
            AND date <= v_end_of_month
            GROUP BY 1
        )
        SELECT COALESCE(s.amt, 0) as val
        FROM generate_series(v_start_of_month, v_end_of_month, '1 day'::interval) d
        LEFT JOIN daily_sums s ON s.d = d
        ORDER BY d
    ) t;

    -- 4. Monthly Trend (Optimized for performance)
    SELECT jsonb_agg(t) INTO v_monthly_trend
    FROM (
        SELECT 
            TO_CHAR(date, 'YYYY-MM') as month,
            SUM(amount) as expense
        FROM public.transactions
        WHERE user_id = p_user_id AND type = 'expense'
        AND date >= DATE_TRUNC('month', CURRENT_TIMESTAMP - INTERVAL '5 months')
        GROUP BY month
        ORDER BY month ASC
    ) t;

    RETURN jsonb_build_object(
        'month', p_month,
        'total_expense', v_total_expense,
        'target_amount', v_target_amount,
        'average_daily_expense', CASE WHEN v_days_in_month > 0 THEN v_total_expense / v_days_in_month ELSE 0 END,
        'category_breakdown', COALESCE(v_category_breakdown, '[]'::jsonb),
        'daily_trend', COALESCE(v_daily_trend, '[]'::jsonb),
        'monthly_trend', COALESCE(v_monthly_trend, '[]'::jsonb)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 2. Dashboard Stats (Fast aggregation for Home)
CREATE OR REPLACE FUNCTION get_dashboard_stats(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_base_balance NUMERIC;
    v_net_balance_all_time NUMERIC;
    v_this_month_income NUMERIC;
    v_this_month_expense NUMERIC;
    v_start_of_month TIMESTAMP;
BEGIN
    v_start_of_month := DATE_TRUNC('month', CURRENT_TIMESTAMP);

    SELECT COALESCE(total_balance, 0) INTO v_base_balance FROM public.profiles WHERE id = p_user_id;

    SELECT SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END)
    INTO v_net_balance_all_time
    FROM public.transactions
    WHERE user_id = p_user_id;

    SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END),
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END)
    INTO v_this_month_income, v_this_month_expense
    FROM public.transactions
    WHERE user_id = p_user_id 
    AND date >= v_start_of_month;

    RETURN jsonb_build_object(
        'current_total_balance', COALESCE(v_base_balance, 0) + COALESCE(v_net_balance_all_time, 0),
        'this_month_income', COALESCE(v_this_month_income, 0),
        'this_month_expense', COALESCE(v_this_month_expense, 0)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 3. Weekly Pulse (Home Chart)
CREATE OR REPLACE FUNCTION get_weekly_pulse(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_this_week_total NUMERIC := 0;
    v_last_week_total NUMERIC := 0;
    v_daily_values NUMERIC[] := ARRAY[0,0,0,0,0,0,0]::NUMERIC[];
    v_start_of_this_week TIMESTAMP;
    v_start_of_last_week TIMESTAMP;
    v_growth NUMERIC := 0;
BEGIN
    v_start_of_this_week := DATE_TRUNC('week', CURRENT_TIMESTAMP);
    v_start_of_last_week := v_start_of_this_week - INTERVAL '7 days';

    SELECT 
        SUM(amount),
        ARRAY[
            COALESCE(SUM(CASE WHEN EXTRACT(ISODOW FROM date) = 1 THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN EXTRACT(ISODOW FROM date) = 2 THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN EXTRACT(ISODOW FROM date) = 3 THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN EXTRACT(ISODOW FROM date) = 4 THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN EXTRACT(ISODOW FROM date) = 5 THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN EXTRACT(ISODOW FROM date) = 6 THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN EXTRACT(ISODOW FROM date) = 7 THEN amount ELSE 0 END), 0)
        ]
    INTO v_this_week_total, v_daily_values
    FROM public.transactions
    WHERE user_id = p_user_id AND type = 'expense' AND date >= v_start_of_this_week;

    SELECT SUM(amount) INTO v_last_week_total
    FROM public.transactions
    WHERE user_id = p_user_id AND type = 'expense' AND date >= v_start_of_last_week AND date < v_start_of_this_week;

    IF COALESCE(v_last_week_total, 0) > 0 THEN
        v_growth := ((COALESCE(v_this_week_total, 0) - v_last_week_total) / v_last_week_total) * 100;
    ELSIF COALESCE(v_this_week_total, 0) > 0 THEN
        v_growth := 100;
    END IF;

    RETURN jsonb_build_object('growth', v_growth, 'values', v_daily_values);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
