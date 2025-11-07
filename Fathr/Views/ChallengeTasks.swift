import Foundation

// MARK: - Daily Task Model
struct DailyTask: Identifiable {
    let id = UUID()
    let category: String
    let task: String
    let tip: String
}

// MARK: - Challenge Day Model
struct ChallengeDay {
    let dayNumber: Int
    let tasks: [DailyTask]
}

// MARK: - All Challenge Days
struct ChallengeTasks {
    static let allDays: [ChallengeDay] = [
        // Day 1
        ChallengeDay(dayNumber: 1, tasks: [
            DailyTask(category: "Nutrition", task: "Drink 3L of water", tip: "Hydration supports overall health and energy levels."),
            DailyTask(category: "Nutrition", task: "Eat a cup of spinach or kale", tip: "Leafy greens provide essential vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Go for a 30-minute walk", tip: "Light exercise boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Adequate sleep supports hormonal balance and recovery."),
            DailyTask(category: "Mental Wellness", task: "Spend 10 minutes meditating", tip: "Meditation reduces stress and improves focus.")
        ]),
        
        // Day 2
        ChallengeDay(dayNumber: 2, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of berries", tip: "Berries provide antioxidants that support overall health."),
            DailyTask(category: "Nutrition", task: "Include a serving of nuts", tip: "Nuts offer healthy fats and protein."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching", tip: "Stretching improves flexibility and circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Consistency helps regulate your internal clock."),
            DailyTask(category: "Lifestyle", task: "Take a 10-minute walk outside", tip: "Fresh air and sunlight improve mood and energy.")
        ]),
        
        // Day 3
        ChallengeDay(dayNumber: 3, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of eggs or tofu", tip: "Provides protein to support energy and muscle recovery."),
            DailyTask(category: "Nutrition", task: "Drink green tea", tip: "Green tea contains antioxidants that support overall wellness."),
            DailyTask(category: "Exercise", task: "Do 30 minutes of cardio (walking, cycling, jogging)", tip: "Cardio boosts heart health and circulation."),
            DailyTask(category: "Sleep", task: "Avoid screens 1 hour before bed", tip: "Reduces blue light exposure for better sleep quality."),
            DailyTask(category: "Mental Wellness", task: "Journal 5 minutes about your day", tip: "Reflection can reduce stress and improve clarity.")
        ]),
        
        // Day 4
        ChallengeDay(dayNumber: 4, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a colorful vegetable salad", tip: "Variety in vegetables ensures a range of nutrients."),
            DailyTask(category: "Nutrition", task: "Include a whole grain (brown rice, quinoa)", tip: "Supports steady energy levels."),
            DailyTask(category: "Exercise", task: "Do bodyweight exercises for 20 minutes", tip: "Strength training supports overall health and metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Maintain recovery and hormonal balance."),
            DailyTask(category: "Lifestyle", task: "Take a 5-minute deep breathing break", tip: "Deep breathing reduces stress and improves focus.")
        ]),
        
        // Day 5
        ChallengeDay(dayNumber: 5, tasks: [
            DailyTask(category: "Nutrition", task: "Drink 2 glasses of water before each meal", tip: "Supports digestion and hydration."),
            DailyTask(category: "Nutrition", task: "Eat a serving of lean protein", tip: "Protein supports muscle repair and energy."),
            DailyTask(category: "Exercise", task: "Walk 10,000 steps", tip: "Promotes circulation and energy expenditure."),
            DailyTask(category: "Sleep", task: "Avoid caffeine after 3 PM", tip: "Improves sleep quality."),
            DailyTask(category: "Mental Wellness", task: "Practice gratitude for 5 minutes", tip: "Positive mindset improves mental well-being.")
        ]),
        
        // Day 6
        ChallengeDay(dayNumber: 6, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of citrus fruits", tip: "Vitamin C supports immune function and overall health."),
            DailyTask(category: "Nutrition", task: "Include healthy fats (avocado, olive oil)", tip: "Supports brain function and energy."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of yoga or stretching", tip: "Improves flexibility and reduces stress."),
            DailyTask(category: "Sleep", task: "Maintain a cool, dark sleep environment", tip: "Supports deep, restorative sleep."),
            DailyTask(category: "Lifestyle", task: "Spend 15 minutes outdoors", tip: "Sunlight boosts vitamin D and mood.")
        ]),
        
        // Day 7
        ChallengeDay(dayNumber: 7, tasks: [
            DailyTask(category: "Nutrition", task: "Include a serving of legumes (beans, lentils)", tip: "Provides protein and fiber for sustained energy."),
            DailyTask(category: "Nutrition", task: "Drink a cup of herbal tea", tip: "Supports hydration and relaxation."),
            DailyTask(category: "Exercise", task: "Go for a brisk 30-minute walk", tip: "Improves cardiovascular health."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Consistent sleep improves recovery and wellness."),
            DailyTask(category: "Mental Wellness", task: "Plan your week ahead for 10 minutes", tip: "Organization reduces stress and improves focus.")
        ]),
        
        // Day 8
        ChallengeDay(dayNumber: 8, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of carrots or bell peppers", tip: "Rich in vitamin A and antioxidants."),
            DailyTask(category: "Nutrition", task: "Drink 2 liters of water", tip: "Maintains hydration and overall wellness."),
            DailyTask(category: "Exercise", task: "Do 30 minutes of light cardio", tip: "Boosts energy and circulation."),
            DailyTask(category: "Sleep", task: "Maintain a consistent bedtime", tip: "Regulates sleep patterns."),
            DailyTask(category: "Lifestyle", task: "Take a break from screens for 1 hour", tip: "Rest your eyes and reduce stress.")
        ]),
        
        // Day 9
        ChallengeDay(dayNumber: 9, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of oats or whole grain cereal", tip: "Whole grains provide sustained energy and fiber."),
            DailyTask(category: "Nutrition", task: "Include a serving of fresh fruit", tip: "Fruit provides natural vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Do 15 minutes of bodyweight strength exercises", tip: "Strength training boosts metabolism and muscle tone."),
            DailyTask(category: "Sleep", task: "Avoid heavy meals 2 hours before bed", tip: "Supports better sleep quality."),
            DailyTask(category: "Mental Wellness", task: "Spend 10 minutes practicing mindful breathing", tip: "Reduces stress and improves focus.")
        ]),
        
        // Day 10
        ChallengeDay(dayNumber: 10, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of Greek yogurt or plant-based yogurt", tip: "Provides protein and probiotics for digestion."),
            DailyTask(category: "Nutrition", task: "Drink a full glass of water with every meal", tip: "Hydration supports digestion and energy."),
            DailyTask(category: "Exercise", task: "Go for a 30-minute brisk walk", tip: "Cardio boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Keep your bedroom cool and dark", tip: "Improves sleep quality and recovery."),
            DailyTask(category: "Lifestyle", task: "Take a 10-minute nature walk", tip: "Sunlight and fresh air improve mood and vitamin D levels.")
        ]),
        
        // Day 11
        ChallengeDay(dayNumber: 11, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of nuts or seeds", tip: "Healthy fats support energy and brain function."),
            DailyTask(category: "Nutrition", task: "Include a serving of leafy greens", tip: "Provides vitamins and minerals for overall wellness."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Improves flexibility and circulation."),
            DailyTask(category: "Sleep", task: "Go to bed at the same time as yesterday", tip: "Supports circadian rhythm stability."),
            DailyTask(category: "Mental Wellness", task: "Write down three things you're grateful for", tip: "Gratitude improves mental well-being.")
        ]),
        
        // Day 12
        ChallengeDay(dayNumber: 12, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of colorful vegetables", tip: "Variety ensures a range of vitamins and antioxidants."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Keeps your body hydrated and energized."),
            DailyTask(category: "Exercise", task: "Do 30 minutes of light cardio", tip: "Supports cardiovascular health and energy."),
            DailyTask(category: "Sleep", task: "Limit screen time before bed to 30 minutes", tip: "Reduces blue light for better sleep."),
            DailyTask(category: "Lifestyle", task: "Spend 15 minutes outside in natural light", tip: "Improves mood and vitamin D synthesis.")
        ]),
        
        // Day 13
        ChallengeDay(dayNumber: 13, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes (beans, lentils)", tip: "High in fiber and plant-based protein."),
            DailyTask(category: "Nutrition", task: "Include a healthy fat source (avocado, olive oil)", tip: "Supports heart and brain health."),
            DailyTask(category: "Exercise", task: "Walk at a brisk pace for 30 minutes", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Supports recovery and hormonal balance."),
            DailyTask(category: "Mental Wellness", task: "Practice 10 minutes of deep breathing", tip: "Reduces stress and promotes relaxation.")
        ]),
        
        // Day 14
        ChallengeDay(dayNumber: 14, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of whole grains", tip: "Provides steady energy and fiber."),
            DailyTask(category: "Nutrition", task: "Drink a cup of herbal tea", tip: "Hydrates and supports relaxation."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of strength exercises", tip: "Supports muscle tone and metabolism."),
            DailyTask(category: "Sleep", task: "Avoid caffeine after 2 PM", tip: "Helps you fall asleep faster."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes stretching or foam rolling", tip: "Improves mobility and circulation.")
        ]),
        
        // Day 15
        ChallengeDay(dayNumber: 15, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of berries", tip: "Berries are rich in antioxidants for overall wellness."),
            DailyTask(category: "Nutrition", task: "Include a serving of nuts", tip: "Healthy fats support brain function and energy."),
            DailyTask(category: "Exercise", task: "Go for a 30-minute walk outdoors", tip: "Fresh air boosts mood and circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports sleep cycle stability."),
            DailyTask(category: "Mental Wellness", task: "Take 5 minutes to reflect on achievements today", tip: "Reflection improves mindset and clarity.")
        ]),
        
        // Day 16
        ChallengeDay(dayNumber: 16, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (eggs, tofu, fish)", tip: "Supports energy and recovery."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Hydration is critical for energy and focus."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of light stretching or yoga", tip: "Reduces muscle tension and boosts flexibility."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery and mental clarity."),
            DailyTask(category: "Lifestyle", task: "Spend 15 minutes outside", tip: "Sunlight and movement improve energy and mood.")
        ]),
        
        // Day 17
        ChallengeDay(dayNumber: 17, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of colorful vegetables", tip: "Supports overall wellness with vitamins and antioxidants."),
            DailyTask(category: "Nutrition", task: "Include a serving of whole grains", tip: "Provides energy and fiber."),
            DailyTask(category: "Exercise", task: "Go for a 30-minute brisk walk", tip: "Boosts circulation and energy levels."),
            DailyTask(category: "Sleep", task: "Avoid screens 1 hour before bed", tip: "Improves sleep quality."),
            DailyTask(category: "Mental Wellness", task: "Practice 5 minutes of mindful breathing", tip: "Reduces stress and improves focus.")
        ]),
        
        // Day 18
        ChallengeDay(dayNumber: 18, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of nuts or seeds", tip: "Provides healthy fats for brain and heart health."),
            DailyTask(category: "Nutrition", task: "Drink a glass of water before each meal", tip: "Supports digestion and hydration."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength exercises", tip: "Strength training supports overall health."),
            DailyTask(category: "Sleep", task: "Maintain a consistent bedtime", tip: "Supports circadian rhythm and recovery."),
            DailyTask(category: "Lifestyle", task: "Take a 10-minute walk outside", tip: "Fresh air boosts energy and mood.")
        ]),
        
        // Day 19
        ChallengeDay(dayNumber: 19, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports sustained energy with protein and fiber."),
            DailyTask(category: "Nutrition", task: "Include a serving of fruit", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Do 30 minutes of light cardio", tip: "Boosts circulation and stamina."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Supports recovery and overall wellness."),
            DailyTask(category: "Mental Wellness", task: "Write down one thing you accomplished today", tip: "Encourages positive mindset and reflection.")
        ]),
        
        // Day 20
        ChallengeDay(dayNumber: 20, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Rich in vitamins and minerals for overall health."),
            DailyTask(category: "Nutrition", task: "Drink herbal tea in the evening", tip: "Supports hydration and relaxation."),
            DailyTask(category: "Exercise", task: "Walk 10,000 steps", tip: "Supports circulation and energy levels."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime and wake time", tip: "Supports circadian rhythm and recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 15 minutes in sunlight", tip: "Vitamin D supports mood and wellness.")
        ]),
        
        // Day 21
        ChallengeDay(dayNumber: 21, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of salmon or plant-based omega-3 source", tip: "Omega-3 supports heart and brain health."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports muscle and metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery and hormone balance."),
            DailyTask(category: "Mental Wellness", task: "Practice 5 minutes of mindfulness meditation", tip: "Reduces stress and improves focus.")
        ]),
        
        // Day 22
        ChallengeDay(dayNumber: 22, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of whole grains", tip: "Provides energy and fiber."),
            DailyTask(category: "Nutrition", task: "Drink a glass of water before each meal", tip: "Supports hydration and digestion."),
            DailyTask(category: "Exercise", task: "Go for a 30-minute walk outdoors", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes in nature", tip: "Improves mood and mental clarity.")
        ]),
        
        // Day 23
        ChallengeDay(dayNumber: 23, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of beans or lentils", tip: "High in fiber and plant protein."),
            DailyTask(category: "Nutrition", task: "Include a serving of fruit", tip: "Provides natural vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Do 15 minutes of stretching or yoga", tip: "Improves flexibility and circulation."),
            DailyTask(category: "Sleep", task: "Avoid screens 1 hour before bed", tip: "Supports better sleep quality."),
            DailyTask(category: "Mental Wellness", task: "Write down one positive thought for the day", tip: "Encourages gratitude and positive mindset.")
        ]),
        
        // Day 24
        ChallengeDay(dayNumber: 24, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of nuts or seeds", tip: "Healthy fats support energy and brain function."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential vitamins and minerals."),
            DailyTask(category: "Exercise", task: "Walk briskly for 30 minutes", tip: "Supports circulation and stamina."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Supports recovery and hormonal balance."),
            DailyTask(category: "Lifestyle", task: "Take 10 minutes to relax and stretch", tip: "Supports recovery and reduces tension.")
        ]),
        
        // Day 25
        ChallengeDay(dayNumber: 25, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of lean protein (chicken, tofu, fish)", tip: "Supports muscle and energy."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Maintains hydration and focus."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of light cardio", tip: "Supports heart health and energy."),
            DailyTask(category: "Sleep", task: "Keep a consistent bedtime", tip: "Supports circadian rhythm and recovery."),
            DailyTask(category: "Mental Wellness", task: "Practice 5 minutes of deep breathing", tip: "Reduces stress and improves focus.")
        ]),
        
        // Day 26
        ChallengeDay(dayNumber: 26, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of colorful vegetables", tip: "Variety ensures broad range of vitamins."),
            DailyTask(category: "Nutrition", task: "Include a serving of whole grains", tip: "Provides sustained energy."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of strength exercises", tip: "Supports muscle health and metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes in natural sunlight", tip: "Vitamin D supports mood and wellness.")
        ]),
        
        // Day 27
        ChallengeDay(dayNumber: 27, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of berries", tip: "Antioxidants support overall health."),
            DailyTask(category: "Nutrition", task: "Drink water with every meal", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Walk 10,000 steps", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime and wake time", tip: "Supports circadian rhythm."),
            DailyTask(category: "Mental Wellness", task: "Write down a goal for tomorrow", tip: "Encourages focus and planning.")
        ]),
        
        // Day 28
        ChallengeDay(dayNumber: 28, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall health and wellness."),
            DailyTask(category: "Nutrition", task: "Include a healthy fat source", tip: "Supports heart and brain health."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of light cardio", tip: "Boosts energy and circulation."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 15 minutes outside", tip: "Boosts mood and vitamin D.")
        ]),
        
        // Day 29
        ChallengeDay(dayNumber: 29, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports sustained energy with protein and fiber."),
            DailyTask(category: "Nutrition", task: "Drink herbal tea", tip: "Supports hydration and relaxation."),
            DailyTask(category: "Exercise", task: "Do 15 minutes of stretching", tip: "Improves flexibility and circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Mental Wellness", task: "Practice 5 minutes of mindful breathing", tip: "Reduces stress and improves focus.")
        ]),
        
        // Day 30
        ChallengeDay(dayNumber: 30, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of whole grains", tip: "Provides fiber and energy."),
            DailyTask(category: "Nutrition", task: "Include a serving of fruit", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports heart health and mood."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery and energy."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Improves mood and mental clarity.")
        ]),
        
        // Day 31
        ChallengeDay(dayNumber: 31, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of nuts or seeds", tip: "Supports healthy fats and brain function."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential vitamins and minerals."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports muscle and metabolism."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Reflect on one accomplishment today", tip: "Encourages positive mindset.")
        ]),
        
        // Day 32
        ChallengeDay(dayNumber: 32, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (eggs, tofu, fish)", tip: "Supports energy and recovery."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Supports hydration and focus."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Reduces muscle tension."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside in sunlight", tip: "Vitamin D supports mood.")
        ]),
        
        // Day 33
        ChallengeDay(dayNumber: 33, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of colorful vegetables", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Nutrition", task: "Include a serving of whole grains", tip: "Supports sustained energy."),
            DailyTask(category: "Exercise", task: "Go for a brisk 30-minute walk", tip: "Supports circulation."),
            DailyTask(category: "Sleep", task: "Avoid screens 1 hour before bed", tip: "Supports sleep quality."),
            DailyTask(category: "Mental Wellness", task: "Practice 5 minutes of mindful breathing", tip: "Reduces stress.")
        ]),
        
        // Day 34
        ChallengeDay(dayNumber: 34, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Provides fiber and plant-based protein."),
            DailyTask(category: "Nutrition", task: "Drink water with meals", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of light cardio", tip: "Boosts circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Take a 10-minute walk outdoors", tip: "Boosts mood and energy.")
        ]),

        // Day 35
        ChallengeDay(dayNumber: 35, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall health."),
            DailyTask(category: "Nutrition", task: "Include a serving of healthy fat", tip: "Supports brain and heart health."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength exercises", tip: "Supports metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Write down one thing you are grateful for", tip: "Improves mindset.")
        ]),
        
        // Day 36
        ChallengeDay(dayNumber: 36, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of berries", tip: "Rich in antioxidants."),
            DailyTask(category: "Nutrition", task: "Drink water with every meal", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports circulation and mood."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime and wake time", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Vitamin D and fresh air.")
        ]),
        
        // Day 37
        ChallengeDay(dayNumber: 37, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (eggs, tofu, fish)", tip: "Supports energy and muscle recovery."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential nutrients."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Improves flexibility."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Reflect on a positive moment from today", tip: "Encourages gratitude.")
        ]),
        
        // Day 38
        ChallengeDay(dayNumber: 38, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of whole grains", tip: "Provides fiber and energy."),
            DailyTask(category: "Nutrition", task: "Drink herbal tea", tip: "Supports relaxation."),
            DailyTask(category: "Exercise", task: "Go for a brisk 30-minute walk", tip: "Boosts circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports sleep quality."),
            DailyTask(category: "Lifestyle", task: "Spend 15 minutes outdoors", tip: "Improves mood and vitamin D levels.")
        ]),
        
        // Day 39
        ChallengeDay(dayNumber: 39, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall health."),
            DailyTask(category: "Nutrition", task: "Include a serving of fruit", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports muscle and metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Practice 5 minutes of mindful breathing", tip: "Reduces stress.")
        ]),
        
        // Day 40
        ChallengeDay(dayNumber: 40, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports energy and digestion."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Walk 10,000 steps", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime and wake time", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside in sunlight", tip: "Supports mood and vitamin D synthesis.")
        ]),
        
        // Day 41
        ChallengeDay(dayNumber: 41, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of lean protein (chicken, fish, tofu)", tip: "Supports muscle and energy."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential vitamins and minerals."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching", tip: "Improves flexibility and circulation."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery and hormonal balance."),
            DailyTask(category: "Mental Wellness", task: "Write one positive thought", tip: "Encourages a positive mindset.")
        ]),
        
        // Day 42
        ChallengeDay(dayNumber: 42, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of whole grains", tip: "Provides sustained energy."),
            DailyTask(category: "Nutrition", task: "Drink a glass of water before each meal", tip: "Supports digestion and hydration."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports circulation and mood."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes in nature", tip: "Boosts mental clarity and reduces stress.")
        ]),
        
        // Day 43
        ChallengeDay(dayNumber: 43, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of fruit", tip: "Provides natural vitamins and antioxidants."),
            DailyTask(category: "Nutrition", task: "Include a serving of nuts or seeds", tip: "Supports healthy fats and energy."),
            DailyTask(category: "Exercise", task: "Do 15 minutes of yoga or mobility exercises", tip: "Improves flexibility and circulation."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Practice 5 minutes of mindful breathing", tip: "Reduces stress.")
        ]),
        
        // Day 44
        ChallengeDay(dayNumber: 44, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports digestion and sustained energy."),
            DailyTask(category: "Nutrition", task: "Drink herbal tea", tip: "Supports relaxation and hydration."),
            DailyTask(category: "Exercise", task: "Walk briskly for 20 minutes", tip: "Boosts circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outdoors", tip: "Supports mood and mental clarity.")
        ]),
        
        // Day 45
        ChallengeDay(dayNumber: 45, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall wellness."),
            DailyTask(category: "Nutrition", task: "Include a healthy fat source", tip: "Supports brain and heart health."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports muscle and metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Reflect on one accomplishment", tip: "Encourages a positive mindset.")
        ]),
        
        // Day 46
        ChallengeDay(dayNumber: 46, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of berries", tip: "Rich in antioxidants."),
            DailyTask(category: "Nutrition", task: "Drink water with each meal", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports mood and circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime and wake time", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Vitamin D and fresh air.")
        ]),
        
        // Day 47
        ChallengeDay(dayNumber: 47, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (eggs, tofu, fish)", tip: "Supports energy and recovery."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential nutrients."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Reduces muscle tension."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Reflect on a positive moment today", tip: "Encourages gratitude.")
        ]),
        
        // Day 48
        ChallengeDay(dayNumber: 48, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of whole grains", tip: "Provides fiber and energy."),
            DailyTask(category: "Nutrition", task: "Include a serving of fruit", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery and energy."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Boosts mood and vitamin D levels.")
        ]),
        
        // Day 49
        ChallengeDay(dayNumber: 49, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of nuts or seeds", tip: "Supports healthy fats and brain function."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential vitamins and minerals."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports metabolism and muscle."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Write one positive thought today", tip: "Encourages a positive mindset.")
        ]),
        
        // Day 50
        ChallengeDay(dayNumber: 50, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (chicken, fish, tofu)", tip: "Supports muscle and energy."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Supports hydration and focus."),
            DailyTask(category: "Exercise", task: "Walk briskly for 30 minutes", tip: "Boosts circulation."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outdoors", tip: "Supports mood and mental clarity.")
        ]),
        
        // Day 51
        ChallengeDay(dayNumber: 51, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of colorful vegetables", tip: "Variety ensures vitamins and minerals."),
            DailyTask(category: "Nutrition", task: "Include a serving of whole grains", tip: "Supports energy and digestion."),
            DailyTask(category: "Exercise", task: "Do 15 minutes of stretching or yoga", tip: "Improves flexibility."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Mental Wellness", task: "Reflect on one thing you are grateful for", tip: "Encourages positivity.")
        ]),
        
        // Day 52
        ChallengeDay(dayNumber: 52, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of berries", tip: "Antioxidants support overall health."),
            DailyTask(category: "Nutrition", task: "Drink water with each meal", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Vitamin D and fresh air.")
        ]),
        
        // Day 53
        ChallengeDay(dayNumber: 53, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (eggs, tofu, fish)", tip: "Supports muscle and recovery."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential nutrients."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Reflect on a positive moment today", tip: "Encourages gratitude.")
        ]),
        
        // Day 54
        ChallengeDay(dayNumber: 54, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of whole grains", tip: "Provides energy and fiber."),
            DailyTask(category: "Nutrition", task: "Include a serving of fruit", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Boosts mood and vitamin D levels.")
        ]),
        
        // Day 55
        ChallengeDay(dayNumber: 55, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall wellness."),
            DailyTask(category: "Nutrition", task: "Include a healthy fat source", tip: "Supports brain and heart health."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Improves flexibility."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Write one thing you are grateful for", tip: "Encourages positivity.")
        ]),
        
        // Day 56
        ChallengeDay(dayNumber: 56, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports sustained energy."),
            DailyTask(category: "Nutrition", task: "Drink water with meals", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Walk briskly for 20 minutes", tip: "Supports circulation."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside in sunlight", tip: "Supports mood and vitamin D synthesis.")
        ]),
        
        // Day 57
        ChallengeDay(dayNumber: 57, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of berries", tip: "Rich in antioxidants."),
            DailyTask(category: "Nutrition", task: "Include a serving of whole grains", tip: "Provides fiber and energy."),
            DailyTask(category: "Exercise", task: "Do 15 minutes of yoga or mobility exercises", tip: "Improves flexibility."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Mental Wellness", task: "Write one positive thought", tip: "Encourages positive mindset.")
        ]),
        
        // Day 58
        ChallengeDay(dayNumber: 58, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (chicken, fish, tofu)", tip: "Supports muscle recovery."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential nutrients."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Vitamin D and fresh air.")
        ]),
        
        // Day 59
        ChallengeDay(dayNumber: 59, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall health."),
            DailyTask(category: "Nutrition", task: "Include a serving of fruit", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports metabolism and muscles."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Mental Wellness", task: "Reflect on one positive moment", tip: "Encourages gratitude.")
        ]),
        
        // Day 60
        ChallengeDay(dayNumber: 60, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports digestion and energy."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Walk 10,000 steps", tip: "Boosts circulation."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside in sunlight", tip: "Supports mood and vitamin D.")
        ]),
        
        // Day 61
        ChallengeDay(dayNumber: 61, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of colorful vegetables", tip: "Variety ensures essential vitamins and minerals."),
            DailyTask(category: "Nutrition", task: "Include a healthy fat source (avocado, nuts, olive oil)", tip: "Supports brain and heart health."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Improves flexibility and circulation."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery and hormonal balance."),
            DailyTask(category: "Mental Wellness", task: "Reflect on one accomplishment today", tip: "Encourages a positive mindset.")
        ]),
        
        // Day 62
        ChallengeDay(dayNumber: 62, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (eggs, fish, chicken, tofu)", tip: "Supports muscle and recovery."),
            DailyTask(category: "Nutrition", task: "Drink water with each meal", tip: "Supports hydration and digestion."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports circulation and mood."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside in sunlight", tip: "Vitamin D and fresh air boost mood.")
        ]),
        
        // Day 63
        ChallengeDay(dayNumber: 63, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall health."),
            DailyTask(category: "Nutrition", task: "Include a serving of whole grains", tip: "Provides fiber and sustained energy."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports muscle and metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Write one positive thought", tip: "Encourages positivity and gratitude.")
        ]),
        
        // Day 64
        ChallengeDay(dayNumber: 64, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of fruit", tip: "Provides natural vitamins and antioxidants."),
            DailyTask(category: "Nutrition", task: "Include a serving of nuts or seeds", tip: "Supports healthy fats and energy."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outdoors", tip: "Supports mood and mental clarity.")
        ]),
        
        // Day 65
        ChallengeDay(dayNumber: 65, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports digestion and sustained energy."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Improves flexibility."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Reflect on a positive moment", tip: "Encourages gratitude and mindfulness.")
        ]),
        
        // Day 66
        ChallengeDay(dayNumber: 66, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein (eggs, fish, chicken, tofu)", tip: "Supports muscle and energy."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Provides essential nutrients."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports circulation and mood."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Vitamin D and fresh air boost mood.")
        ]),
        
        // Day 67
        ChallengeDay(dayNumber: 67, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall wellness."),
            DailyTask(category: "Nutrition", task: "Include a serving of whole grains", tip: "Provides energy and fiber."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports muscle and metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Write one positive thought", tip: "Encourages positivity.")
        ]),
        
        // Day 68
        ChallengeDay(dayNumber: 68, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of fruit", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Nutrition", task: "Include a serving of nuts or seeds", tip: "Supports healthy fats."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes", tip: "Boosts circulation and energy."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outdoors", tip: "Supports mental clarity and vitamin D.")
        ]),
        
        // Day 69
        ChallengeDay(dayNumber: 69, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports digestion and sustained energy."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Supports flexibility and recovery."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Reflect on a positive moment", tip: "Encourages gratitude.")
        ]),
        
        // Day 70
        ChallengeDay(dayNumber: 70, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein", tip: "Supports muscle and recovery."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Supports overall health."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports circulation."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Boosts mood and vitamin D levels.")
        ]),
        
        // Day 71
        ChallengeDay(dayNumber: 71, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of leafy greens", tip: "Supports overall wellness."),
            DailyTask(category: "Nutrition", task: "Include a serving of whole grains", tip: "Provides energy and fiber."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of bodyweight strength training", tip: "Supports muscles and metabolism."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Write one positive thought", tip: "Encourages gratitude and positivity.")
        ]),
        
        // Day 72
        ChallengeDay(dayNumber: 72, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of fruit", tip: "Provides vitamins and antioxidants."),
            DailyTask(category: "Nutrition", task: "Include a serving of nuts or seeds", tip: "Supports healthy fats."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes", tip: "Supports circulation and energy."),
            DailyTask(category: "Sleep", task: "Maintain consistent bedtime", tip: "Supports circadian rhythm."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outdoors", tip: "Vitamin D and fresh air boost mood.")
        ]),
        
        // Day 73
        ChallengeDay(dayNumber: 73, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of legumes", tip: "Supports digestion and energy."),
            DailyTask(category: "Nutrition", task: "Drink at least 2 liters of water", tip: "Supports hydration."),
            DailyTask(category: "Exercise", task: "Do 20 minutes of stretching or yoga", tip: "Supports flexibility and circulation."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Mental Wellness", task: "Reflect on a positive moment", tip: "Encourages gratitude and mindfulness.")
        ]),
        
        // Day 74
        ChallengeDay(dayNumber: 74, tasks: [
            DailyTask(category: "Nutrition", task: "Eat a serving of protein", tip: "Supports muscle recovery and energy."),
            DailyTask(category: "Nutrition", task: "Include a serving of vegetables", tip: "Supports overall health."),
            DailyTask(category: "Exercise", task: "Walk 30 minutes outdoors", tip: "Supports circulation and energy."),
            DailyTask(category: "Sleep", task: "Sleep 7–8 hours", tip: "Supports recovery."),
            DailyTask(category: "Lifestyle", task: "Spend 10 minutes outside", tip: "Boosts mood and vitamin D.")
        ])
    ]
}
