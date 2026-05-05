-- ==========================================
-- SEED SCRIPT: Data for test1@savaio.com
-- Run this in the Supabase SQL Editor
-- ==========================================

DO $$
DECLARE
    target_user_id UUID;
    target_email TEXT := 'test1@savaio.com';
BEGIN

-- 1. Get the User ID from auth.users
SELECT id INTO target_user_id FROM auth.users WHERE email = target_email;

IF target_user_id IS NULL THEN
    RAISE NOTICE 'User % not found. Please create the user first or check the email.', target_email;
ELSE
    RAISE NOTICE 'Seeding data for User ID: %', target_user_id;

    -- 2. Ensure Profile exists and is updated
    INSERT INTO public.profiles (id, full_name, username, total_balance, avatar_url)
    VALUES (
        target_user_id,
        'Savaio Test User',
        'tester_rich',
        50000000,
        'https://api.dicebear.com/7.x/pixel-art/svg?seed=Rich'
    )
    ON CONFLICT (id) DO UPDATE SET
        total_balance = 50000000,
        full_name = 'Savaio Test User',
        username = 'tester_rich';

    -- 3. Clear old data to prevent duplicates
    DELETE FROM public.transactions WHERE user_id = target_user_id;
    DELETE FROM public.budgets WHERE user_id = target_user_id;
    DELETE FROM public.daily_checkins WHERE user_id = target_user_id;
    DELETE FROM public.nudges WHERE user_id = target_user_id;
    DELETE FROM public.notifications WHERE user_id = target_user_id;

    -- 4. Seed Transactions (Income)
    INSERT INTO public.transactions (user_id, title, amount, category, type, date)
    VALUES 
    (target_user_id, 'Bonus Tahunan', 25000000, 'Investment', 'income', '2026-05-01 08:00:00'),
    (target_user_id, 'Gaji Pokok', 15000000, 'Salary', 'income', '2026-05-01 09:00:00'),
    (target_user_id, 'Freelance Project', 5000000, 'Investment', 'income', '2026-05-10 14:30:00');

    -- 5. Seed Transactions (Expenses - May 2026)
    INSERT INTO public.transactions (user_id, title, amount, category, type, date)
    VALUES 
    (target_user_id, 'Sewa Apartemen', 7500000, 'Kost/Sewa', 'expense', '2026-05-01 10:00:00'),
    (target_user_id, 'Belanja Mingguan', 1500000, 'Food', 'expense', '2026-05-02 11:00:00'),
    (target_user_id, 'Makan Malam Mewah', 1200000, 'Food', 'expense', '2026-05-03 20:00:00'),
    (target_user_id, 'Bensin Mobil', 500000, 'Transport', 'expense', '2026-05-04 08:30:00'),
    (target_user_id, 'Servis Rutin Mobil', 2000000, 'Transport', 'expense', '2026-05-04 14:00:00'),
    (target_user_id, 'Starbucks Reserve', 85000, 'Coffee', 'expense', '2026-05-04 16:00:00'),
    (target_user_id, 'Gym Membership', 850000, 'Fun', 'expense', '2026-05-05 07:00:00'),
    (target_user_id, 'Langganan Cloud', 150000, 'Fun', 'expense', '2026-05-05 09:00:00'),
    (target_user_id, 'Lunch w/ Team', 250000, 'Food', 'expense', '2026-05-02 12:30:00'),
    (target_user_id, 'Grab Car', 120000, 'Transport', 'expense', '2026-05-03 18:00:00'),
    (target_user_id, 'E-Toll Topup', 200000, 'Transport', 'expense', '2026-05-01 07:00:00');

    -- 6. Seed Budgets
    INSERT INTO public.budgets (user_id, category, amount, month)
    VALUES 
    (target_user_id, 'All', 15000000, '2026-05'),
    (target_user_id, 'Food', 5000000, '2026-05'),
    (target_user_id, 'Transport', 3000000, '2026-05'),
    (target_user_id, 'Coffee', 500000, '2026-05');

    -- 7. Seed Daily Check-ins (7 days streak)
    INSERT INTO public.daily_checkins (user_id, checkin_date)
    VALUES 
    (target_user_id, '2026-04-28'),
    (target_user_id, '2026-04-29'),
    (target_user_id, '2026-04-30'),
    (target_user_id, '2026-05-01'),
    (target_user_id, '2026-05-02'),
    (target_user_id, '2026-05-03'),
    (target_user_id, '2026-05-04');

    -- 8. Seed Nudges
    INSERT INTO public.nudges (user_id, type, message, is_read, created_at)
    VALUES 
    (target_user_id, 'positive', 'Hebat! Kamu sudah mencatat 7 hari berturut-turut. 🔥', false, now()),
    (target_user_id, 'info', 'Budget transport kamu masih sangat aman. Mau dialokasikan ke tabungan? 🏦', false, now() - interval '1 hour'),
    (target_user_id, 'warning', 'Pengeluaran Makan kamu sudah mencapai 60% dari budget. 🍔', false, now() - interval '2 hours');

    -- 9. Seed Notifications
    INSERT INTO public.notifications (user_id, title, message, type, is_read, created_at)
    VALUES 
    (target_user_id, 'Pencapaian Baru!', 'Kamu mendapatkan badge "Hematology" karena pengeluaran stabil.', 'success', false, now()),
    (target_user_id, 'Jangan Lupa!', 'Ingat untuk mencatat pengeluaran kopi sore ini ya.', 'info', false, now() - interval '3 hours');

    RAISE NOTICE 'Seeding completed successfully for test1@savaio.com';
END IF;

END $$;
