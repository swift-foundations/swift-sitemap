import Foundation
import Testing

@testable import Sitemap

@Suite("README Verification")
struct ReadmeVerificationTests {

    @Test("Quick Start example from README lines 28-49")
    func quickStartExample() throws {

        let urls = [
            Sitemap.URL(
                location: try #require(URL(string: "https://example.com")),
                lastModification: Date(timeIntervalSince1970: 1_700_000_000),
                changeFrequency: .daily,
                priority: 1.0
            ),
            Sitemap.URL(
                location: try #require(URL(string: "https://example.com/about")),
                changeFrequency: .monthly,
                priority: 0.8
            ),
        ]

        let sitemap = Sitemap(urls: urls)
        let xmlString = sitemap.xml

        #expect(!xmlString.isEmpty)
        #expect(xmlString.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(
            xmlString.contains("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">")
        )
        #expect(xmlString.contains("https://example.com"))
        #expect(xmlString.contains("https://example.com/about"))
    }

    @Test("Router-based generation example from README lines 57-78")
    func routerBasedExample() throws {
        enum Page {
            case home, about, contact
        }

        let router: (Page) -> URL = { page in
            switch page {
            case .home: return URL(string: "https://example.com")!
            case .about: return URL(string: "https://example.com/about")!
            case .contact: return URL(string: "https://example.com/contact")!
            }
        }

        let metadata: [Page: Sitemap.URL.MetaData] = [
            .home: Sitemap.URL.MetaData(changeFrequency: .daily, priority: 1.0),
            .about: Sitemap.URL.MetaData(changeFrequency: .monthly, priority: 0.8),
            .contact: Sitemap.URL.MetaData(changeFrequency: .yearly, priority: 0.5),
        ]

        let urls = [Sitemap.URL](router: router, metadata)
        let sitemap = Sitemap(urls: urls)

        #expect(urls.count == 3)
        #expect(sitemap.urls.count == 3)

        let locations = Set(sitemap.urls.map(\.location.absoluteString))
        #expect(locations.contains("https://example.com"))
        #expect(locations.contains("https://example.com/about"))
        #expect(locations.contains("https://example.com/contact"))
    }

    @Test("Generated XML format from README lines 85-99")
    func generatedXMLFormat() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let specificDate = dateFormatter.date(from: "2025-01-15")!

        let urls = [
            Sitemap.URL(
                location: try #require(URL(string: "https://example.com")),
                lastModification: specificDate,
                changeFrequency: .daily,
                priority: 1.0
            ),
            Sitemap.URL(
                location: try #require(URL(string: "https://example.com/about")),
                changeFrequency: .monthly,
                priority: 0.8
            ),
        ]

        let sitemap = Sitemap(urls: urls)
        let xml = sitemap.xml

        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"))
        #expect(xml.contains("<url>"))
        #expect(xml.contains("<loc>https://example.com</loc>"))
        #expect(xml.contains("<lastmod>2025-01-15</lastmod>"))
        #expect(xml.contains("<changefreq>daily</changefreq>"))
        #expect(xml.contains("<priority>1.0</priority>"))
        #expect(xml.contains("</url>"))
        #expect(xml.contains("<loc>https://example.com/about</loc>"))
        #expect(xml.contains("<changefreq>monthly</changefreq>"))
        #expect(xml.contains("<priority>0.8</priority>"))
        #expect(xml.contains("</urlset>"))
    }

    @Test("API Reference - Sitemap init from README line 107")
    func sitemapInit() throws {
        let url = try #require(URL(string: "https://example.com"))
        let sitemapURL = Sitemap.URL(location: url)

        let sitemap = Sitemap(urls: [sitemapURL])

        #expect(sitemap.urls.count == 1)
        #expect(sitemap.urls.first?.location == url)
    }

    @Test("API Reference - Sitemap xml property from README line 108")
    func sitemapXMLProperty() throws {
        let url = try #require(URL(string: "https://example.com"))
        let sitemapURL = Sitemap.URL(location: url)
        let sitemap = Sitemap(urls: [sitemapURL])

        let xmlString = sitemap.xml

        #expect(!xmlString.isEmpty)
        #expect(xmlString.contains("<?xml"))
        #expect(xmlString is String)
    }

    @Test("API Reference - Sitemap.URL properties from README lines 113-115")
    func sitemapURLProperties() throws {
        let url = try #require(URL(string: "https://example.com"))
        let metadata = Sitemap.URL.MetaData(
            lastModification: Date(timeIntervalSince1970: 1_700_000_000),
            changeFrequency: .daily,
            priority: 0.8
        )

        let sitemapURL = Sitemap.URL(
            location: url,
            lastModification: metadata.lastModification,
            changeFrequency: metadata.changeFrequency,
            priority: metadata.priority
        )

        #expect(sitemapURL.location == url)

        #expect(sitemapURL.metadata.lastModification == metadata.lastModification)
        #expect(sitemapURL.metadata.changeFrequency == metadata.changeFrequency)
        #expect(sitemapURL.metadata.priority == metadata.priority)
    }

    @Test("API Reference - MetaData properties from README lines 119-123")
    func metadataProperties() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let frequency = Sitemap.URL.ChangeFrequency.weekly
        let priority: Float = 0.7

        let metadata = Sitemap.URL.MetaData(
            lastModification: date,
            changeFrequency: frequency,
            priority: priority
        )

        #expect(metadata.lastModification == date)
        #expect(metadata.changeFrequency == frequency)
        #expect(metadata.priority == priority)
    }

    @Test("API Reference - ChangeFrequency enum values from README line 128")
    func changeFrequencyValues() {

        _ = Sitemap.URL.ChangeFrequency.always
        _ = Sitemap.URL.ChangeFrequency.hourly
        _ = Sitemap.URL.ChangeFrequency.daily
        _ = Sitemap.URL.ChangeFrequency.weekly
        _ = Sitemap.URL.ChangeFrequency.monthly
        _ = Sitemap.URL.ChangeFrequency.yearly
        _ = Sitemap.URL.ChangeFrequency.never

        #expect(Sitemap.URL.ChangeFrequency.always.rawValue == "always")
        #expect(Sitemap.URL.ChangeFrequency.hourly.rawValue == "hourly")
        #expect(Sitemap.URL.ChangeFrequency.daily.rawValue == "daily")
        #expect(Sitemap.URL.ChangeFrequency.weekly.rawValue == "weekly")
        #expect(Sitemap.URL.ChangeFrequency.monthly.rawValue == "monthly")
        #expect(Sitemap.URL.ChangeFrequency.yearly.rawValue == "yearly")
        #expect(Sitemap.URL.ChangeFrequency.never.rawValue == "never")
    }
}
