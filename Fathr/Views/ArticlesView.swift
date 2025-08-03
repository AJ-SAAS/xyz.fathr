// ArticlesView.swift
import SwiftUI

struct ArticlesView: View {
    @State private var selectedArticle: Article? // Tracks the article to show in pop-up
    @Environment(\.colorScheme) var colorScheme // For light/dark mode support

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Articles")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal)

            VStack(spacing: 16) {
                ForEach(ArticleContent.articles) { article in
                    ArticleCardView(article: article)
                        .onTapGesture {
                            selectedArticle = article
                        }
                        .accessibilityLabel("Article: \(article.title)")
                }
            }
            .padding(.horizontal)
        }
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(article: article)
        }
    }
}

struct ArticleCardView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(article.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .accessibilityLabel("Image for article: \(article.title)")

            Text(article.title)
                .font(.system(size: 19, design: .rounded)) // 19pt
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(2)

            Text(article.description)
                .font(.system(size: 14, design: .rounded)) // 14pt
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) var dismiss

    // List of headings to be bolded for all articles
    private let boldHeadings = [
        // Article 1: The 5 Daily Habits That Supercharge Your Sperm
        "Stay Hydrated",
        "Move Your Body, But Don’t Overdo It",
        "Eat for Fertility, Not Just Fuel",
        "Prioritize Deep, Consistent Sleep",
        "Take Stress Seriously",
        "Bottom Line",
        // Article 2: What a Healthy Sperm Diet Looks Like
        "Zinc for Sperm Count & Movement",
        "Omega-3 Fats for Sperm Movement",
        "Folate & B Vitamins for Healthy DNA",
        "Antioxidants to Protect Sperm",
        "Skip Processed Foods",
        // Article 3: Fertility Test Results: What’s Normal and What’s Not
        "Sperm Count",
        "Motility (Movement)",
        "Morphology (Shape)",
        "Semen Volume",
        "DNA Fragmentation",
        // Article 4: 7 Hidden Habits That Hurt Your Fertility
        "1. Heat",
        "2. Smoking & Vaping",
        "3. Too Much Alcohol",
        "4. Tight Underwear",
        "5. Junk Food",
        "6. Chemicals",
        "7. Stress",
        // Article 5: How to Talk to Your Partner About Fertility
        "Choose the Right Moment",
        "Start Simply",
        "Focus on Facts, Not Blame",
        "Listen Actively",
        "Keep the Conversation Going"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image(article.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        .accessibilityLabel("Image for article: \(article.title)")

                    Text(article.title)
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)

                    Text(article.description)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    // Split content into lines and apply bold/italic styling
                    ForEach(article.content.split(separator: "\n").map { String($0) }, id: \.self) { line in
                        let isItalic = line.hasPrefix("*")
                        let cleanLine = isItalic ? String(line.dropFirst()) : line
                        Text(cleanLine)
                            .font(.body)
                            .fontDesign(.rounded)
                            .foregroundColor(.black)
                            .fontWeight(boldHeadings.contains(cleanLine) ? .bold : .regular)
                            .italic(isItalic)
                            .padding(.horizontal)
                            .padding(.vertical, cleanLine == "" ? 4 : 0) // Add spacing for empty lines
                    }
                }
                .padding(.vertical)
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            )
        }
    }
}

struct ArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        ArticlesView()
    }
}
