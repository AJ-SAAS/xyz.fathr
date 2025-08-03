// ArticleContent.swift
import Foundation

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let content: String
}

struct ArticleContent {
    static let articles: [Article] = [
        Article(
            title: "The 5 Daily Habits That Supercharge Your Sperm",
            description: "Simple lifestyle tweaks you can start today to boost sperm quality, naturally.",
            imageName: "articleimage1",
            content: """
            Improving your fertility doesn’t require drastic changes. *Small, consistent habits* can significantly boost your sperm count, quality, and motility, helping you conceive naturally.

            Here’s how to get started:

            Stay Hydrated
            Water is critical for sperm health. Dehydration reduces semen volume, meaning fewer sperm reach their destination. 
            
            *Aim for 2–3 liters daily* (more if you’re active). Keep a water bottle handy to make hydration effortless.

            Move Your Body, But Don’t Overdo It
            Regular exercise improves blood flow to reproductive organs, supporting testosterone and sperm production. A brisk 30-minute walk, bodyweight exercises, or cycling works wonders.
            
            *Avoid overtraining*, like intense marathons, which can raise cortisol and lower testosterone.

            Eat for Fertility, Not Just Fuel
            Your sperm thrive on nutrients. A diet rich in key foods can enhance their performance:
            - Leafy greens like spinach (*packed with folate*)
            - Nuts and seeds (*zinc and omega-3s*)
            - Berries (*antioxidants to protect sperm DNA*)
            - Eggs (*protein and choline*)

            *Focus on adding nutrients*, not just cutting out junk.

            Prioritize Deep, Consistent Sleep
            Testosterone, vital for sperm production, peaks during sleep. Skimping on rest—less than 6 hours—can lower your levels.
            
            *Aim for 7–8 hours* with a routine: no screens 30 minutes before bed, a cool, dark room, and consistent sleep times.

            Take Stress Seriously
            Chronic stress spikes cortisol, which suppresses testosterone. Just 5–10 minutes of deep breathing, a walk, or journaling can reset your system.
            
            *Small stress-relief habits* make a big difference over time.

            Bottom Line
            These habits are simple, accessible, and proven. *Start with one today*, and your future family will thank you.

            *This article is for informational purposes only and is not medical advice. Consult a doctor for personalized guidance.*
            """
        ),
        Article(
            title: "What a Healthy Sperm Diet Looks Like",
            description: "Eat your way to stronger swimmers.",
            imageName: "articleimage2",
            content: """
            Your diet today shapes your sperm 2–3 months from now—the time it takes to produce a new batch. *What you eat matters* for stronger, healthier sperm.

            Here are five dietary changes to boost your fertility:

            Zinc for Sperm Count & Movement
            Zinc fuels testosterone and sperm production. 
            *Add these to your plate*: oysters, pumpkin seeds, chickpeas, beef, cashews.

            Omega-3 Fats for Sperm Movement
            Omega-3s make sperm more flexible, improving their swimming ability. 
            *Try these*: salmon, sardines, walnuts, flaxseeds, or a fish oil supplement.

            Folate & B Vitamins for Healthy DNA
            These nutrients protect sperm DNA from damage. 
            *Eat more*: spinach, lentils, avocados, eggs, asparagus.

            Antioxidants to Protect Sperm
            Antioxidants shield sperm from toxins and oxidative stress. 
            *Stock up on*: berries, oranges, almonds, Brazil nuts, olive oil.

            Skip Processed Foods
            Junk food harms sperm count and motility. 
            *Swap soda, chips, and fried foods* for whole foods, good fats, and lean proteins.

            *Small changes now* can lead to big results in a few months. Start eating for fertility today.

            *This article is for informational purposes only and is not medical advice. Consult a doctor for personalized guidance.*
            """
        ),
        Article(
            title: "Fertility Test Results: What’s Normal and What’s Not",
            description: "Understand your semen analysis so you know where you stand.",
            imageName: "articleimage3",
            content: """
            A semen analysis can feel overwhelming, but those numbers tell a clear story about your fertility. *Understanding them* empowers you to take action.

            Here’s what the key metrics mean:

            Sperm Count
            This measures sperm per milliliter of semen. 
            *Healthy range*: at least 15 million per mL, ideally 20–40 million.

            Motility (Movement)
            This shows how many sperm are swimming effectively. 
            *Target*: at least 40% moving, with 32% swimming forward to reach the egg.

            Morphology (Shape)
            This indicates the percentage of sperm with normal shape. 
            *Goal*: 4% or more, as misshapen sperm are less effective.

            Semen Volume
            This is the amount of ejaculate. 
            *Normal*: 1.4 mL or more. Lower volume means fewer sperm.

            DNA Fragmentation
            This checks sperm DNA quality. 
            *Ideal*: below 15%. Higher levels can reduce conception chances.

            *Your results aren’t the final word*. Many men with lower numbers still conceive. Use this data to guide improvements.

            *This article is for informational purposes only and is not medical advice. Consult a doctor for personalized guidance.*
            """
        ),
        Article(
            title: "7 Hidden Habits That Hurt Your Fertility",
            description: "Everyday habits could be hurting your fertility — here’s how to fix them.",
            imageName: "articleimage4",
            content: """
            Some daily habits silently harm your sperm. *The good news?* Most are easy to change.

            Here are seven habits to avoid:

            1. Heat
            Testicles need to stay cool for optimal sperm production. 
            *Avoid*: hot tubs, saunas, or laptops on your lap. Use a desk or table instead.

            2. Smoking & Vaping
            Tobacco and vape chemicals damage sperm DNA and reduce count. 
            *Quitting* is one of the best steps for fertility.

            3. Too Much Alcohol
            Heavy drinking lowers testosterone and sperm quality. 
            *Limit to*: 1–2 drinks per week or take a break entirely.

            4. Tight Underwear
            Tight briefs trap heat, harming sperm. 
            *Switch to*: loose boxers for better airflow.

            5. Junk Food
            Fast food and sugary snacks reduce sperm count and motility. 
            *Choose*: whole foods and healthy fats instead.

            6. Chemicals
            Plastics (like BPA), pesticides, and cleaning chemicals disrupt hormones. 
            *Minimize exposure*: use glass containers and wash produce thoroughly.

            7. Stress
            Chronic stress raises cortisol, lowering sperm production. 
            *Try*: 5–10 minutes of walking, meditation, or deep breathing daily.

            *Small tweaks* can protect your sperm and boost your fertility.

            *This article is for informational purposes only and is not medical advice. Consult a doctor for personalized guidance.*
            """
        ),
        Article(
            title: "How to Talk to Your Partner About Fertility",
            description: "It’s not always easy—but it’s always worth it.",
            imageName: "articleimage5",
            content: """
            Discussing fertility can feel daunting—awkward, emotional, or even scary. *Open, honest talks* with your partner build trust and teamwork, especially when trying to conceive.

            Here’s how to approach it:

            Choose the Right Moment
            Pick a calm, private setting—like a quiet walk or cozy evening at home. 
            *Avoid rushed or stressful times* to keep the conversation relaxed.

            Start Simply
            Ease into the topic with a gentle opener. 
            *Try saying*: “I’ve been thinking about our fertility and wanted to share what I’ve learned.”

            Focus on Facts, Not Blame
            Share your health updates, test results, or lifestyle changes. 
            *Be open*: encourage your partner to share their thoughts too.

            Listen Actively
            Give your partner space to respond. *Really listen* to their feelings or concerns without judgment.

            Keep the Conversation Going
            Fertility talks aren’t one-and-done. 
            *Check in regularly*: discuss feelings, plans, or next steps like seeing a doctor together.

            *Honesty and teamwork* lay the foundation for a strong family. You’ve got this.

            *This article is for informational purposes only and is not medical advice. Consult a doctor for personalized guidance.*
            """
        )
    ]
}
