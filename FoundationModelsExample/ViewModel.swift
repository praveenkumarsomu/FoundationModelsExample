//
//  ViewModel.swift
//  FoundationModelsExample
//
//  Created by Somu Praveen Kumar on 27/11/25.
//

import Foundation
import Playgrounds
import FoundationModels

@Generable
struct StatementSummary {
    @Guide(description: "Credit card statement summary")
    var summary: String
    @Guide(description: "Followup questions that user can ask")
    @Guide(.count(5))
    var followUpQuestions: [String]
}

let userStatement = """
{
  "statement_start_date": "2025-11-11",
  "statement_end_date": "2025-12-11",
  "currency": "INR",
  "transactions": [
    {
      "date": "2025-12-11 12:00:00",
      "merchant": "Amazon India",
      "amount": 1299.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-10 18:45:00",
      "merchant": "Swiggy",
      "amount": 420.50,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-10 09:15:00",
      "merchant": "Indian Oil Petrol Pump",
      "amount": 2200.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-09 20:20:00",
      "merchant": "Zomato",
      "amount": 365.75,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-09 14:40:00",
      "merchant": "BigBasket",
      "amount": 890.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-08 11:05:00",
      "merchant": "Apple Services",
      "amount": 99.00,
      "city": "Online"
    },
    {
      "date": "2025-12-07 17:30:00",
      "merchant": "DMart",
      "amount": 1450.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-07 10:20:00",
      "merchant": "Uber",
      "amount": 230.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-06 21:00:00",
      "merchant": "Inox Cinemas",
      "amount": 780.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-06 08:35:00",
      "merchant": "Apollo Pharmacy",
      "amount": 315.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-05 19:10:00",
      "merchant": "KFC",
      "amount": 560.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-05 12:55:00",
      "merchant": "H&M",
      "amount": 2499.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-04 15:20:00",
      "merchant": "Decathlon",
      "amount": 1799.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-03 09:50:00",
      "merchant": "Starbucks",
      "amount": 310.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-02 20:05:00",
      "merchant": "Myntra",
      "amount": 1650.00,
      "city": "Online"
    },
    {
      "date": "2025-12-02 07:45:00",
      "merchant": "Ola Cabs",
      "amount": 190.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-12-01 13:30:00",
      "merchant": "Reliance Trends",
      "amount": 899.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-11-30 18:25:00",
      "merchant": "Domino's Pizza",
      "amount": 520.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-11-29 11:55:00",
      "merchant": "BookMyShow",
      "amount": 250.00,
      "city": "Hyderabad"
    },
    {
      "date": "2025-11-28 16:45:00",
      "merchant": "Lifestyle Stores",
      "amount": 1499.00,
      "city": "Hyderabad"
    }
  ]
}
"""

#Playground {
    /*
    let session = LanguageModelSession {
        "Your job is to summarize the credit spending for the given statement."
        
        "Do not hallucinate or make up information. Focus on the actual spending patterns. If possible provide the category of each expense."
        
        "When generating follow up questions be creative"
        
        "Example categories: Food, Transportation, Utilities, Entertainment, Savings, Investments, Groceries, etc."
        
        "Example:"
        StatementSummary.example()
        
    }
    */
    
    /*
    do {
        let response = try await session.respond(generating: StatementSummary.self) {
            "Summarize the user spending for the given statement"
            userStatement
        }
        print(response.content)
    } catch {
        print(error.localizedDescription)
        
    }*/
    
    // Dynamic schema
    let dynamicSchema = DynamicGenerationSchema(name: "creditCardStatement", description: "Financial advisor adheres to user's needs and specifications", properties: [
        DynamicGenerationSchema.Property(name: "Summary",description: "Summarise user spending habits", schema: DynamicGenerationSchema(type: String.self)),
        DynamicGenerationSchema.Property(name: "Categories", description: "Divide transactions into categories", schema: DynamicGenerationSchema(type: [CategoryModel].self))
    ])
    
    let sessionForDynamicSchema: LanguageModelSession = LanguageModelSession {
        "Your job is to summarize the credit spending for the given statement."
        
       // "Do not hallucinate or make up information. Focus on the actual spending patterns. If possible provide the category of each expense other wise put it inside other category"
    }
    
    let dynamicResponse = try await sessionForDynamicSchema.respond(schema: GenerationSchema(root: dynamicSchema, dependencies: [])) {
        "Generate a credit card statement summary and categorize transactions"
        userStatement
    }
    let generatedContent = dynamicResponse.content
    let summary = try generatedContent.value(String.self, forProperty: "Summary")
    let categories = try generatedContent.value([CategoryModel].self, forProperty: "Categories")
    
    // Tool calling
    let toolCallingSession = LanguageModelSession(tools: [StatementsTool()]) {
        "Your job is to summarize the credit spending for the given statement."
        
        "Do not hallucinate or make up information. Focus on the actual spending patterns. If possible provide the category of each expense other wise put it inside other category"
    }
    
    let toolCallResponse = try await toolCallingSession.respond(schema: GenerationSchema(root: dynamicSchema, dependencies: [])) {
        "Generate a credit card statement summary and categorize transactions for Nov 2025"
    }
    
    let generatedContentForTollCalling = dynamicResponse.content
    let summaryToolCalling = try generatedContent.value(String.self, forProperty: "Summary")
    let categoriesToolCalling = try generatedContent.value([CategoryModel].self, forProperty: "Categories")
}

@Generable
enum Category: String, CaseIterable, Codable, Identifiable {
    case groceries, diningOut, entertainment, utilities, other
    var id: String { rawValue }
}

extension StatementSummary {
    static func example() -> Self {
        StatementSummary(summary: "You spend $500 on groceries, $300 on dining out, and $200 on groceries. Your spending is higher on the first week of the month and you are paying off a $1000 debt.", followUpQuestions: ["How can save money?", "Are there any intrest on the account?", "How much I am spending for entertainment?"])
    }
}

// Tool calling

@Generable
struct CategoryModel {
    var category: Category
    var transaction: [Transactions]
    var total: Double
}

@Generable
struct Transactions: Codable, Identifiable {
    var id: String
    var description: String
    var amount: Double
    var date: String
}

@MainActor
struct StatementsTool: Tool {
    let name = "getStatements"
    let description = "Retrieve the credit card statement for the month"

    @Generable
    struct Arguments {
        @Guide(description: "The date of the statement which we need to summarise")
        var statementDate: String
    }

    func call(arguments: Arguments) async throws -> String {
        // Placeholder logic; a real app would use a weather API
        userStatement
    }
}

