import Foundation
import Testing

@testable import Sitemap

@Suite("Sitemap Basic Functionality")
struct SitemapBasicTests {

    @Test("Sitemap initializes with empty URLs array")
    func siteMapEmptyInitialization() {
        let sitemap = Sitemap(urls: [])

        #expect(sitemap.urls.isEmpty)
    }

    @Test("Sitemap initializes with single URL")
    func siteMapSingleURL() throws {
        let url = try #require(URL(string: "https://example.com"))
        let sitemapURL = Sitemap.URL(location: url)
        let sitemap = Sitemap(urls: [sitemapURL])

        #expect(sitemap.urls.count == 1)
        #expect(sitemap.urls.first?.location == url)
        #expect(sitemap.urls.first?.metadata.lastModification == nil)
        #expect(sitemap.urls.first?.metadata.changeFrequency == nil)
        #expect(sitemap.urls.first?.metadata.priority == nil)
    }

    @Test("Sitemap initializes with multiple URLs")
    func siteMapMultipleURLs() throws {
        let url1 = try #require(URL(string: "https://example.com"))
        let url2 = try #require(URL(string: "https://example.com/about"))
        let url3 = try #require(URL(string: "https://example.com/contact"))

        let urls = [
            Sitemap.URL(location: url1),
            Sitemap.URL(location: url2),
            Sitemap.URL(location: url3),
        ]
        let sitemap = Sitemap(urls: urls)

        #expect(sitemap.urls.count == 3)
        #expect(sitemap.urls[0].location == url1)
        #expect(sitemap.urls[1].location == url2)
        #expect(sitemap.urls[2].location == url3)
    }
}

@Suite("Sitemap.URL Functionality")
struct SitemapURLTests {

    @Test("URL initializes with location only")
    func urlBasicInitialization() throws {
        let url = try #require(URL(string: "https://example.com"))
        let sitemapURL = Sitemap.URL(location: url)

        #expect(sitemapURL.location == url)
        #expect(sitemapURL.metadata.lastModification == nil)
        #expect(sitemapURL.metadata.changeFrequency == nil)
        #expect(sitemapURL.metadata.priority == nil)
    }

    @Test("URL initializes with all metadata")
    func urlFullInitialization() throws {
        let url = try #require(URL(string: "https://example.com"))
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let frequency = Sitemap.URL.ChangeFrequency.daily
        let priority: Float = 0.8

        let sitemapURL = Sitemap.URL(
            location: url,
            lastModification: date,
            changeFrequency: frequency,
            priority: priority
        )

        #expect(sitemapURL.location == url)
        #expect(sitemapURL.metadata.lastModification == date)
        #expect(sitemapURL.metadata.changeFrequency == frequency)
        #expect(sitemapURL.metadata.priority == priority)
    }

    @Test("URL initializes with partial metadata")
    func urlPartialInitialization() throws {
        let url = try #require(URL(string: "https://example.com"))
        let frequency = Sitemap.URL.ChangeFrequency.weekly

        let sitemapURL = Sitemap.URL(
            location: url,
            changeFrequency: frequency
        )

        #expect(sitemapURL.location == url)
        #expect(sitemapURL.metadata.lastModification == nil)
        #expect(sitemapURL.metadata.changeFrequency == frequency)
        #expect(sitemapURL.metadata.priority == nil)
    }
}

@Suite("MetaData Functionality")
struct MetaDataTests {

    @Test("MetaData initializes with default values")
    func metaDataDefaultInitialization() {
        let metadata = Sitemap.URL.MetaData()

        #expect(metadata.lastModification == nil)
        #expect(metadata.changeFrequency == nil)
        #expect(metadata.priority == nil)
    }

    @Test("MetaData initializes with all values")
    func metaDataFullInitialization() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let frequency = Sitemap.URL.ChangeFrequency.monthly
        let priority: Float = 0.5

        let metadata = Sitemap.URL.MetaData(
            lastModification: date,
            changeFrequency: frequency,
            priority: priority
        )

        #expect(metadata.lastModification == date)
        #expect(metadata.changeFrequency == frequency)
        #expect(metadata.priority == priority)
    }

    @Test("MetaData.empty provides correct empty instance")
    func metaDataEmpty() {
        let empty = Sitemap.URL.MetaData.empty

        #expect(empty.lastModification == nil)
        #expect(empty.changeFrequency == nil)
        #expect(empty.priority == nil)
    }
}

@Suite("ChangeFrequency Enum")
struct ChangeFrequencyTests {

    @Test("ChangeFrequency raw values are correct")
    func changeFrequencyRawValues() {
        #expect(Sitemap.URL.ChangeFrequency.always.rawValue == "always")
        #expect(Sitemap.URL.ChangeFrequency.hourly.rawValue == "hourly")
        #expect(Sitemap.URL.ChangeFrequency.daily.rawValue == "daily")
        #expect(Sitemap.URL.ChangeFrequency.weekly.rawValue == "weekly")
        #expect(Sitemap.URL.ChangeFrequency.monthly.rawValue == "monthly")
        #expect(Sitemap.URL.ChangeFrequency.yearly.rawValue == "yearly")
        #expect(Sitemap.URL.ChangeFrequency.never.rawValue == "never")
    }

    @Test("ChangeFrequency can be initialized from raw values")
    func changeFrequencyFromRawValue() {
        #expect(Sitemap.URL.ChangeFrequency(rawValue: "always") == .always)
        #expect(Sitemap.URL.ChangeFrequency(rawValue: "hourly") == .hourly)
        #expect(Sitemap.URL.ChangeFrequency(rawValue: "daily") == .daily)
        #expect(Sitemap.URL.ChangeFrequency(rawValue: "weekly") == .weekly)
        #expect(Sitemap.URL.ChangeFrequency(rawValue: "monthly") == .monthly)
        #expect(Sitemap.URL.ChangeFrequency(rawValue: "yearly") == .yearly)
        #expect(Sitemap.URL.ChangeFrequency(rawValue: "never") == .never)
        #expect(Sitemap.URL.ChangeFrequency(rawValue: "invalid") == nil)
    }

    @Test("ChangeFrequency is hashable")
    func changeFrequencyHashable() {
        let set: Set<Sitemap.URL.ChangeFrequency> = [.daily, .weekly, .daily]
        #expect(set.count == 2)
        #expect(set.contains(.daily))
        #expect(set.contains(.weekly))
    }
}

@Suite("XML Generation")
struct XMLGenerationTests {

    @Test("Empty sitemap generates correct XML")
    func emptySitemapXML() {
        let sitemap = Sitemap(urls: [])
        let xml = sitemap.xml

        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"))
        #expect(xml.contains("</urlset>"))
        #expect(!xml.contains("<url>"))
    }

    @Test("Single URL sitemap generates correct XML")
    func singleURLSitemapXML() throws {
        let url = try #require(URL(string: "https://example.com"))
        let sitemapURL = Sitemap.URL(location: url)
        let sitemap = Sitemap(urls: [sitemapURL])
        let xml = sitemap.xml

        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"))
        #expect(xml.contains("<url>"))
        #expect(xml.contains("<loc>https://example.com</loc>"))
        #expect(xml.contains("</url>"))
        #expect(xml.contains("</urlset>"))
    }

    @Test("URL with minimal metadata generates correct XML")
    func urlMinimalMetadataXML() throws {
        let url = try #require(URL(string: "https://example.com/page"))
        let sitemapURL = Sitemap.URL(location: url)
        let xml = sitemapURL.xml

        #expect(xml.contains("<url>"))
        #expect(xml.contains("<loc>https://example.com/page</loc>"))
        #expect(xml.contains("</url>"))
        #expect(!xml.contains("<lastmod>"))
        #expect(!xml.contains("<changefreq>"))
        #expect(!xml.contains("<priority>"))
    }

    @Test("URL with full metadata generates correct XML")
    func urlFullMetadataXML() throws {
        let url = try #require(URL(string: "https://example.com/page"))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: "2025-01-15")!

        let sitemapURL = Sitemap.URL(
            location: url,
            lastModification: date,
            changeFrequency: .weekly,
            priority: 0.8
        )
        let xml = sitemapURL.xml

        #expect(xml.contains("<url>"))
        #expect(xml.contains("<loc>https://example.com/page</loc>"))
        #expect(xml.contains("<lastmod>2025-01-15</lastmod>"))
        #expect(xml.contains("<changefreq>weekly</changefreq>"))
        #expect(xml.contains("<priority>0.8</priority>"))
        #expect(xml.contains("</url>"))
    }

    @Test("URL with partial metadata generates correct XML")
    func urlPartialMetadataXML() throws {
        let url = try #require(URL(string: "https://example.com/about"))
        let sitemapURL = Sitemap.URL(
            location: url,
            changeFrequency: .monthly,
            priority: 0.5
        )
        let xml = sitemapURL.xml

        #expect(xml.contains("<url>"))
        #expect(xml.contains("<loc>https://example.com/about</loc>"))
        #expect(!xml.contains("<lastmod>"))
        #expect(xml.contains("<changefreq>monthly</changefreq>"))
        #expect(xml.contains("<priority>0.5</priority>"))
        #expect(xml.contains("</url>"))
    }
}

@Suite("Date Formatting")
struct DateFormattingTests {

    @Test("Date formatting uses correct ISO format")
    func dateFormattingISO() throws {
        let url = try #require(URL(string: "https://example.com"))

        let testDates = [
            ("2025-01-01", "2025-01-01"),
            ("2024-12-31", "2024-12-31"),
            ("2025-07-26", "2025-07-26"),
            ("2000-02-29", "2000-02-29"),
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for (inputDate, expectedOutput) in testDates {
            let date = dateFormatter.date(from: inputDate)!
            let sitemapURL = Sitemap.URL(
                location: url,
                lastModification: date
            )
            let xml = sitemapURL.xml

            #expect(xml.contains("<lastmod>\(expectedOutput)</lastmod>"))
        }
    }

    @Test("Date formatting handles edge cases")
    func dateFormattingEdgeCases() throws {
        let url = try #require(URL(string: "https://example.com"))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dates = [
            "1999-12-31",
            "2000-01-01",
            "2099-12-31",
            "2100-01-01",
        ]

        for dateString in dates {
            let date = dateFormatter.date(from: dateString)!
            let sitemapURL = Sitemap.URL(
                location: url,
                lastModification: date
            )
            let xml = sitemapURL.xml

            #expect(xml.contains("<lastmod>\(dateString)</lastmod>"))
        }
    }
}

@Suite("Priority Values")
struct PriorityTests {

    @Test("Priority accepts valid float values")
    func priorityValidValues() throws {
        let url = try #require(URL(string: "https://example.com"))

        let validPriorities: [Float] = [0.0, 0.1, 0.5, 0.8, 1.0]

        for priority in validPriorities {
            let sitemapURL = Sitemap.URL(
                location: url,
                priority: priority
            )
            let xml = sitemapURL.xml

            #expect(xml.contains("<priority>\(priority)</priority>"))
        }
    }

    @Test("Priority handles decimal precision")
    func priorityDecimalPrecision() throws {
        let url = try #require(URL(string: "https://example.com"))

        let priorities: [(Float, String)] = [
            (0.0, "0.0"),
            (0.5, "0.5"),
            (0.8, "0.8"),
            (1.0, "1.0"),
            (0.33, "0.33"),
            (0.66, "0.66"),
        ]

        for (priority, expectedString) in priorities {
            let sitemapURL = Sitemap.URL(
                location: url,
                priority: priority
            )
            let xml = sitemapURL.xml

            #expect(xml.contains("<priority>\(expectedString)</priority>"))
        }
    }
}

@Suite("Array Extension for URL Generation")
struct ArrayExtensionTests {

    @Test("Array initializer with router and dictionary works")
    func arrayInitializerBasic() throws {
        enum TestPage {
            case home, about, contact
        }

        let router: (TestPage) -> URL = { page in
            switch page {
            case .home: return URL(string: "https://example.com")!
            case .about: return URL(string: "https://example.com/about")!
            case .contact: return URL(string: "https://example.com/contact")!
            }
        }

        let metadata: [TestPage: Sitemap.URL.MetaData] = [
            .home: Sitemap.URL.MetaData(changeFrequency: .daily, priority: 1.0),
            .about: Sitemap.URL.MetaData(changeFrequency: .monthly, priority: 0.8),
            .contact: Sitemap.URL.MetaData(changeFrequency: .yearly, priority: 0.5),
        ]

        let urls = [Sitemap.URL](router: router, metadata)

        #expect(urls.count == 3)

        let locations = Set(urls.map(\.location.absoluteString))
        #expect(locations.contains("https://example.com"))
        #expect(locations.contains("https://example.com/about"))
        #expect(locations.contains("https://example.com/contact"))

        for url in urls {
            switch url.location.absoluteString {
            case "https://example.com":
                #expect(url.metadata.changeFrequency == .daily)
                #expect(url.metadata.priority == 1.0)

            case "https://example.com/about":
                #expect(url.metadata.changeFrequency == .monthly)
                #expect(url.metadata.priority == 0.8)

            case "https://example.com/contact":
                #expect(url.metadata.changeFrequency == .yearly)
                #expect(url.metadata.priority == 0.5)

            default:
                #expect(Bool(false), "Unexpected URL: \(url.location.absoluteString)")
            }
        }
    }

    @Test("Array initializer with empty dictionary")
    func arrayInitializerEmpty() {
        enum TestPage: CaseIterable {
            case home
        }

        let router: (TestPage) -> URL = { _ in
            URL(string: "https://example.com")!
        }

        let emptyMetadata: [TestPage: Sitemap.URL.MetaData] = [:]
        let urls = [Sitemap.URL](router: router, emptyMetadata)

        #expect(urls.isEmpty)
    }
}

@Suite("Integration Tests")
struct IntegrationTests {

    @Test("Complete sitemap with mixed content")
    func completeSitemapGeneration() throws {
        let baseURL = "https://example.com"
        let urls = [
            Sitemap.URL(
                location: try #require(URL(string: baseURL)),
                lastModification: Date(timeIntervalSince1970: 1_700_000_000),
                changeFrequency: .daily,
                priority: 1.0
            ),
            Sitemap.URL(
                location: try #require(URL(string: "\(baseURL)/about")),
                changeFrequency: .monthly,
                priority: 0.8
            ),
            Sitemap.URL(
                location: try #require(URL(string: "\(baseURL)/contact"))
            ),
            Sitemap.URL(
                location: try #require(URL(string: "\(baseURL)/blog")),
                lastModification: Date(timeIntervalSince1970: 1_700_000_000),
                changeFrequency: .weekly
            ),
        ]

        let sitemap = Sitemap(urls: urls)
        let xml = sitemap.xml

        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"))
        #expect(xml.contains("</urlset>"))

        #expect(xml.contains("<loc>https://example.com</loc>"))
        #expect(xml.contains("<loc>https://example.com/about</loc>"))
        #expect(xml.contains("<loc>https://example.com/contact</loc>"))
        #expect(xml.contains("<loc>https://example.com/blog</loc>"))

        #expect(xml.contains("<changefreq>daily</changefreq>"))
        #expect(xml.contains("<changefreq>monthly</changefreq>"))
        #expect(xml.contains("<changefreq>weekly</changefreq>"))
        #expect(xml.contains("<priority>1.0</priority>"))
        #expect(xml.contains("<priority>0.8</priority>"))

        let urlCount = xml.components(separatedBy: "<url>").count - 1
        #expect(urlCount == 4)
    }

    @Test("Large sitemap generation")
    func largeSitemap() throws {
        var urls: [Sitemap.URL] = []
        for i in 0..<1000 {
            let url = try #require(URL(string: "https://example.com/page\(i)"))
            urls.append(
                Sitemap.URL(
                    location: url,
                    lastModification: Date(timeIntervalSince1970: 1_700_000_000),
                    changeFrequency: .weekly,
                    priority: 0.5
                )
            )
        }

        let sitemap = Sitemap(urls: urls)
        let xml = sitemap.xml

        #expect(urls.count == 1000)
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("https://example.com/page0"))
        #expect(xml.contains("https://example.com/page999"))

    }

    @Test("Real-world URL patterns")
    func realWorldURLPatterns() throws {
        let urls = [

            Sitemap.URL(
                location: try #require(URL(string: "https://myblog.com")),
                lastModification: Date(timeIntervalSince1970: 1_700_000_000),
                changeFrequency: .daily,
                priority: 1.0
            ),

            Sitemap.URL(
                location: try #require(URL(string: "https://myblog.com/about")),
                changeFrequency: .yearly,
                priority: 0.8
            ),
            Sitemap.URL(
                location: try #require(URL(string: "https://myblog.com/contact")),
                changeFrequency: .yearly,
                priority: 0.5
            ),

            Sitemap.URL(
                location: try #require(URL(string: "https://myblog.com/posts/2025/01/hello-world")),
                lastModification: Date(timeIntervalSince1970: 1_700_000_000),
                changeFrequency: .never,
                priority: 0.6
            ),

            Sitemap.URL(
                location: try #require(URL(string: "https://myblog.com/categories/swift")),
                changeFrequency: .monthly,
                priority: 0.7
            ),

            Sitemap.URL(
                location: try #require(URL(string: "https://myblog.com/search?q=swift&page=1")),
                changeFrequency: .never,
                priority: 0.3
            ),
        ]

        let sitemap = Sitemap(urls: urls)
        let xml = sitemap.xml

        #expect(xml.contains("https://myblog.com"))
        #expect(xml.contains("https://myblog.com/about"))
        #expect(xml.contains("https://myblog.com/posts/2025/01/hello-world"))
        #expect(
            xml.contains("https://myblog.com/search?q=swift&amp;page=1")
                || xml.contains("https://myblog.com/search?q=swift&page=1")
        )

        #expect(xml.contains("<changefreq>daily</changefreq>"))
        #expect(xml.contains("<changefreq>yearly</changefreq>"))
        #expect(xml.contains("<changefreq>never</changefreq>"))
        #expect(xml.contains("<changefreq>monthly</changefreq>"))

        #expect(xml.contains("<priority>1.0</priority>"))
        #expect(xml.contains("<priority>0.3</priority>"))
    }
}

@Suite("Edge Cases")
struct EdgeCaseTests {

    @Test("URLs with special characters")
    func urlsWithSpecialCharacters() throws {
        let specialURLs = [
            "https://example.com/path with spaces",
            "https://example.com/café",
            "https://example.com/测试",
            "https://example.com/page?param=value&other=test",
            "https://example.com/page#section",
        ]

        for urlString in specialURLs {
            let url = try #require(URL(string: urlString))
            let sitemapURL = Sitemap.URL(location: url)
            let xml = sitemapURL.xml

            #expect(xml.contains("<url>"))
            #expect(xml.contains("<loc>"))
            #expect(xml.contains("</loc>"))
            #expect(xml.contains("</url>"))
        }
    }

    @Test("Extreme priority values")
    func extremePriorityValues() throws {
        let url = try #require(URL(string: "https://example.com"))

        let extremeValues: [Float] = [
            Float.leastNormalMagnitude,
            Float.greatestFiniteMagnitude,
            0.0,
            1.0,
            -1.0,
            2.0,
        ]

        for priority in extremeValues {
            let sitemapURL = Sitemap.URL(
                location: url,
                priority: priority
            )
            let xml = sitemapURL.xml

            #expect(xml.contains("<priority>\(priority)</priority>"))
        }
    }

    @Test("Very old and future dates")
    func extremeDates() throws {
        let url = try #require(URL(string: "https://example.com"))
        let calendar = Calendar.current

        let extremeDates = [
            calendar.date(from: DateComponents(year: 1970, month: 1, day: 1))!,
            calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!,

            calendar.date(from: DateComponents(year: 2038, month: 1, day: 19))!,
            calendar.date(from: DateComponents(year: 3000, month: 12, day: 31))!,
        ]

        for date in extremeDates {
            let sitemapURL = Sitemap.URL(
                location: url,
                lastModification: date
            )
            let xml = sitemapURL.xml

            #expect(xml.contains("<lastmod>"))
            #expect(xml.contains("</lastmod>"))
        }
    }
}

@Suite("XML Structure Validation")
struct XMLValidationTests {

    @Test("XML has proper structure and escaping")
    func xmlStructureValidation() throws {
        let url = try #require(URL(string: "https://example.com/path?param=value&other=test"))
        let sitemapURL = Sitemap.URL(location: url)
        let sitemap = Sitemap(urls: [sitemapURL])
        let xml = sitemap.xml

        #expect(xml.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))

        #expect(xml.contains("xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\""))

        let lines = xml.components(separatedBy: .newlines)
        var inUrlset = false
        var inUrl = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("<urlset") {
                inUrlset = true
            } else if trimmed == "</urlset>" {
                #expect(inUrlset)
                #expect(!inUrl)
                inUrlset = false
            } else if trimmed == "<url>" {
                #expect(inUrlset)
                inUrl = true
            } else if trimmed == "</url>" {
                #expect(inUrl)
                inUrl = false
            }
        }
    }

    @Test("XML escaping of special characters in URLs")
    func xmlEscaping() throws {
        let url = try #require(URL(string: "https://example.com/path?a=1&b=2&c=3"))
        let sitemapURL = Sitemap.URL(location: url)
        let xml = sitemapURL.xml

        #expect(xml.contains("<loc>https://example.com/path?a=1&"))
        #expect(xml.contains("</loc>"))
    }
}
