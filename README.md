# 💵 CurrencyLayer
![Swift](https://github.com/imryan/CurrencyLayer/workflows/Swift/badge.svg?branch=master)

A Swift command-line tool for fetching and converting live currency data.


# Usage
```
currency-layer <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  live                    Request the most recent exchange rate data.
  historical              Request historical rates for a specific day.
  convert                 Convert any amount from one currency to another using
                          real-time exchange rates.
  timeframe               Request exchange rates for a specific period of time.
  change                  Request any currency's change parameters (margin and
                          percentage), optionally between two specified dates.
  key                     Use this command to set your CurrencyLayer API key.
```
