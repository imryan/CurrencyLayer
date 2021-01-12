import Foundation
import ArgumentParser

// MARK: - Setup -

/// Networking helper
let networking: Networking?
if let apiKey = UserDefaults.standard.string(forKey: "kCurrencyLayerAPIKey") {
    networking = .init(apiKey: apiKey)
} else {
    print("No API key found. Please set one now:")
    
    if let apiKey = readLine() {
        UserDefaults.standard.setValue(apiKey, forKey: "kCurrencyLayerAPIKey")
        print("API key has been set successfully.")
        networking = .init(apiKey: apiKey)
    } else {
        print("Failed to set API key.")
        exit(EXIT_FAILURE)
    }
}

/// Track async process
var isDone: Bool = false {
    didSet {
        if isDone {
            exit(EXIT_SUCCESS)
        }
    }
}

// MARK: - CurrencyLayer -

struct CurrencyLayer: ParsableCommand {
    
    // MARK: - CommandConfiguration -
    
    static let configuration: CommandConfiguration = .init(
        abstract: "A Swift command-line tool for fetching and converting live currency data.",
        subcommands: [Live.self, Historical.self, Convert.self, Timeframe.self, Change.self, Key.self]
    )
    
    // MARK: - Initialization -
    
    init() {
        /// TODO: Setup module here.
    }
}

// MARK: - Key -

struct Key: ParsableCommand {
    
    public static let configuration: CommandConfiguration = .init(abstract: "Use this command to set your CurrencyLayer API key.")
    
    @Argument(help: "Your API key from CurrencyLayer.")
    private var apiKey: String
    
    func run() throws {
        UserDefaults.standard.setValue(apiKey, forKey: "kCurrencyLayerAPIKey")
        print("API key has been set successfully.")
        isDone = true
    }
}

// MARK: - Live -

struct Live: ParsableCommand {
    
    public static let configuration: CommandConfiguration = .init(abstract: "Request the most recent exchange rate data.")
    
    @Option(name: .shortAndLong, help: "Specify a Source Currency other than the default USD. Supported on the Basic Plan and higher.")
    private var source: String?
    
    @Option(name: .shortAndLong, help: "Specify a comma-separated list of currency codes to limit your API response to specific currencies.")
    private var currencies: String?
    
    func run() throws {
        var parameters: [String: Any] = [:]
        if let source = source {
            parameters["source"] = source
        }
        
        if let currencies = currencies {
            parameters["currencies"] = currencies
        }
        
        printCurrencyData(with: parameters)
    }
}

// MARK: - Historical -

struct Historical: ParsableCommand {
    
    public static let configuration: CommandConfiguration = .init(abstract: "Request historical rates for a specific day.")
    
    @Argument(help: "Specify a date for which to request historical rates. (Format: 'YYYY-MM-DD').")
    private var date: String
    
    @Option(name: .shortAndLong, help: "Specify a Source Currency other than the default USD. Supported on the Basic Plan and higher.")
    private var source: String?
    
    @Option(name: .shortAndLong, help: "Specify a comma-separated list of currency codes to limit your API response to specific currencies.")
    private var currencies: String?
    
    func run() throws {
        var parameters: [String: Any] = ["date": date]
        if let source = source {
            parameters["source"] = source
        }
        
        if let currencies = currencies {
            parameters["currencies"] = currencies
        }
        
        printCurrencyData(with: parameters)
    }
}

// MARK: - Convert -

struct Convert: ParsableCommand {
    
    public static let configuration: CommandConfiguration = .init(abstract: "Convert any amount from one currency to another using real-time exchange rates.")
    
    @Argument(help: "Specify the currency to convert from.")
    private var from: String
    
    @Argument(help: "Specify the currency to convert to.")
    private var to: String
    
    @Argument(help: "Specify the amount to convert.")
    private var amount: String
    
    @Option(name: .shortAndLong, help: "Specify a date for which to request historical rates. (Format: 'YYYY-MM-DD').")
    private var date: String?
    
    func run() throws {
        var parameters: [String: Any] = [
            "from": from,
            "to": to,
            "amount": amount
        ]
        
        if let date = date {
            parameters["date"] = date
        }
        
        networking?.request(.convert, parameters: parameters) { (data: ConversionResponse?, error: CurrencyLayerError?) in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "No description.")")
                isDone = true
                return
            }
            
            if let result = data?.result {
                print("\(from) -> \(to) = $\(result)")
            }
            
            isDone = true
        }
    }
}

// MARK: - Timeframe -

struct Timeframe: ParsableCommand {
    
    public static let configuration: CommandConfiguration = .init(abstract: "Request exchange rates for a specific period of time.")
    
    @Argument(help: "Specify the start date of your time frame.")
    private var startDate: String
    
    @Argument(help: "Specify the end date of your time frame.")
    private var endDate: String
    
    @Option(name: .shortAndLong, help: "Specify a Source Currency other than the default USD. Supported on the Basic Plan and higher.")
    private var source: String?
    
    @Option(name: .shortAndLong, help: "Specify a comma-separated list of currency codes to limit your API response to specific currencies.")
    private var currencies: String?
    
    func run() throws {
        var parameters: [String: Any] = [
            "start_date": startDate,
            "end_date": endDate
        ]
        
        if let source = source {
            parameters["source"] = source
        }
        
        if let currencies = currencies {
            parameters["currencies"] = currencies
        }
        
        networking?.request(.timeFrame, parameters: parameters) { (data: TimeframeResponse?, error: CurrencyLayerError?) in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "No description.")")
                isDone = true
                return
            }
            
            if let quote = data?.quotes {
                quote.forEach { (k, v) in
                    print("\(k) -> \(v)")
                }
            }
            
            isDone = true
        }
    }
}

// MARK: - Change -

struct Change: ParsableCommand {
    
    public static let configuration: CommandConfiguration = .init(abstract: "Request any currency's change parameters (margin and percentage), optionally between two specified dates.")
    
    @Argument(help: "Specify the start date of your time frame.")
    private var startDate: String
    
    @Argument(help: "Specify the end date of your time frame.")
    private var endDate: String
    
    @Option(name: .shortAndLong, help: "Specify a Source Currency other than the default USD. Supported on the Basic Plan and higher.")
    private var source: String?
    
    @Option(name: .shortAndLong, help: "Specify a comma-separated list of currency codes to limit your API response to specific currencies.")
    private var currencies: String?
    
    func run() throws {
        var parameters: [String: Any] = [
            "start_date": startDate,
            "end_date": endDate
        ]
        
        if let source = source {
            parameters["source"] = source
        }
        
        if let currencies = currencies {
            parameters["currencies"] = currencies
        }
        
        networking?.request(.change, parameters: parameters) { (data: TimeframeResponse?, error: CurrencyLayerError?) in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "No description.")")
                isDone = true
                return
            }
            
            if let quote = data?.quotes {
                quote.forEach { (k, v) in
                    print("\(k) -> \(v)")
                }
            }
            
            isDone = true
        }
    }
}

// MARK: - Helpers -

private func printCurrencyData(with parameters: [String: Any]) {
    networking?.request(.live, parameters: parameters) { (data: LiveData?, error: CurrencyLayerError?) in
        guard error == nil else {
            print("Error: \(error?.localizedDescription ?? "No description.")")
            isDone = true
            return
        }
        
        if let source = data?.source, let quotes = data?.quotes {
            quotes.forEach {
                if let destinationCurrency: String = $0.key.components(separatedBy: source).last {
                    print("* \(source)->\(destinationCurrency) = $\($0.value)")
                }
            }
        }
        
        isDone = true
    }
}

// MARK: - Main -

// Start it up
CurrencyLayer.main()
RunLoop.main.run()
