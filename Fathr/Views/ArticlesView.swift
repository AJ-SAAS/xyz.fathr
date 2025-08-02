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

            Text(article.title)
                .font(.system(size: 19, design: .rounded)) // 19pt as previously updated
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(2)

            Text(article.description)
                .font(.system(size: 14, design: .rounded)) // 14pt as previously updated
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

    // List of headings to be bolded for the first article
    private let boldHeadings = [
        "Stay Hydrated",
        "Move Your Body, But Don’t Overdo It",
        "Eat for Fertility, Not Just Fuel",
        "Prioritize Deep, Consistent Sleep",
        "Take Stress Seriously",
        "Bottom line?"
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

                    // Split content into lines and apply bold to headings
                    ForEach(article.content.split(separator: "\n").map { String($0) }, id: \.self) { line in
                        Text(line)
                            .font(.body)
                            .fontDesign(.rounded)
                            .foregroundColor(.black)
                            .fontWeight(boldHeadings.contains(line) ? .bold : .regular)
                            .padding(.horizontal)
                            .padding(.vertical, line == "" ? 4 : 0) // Add spacing for empty lines
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
