struct AppConstants {
    struct ProductionAPIServer {
        static let scheme: HTTPServer.Scheme = .https
        static let host = "sammysapp.herokuapp.com"
    }
    
    struct ApplePay {
        static let merchantID = "merchant.com.niazoff.sammys"
        static let countryCode = "US"
        static let currencyCode = "USD"
    }
}
