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
            You don’t need to turn your life upside down to improve your fertility.

            Most men are surprised to learn that better sperm health starts with small, everyday habits. When practiced consistently, they can boost your count, quality, and motility — and give you the confidence to conceive naturally.

            Here’s what that looks like:

            Stay Hydrated
            Water plays a bigger role than you think. Dehydration doesn’t just affect your energy levels — it also lowers semen volume. That means fewer sperm are carried during ejaculation. Aim for 2 to 3 liters per day (more if you’re active). Carrying a water bottle makes it easier to keep sipping without thinking about it.

            Move Your Body, But Don’t Overdo It
            Regular movement supports healthy blood flow to the reproductive organs, which helps with testosterone production and sperm creation. You don’t have to hit the gym hard — even 30 minutes of walking, bodyweight exercises, or cycling is enough. Just avoid excessive, high-intensity workouts or long endurance training (like running marathons weekly), which can increase stress hormones like cortisol and decrease testosterone.

            Eat for Fertility, Not Just Fuel
            Your sperm need nutrients just like the rest of your body. What you eat directly affects how well they form and function. Try adding more of these to your plate:
            - Leafy greens like spinach (rich in folate)
            - Nuts and seeds (zinc, selenium, omega-3s)
            - Berries (antioxidants that fight sperm DNA damage)
            - Eggs (a good source of protein and choline)

            Fertility isn’t about cutting everything out — it’s about putting more of the right things in.

            Prioritize Deep, Consistent Sleep
            Sleep is when your body rebuilds. Testosterone — the hormone that drives sperm production — is made mostly at night. Less than 6 hours of sleep? Your levels can drop. Aim for 7–8 hours of uninterrupted sleep. Try a simple night routine: no screens 30 minutes before bed, keep the room cool and dark, and go to bed at the same time each night.

            Take Stress Seriously
            Stress affects everything — from your mood to your hormones. When you’re under pressure for too long, your body produces more cortisol, which lowers testosterone. You don’t need to meditate for an hour. Just 5 to 10 minutes a day of breathing exercises, walking outside, or journaling can shift your nervous system back into balance.

            Bottom line?
            You already have the tools. These habits don’t require a gym membership, a new diet, or a prescription. They’re simple, repeatable, and proven to make a difference.

            Start with one. Then build from there. Your future family will thank you.
            """
        ),
        Article(
            title: "What a Healthy Sperm Diet Looks Like",
            description: "Eat your way to stronger swimmers.",
            imageName: "articleimage2",
            content: """
            Most guys don’t know this, but what you eat today affects your sperm 2–3 months from now. That’s how long it takes your body to make a new batch. What you put in your body during that time can make your sperm stronger—or weaker.

            Here are five important changes you can make to your diet to help boost your fertility:

            🧠 Zinc for Sperm Count & Movement
            Zinc helps your body make testosterone and healthy sperm.
            Eat more: Oysters, pumpkin seeds, chickpeas, beef, cashews.

            🐟 Omega-3 Fats for Sperm Movement
            These fats make sperm more flexible so they can swim better.
            Eat more: Salmon, sardines, walnuts, flaxseeds—or take a fish oil supplement.

            🌿 Folate & B Vitamins for Healthy DNA
            These protect the DNA inside your sperm.
            Eat more: Spinach, lentils, avocados, eggs, asparagus.

            🍊 Antioxidants to Protect Sperm
            They stop damage from toxins in your body.
            Eat more: Berries, oranges, almonds, Brazil nuts, olive oil.

            🚫 Skip Processed Foods
            Junk food lowers sperm count and movement.
            Avoid: Soda, chips, fried food.
            Eat instead: Whole foods, good fats, lean protein.

            Even small changes in your diet can help. What you eat today could help you become a dad tomorrow.
            """
        ),
        Article(
            title: "Fertility Test Results: What’s Normal and What’s Not",
            description: "Understand your semen analysis so you know where you stand.",
            imageName: "articleimage3",
            content: """
            Getting a semen test can be stressful. Then you get the results—and it’s just a bunch of numbers. But those numbers tell you something important: how strong your fertility is right now, and where there’s room to improve.

            Here’s what those numbers usually mean:

            Sperm Count
            This is how many sperm are in one milliliter of semen. A healthy number is at least 15 million per mL, but 20–40 million is better.

            Motility (Movement)
            This tells you how many sperm are actually swimming. At least 40% should be moving, and 32% should be swimming forward. Sperm need to move to reach the egg.

            Morphology (Shape)
            This shows what percent of sperm have the right shape. A good number is 4% or more. Strange-looking sperm don’t work as well.

            Semen Volume
            This is how much you ejaculate. Normal is around 1.4 mL or more. Less volume means fewer sperm.

            DNA Fragmentation
            This checks the quality of sperm DNA. You want this number low—ideally under 15%. High levels can make it harder to get pregnant.

            These numbers are not the final word. Many guys with low numbers still become dads. What matters is using the info to make changes and keep improving.
            """
        ),
        Article(
            title: "7 Hidden Habits That Hurt Your Fertility",
            description: "Everyday habits could be hurting your fertility — here’s how to fix them.",
            imageName: "articleimage4",
            content: """
            You might not notice it, but some everyday things can hurt your sperm without you even realizing it. The good news? You can change most of them.

            1. Heat
            Your testicles need to stay cool. Hot tubs, saunas, or even laptops on your lap raise the heat and hurt sperm. Keep devices off your lap and avoid long hot baths.

            2. Smoking & Vaping
            Tobacco and vape chemicals lower sperm count and damage sperm DNA. Quitting is one of the best ways to boost fertility.

            3. Too Much Alcohol
            Heavy drinking lowers testosterone and sperm quality. Stick to 1–2 drinks per week, or take a break from alcohol.

            4. Tight Underwear
            Tight briefs trap heat. Go for loose boxers instead.

            5. Junk Food
            Fast food and sugary snacks lower sperm count and motility. Eat more whole foods and healthy fats.

            6. Chemicals
            Plastics (like BPA), pesticides, and cleaning chemicals can mess with your hormones. Avoid plastic containers and wash fruits and veggies well.

            7. Stress
            Stress raises cortisol, which lowers sperm production. Take time to relax—walk, exercise, meditate, or just breathe.

            Small changes can make a big difference. Avoid the bad stuff and your sperm will thank you.
            """
        ),
        Article(
            title: "How to Talk to Your Partner About Fertility",
            description: "It’s not always easy—but it’s always worth it.",
            imageName: "articleimage5",
            content: """
            Talking about fertility isn’t always simple. It can feel awkward, scary, or even emotional. But having open and honest conversations with your partner is one of the best things you can do—especially if you’re trying to start a family.

            Pick a calm, private time when you both feel relaxed—like during a quiet walk or evening together.

            Start with something simple like,
            “I’ve been thinking about our fertility and wanted to share what I’ve learned.”

            Stick to facts, not blame. Talk about your health, your test results, or what changes you’re trying to make. Then give your partner space to respond. Really listen.

            This isn’t a one-time talk. Keep checking in with each other. Talk about how you’re feeling. Make plans together—like visiting a doctor or improving your health as a team.

            You don’t have to be perfect. Just honest. Every strong family starts with strong communication.
            """
        )
    ]
}
