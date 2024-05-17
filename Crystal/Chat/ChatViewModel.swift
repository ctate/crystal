import AVFoundation
import CoreLocation
import Foundation
import SwiftUI
import SwiftData

struct OpenAIGetWeatherResponse: Codable {
    let location: String
}

struct OpenAIMakeRecipeResponse: Codable {
    let name: String
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}


class ChatViewModel: ObservableObject {
    @Environment(\.modelContext) private var modelContext
    
    @Published var currentView: AnyView = AnyView(TextCard(text: "How can I help?"))
    @Published var prompt = ""
    @Published var isLoading = false
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func sendMessage(_ text: String, conversationManager: ConversationManager, modelContext: ModelContext) {
        let newMessage = Message(text: text, role: "user", timestamp: Date(), provider: nil, model: nil,  function: nil, tokensIn: nil, tokensOut: nil, tokensTotal: nil)
        
        if conversationManager.selectedConversation == nil {
            let newConversation = Conversation(messages: [newMessage])
            conversationManager.selectedConversation = newConversation
            modelContext.insert(newConversation)
        } else {
            conversationManager.selectedConversation?.messages.append(newMessage)
        }
        
        fetchOpenAIResponse(text, modelContext: modelContext, conversation: conversationManager.selectedConversation!)
    }
    
    private func fetchOpenAIResponse(_ text: String, modelContext: ModelContext, conversation: Conversation) {
        isLoading = true
        prompt = text
        
        var messagesPayload: [[String: String]] = [["role": "system", "content": "You are a helpful assistant."]]
        messagesPayload
            .append(contentsOf: conversation.messages
                .sorted { $0.timestamp < $1.timestamp }
                .map { ["role": $0.role, "content": $0.text] }
            )
        
        var tools: [[String: Any]]?
        
        if !UserDefaults.standard.bool(forKey: "functionsDisabled") {
            tools = [
                [
                    "type": "function",
                    "function": [
                        "name": "generate_image",
                        "description": "This function generates images based on specific user-provided text descriptions. Do NOT use this function unless the user provides an explicit request for image generation.",
                        "parameters": [
                            "type": "object",
                            "properties": [
                                "subject": [
                                    "type": "string"
                                ]
                            ],
                            "required": [
                                "subject"
                            ]
                        ]
                    ]
                ],
                [
                    "type": "function",
                    "function": [
                        "name": "make_recipe",
                        "description": "Find a recipe and return it",
                        "parameters": [
                            "type": "object",
                            "properties": [
                                "name": [
                                    "type": "string",
                                    "description": "The name of the recipe"
                                ]
                            ],
                            "required": [
                                "name"
                            ]
                        ]
                    ]
                ]
            ]
            
            if UserDefaults.standard.bool(forKey: "Google:isEnabled") {
                tools!.append([
                    "type": "function",
                    "function": [
                        "name": "search_web",
                        "description": "Search web",
                        "parameters": [
                            "type": "object",
                            "properties": [
                                "query": [
                                    "type": "string"
                                ]
                            ],
                            "required": [
                                "query"
                            ]
                        ]
                    ]
                ])
            }
            
            if UserDefaults.standard.bool(forKey: "HackerNews:isEnabled") {
                tools!.append([
                    "type": "function",
                    "function": [
                        "name": "get_hacker_news",
                        "description": "Get Hacker News",
                        "parameters": [
                            "type": "object",
                            "properties": [
                                "type": [
                                    "type": "string",
                                    "enum": ["top", "new", "best"],
                                    "description": "type of news stories",
                                    "default": "top"
                                ]
                            ],
                            "required": [
                                "type"
                            ]
                        ]
                    ]
                ])
            }
            
            if UserDefaults.standard.bool(forKey: "WeatherGov:isEnabled") {
                tools!.append([
                    "type": "function",
                    "function": [
                        "name": "get_current_weather",
                        "description": "Get weather",
                        "parameters": [
                            "type": "object",
                            "properties": [
                                "location": [
                                    "type": "string",
                                    "description": "The city and state, e.g. San Francisco, CA"
                                ]
                            ],
                            "required": [
                                "location"
                            ]
                        ]
                    ]
                ])
            }
            
            if UserDefaults.standard.bool(forKey: "Wikipedia:isEnabled") {
                tools!.append([
                    "type": "function",
                    "function": [
                        "name": "search_wikipedia",
                        "description": "Search Wikipedia for biography",
                        "parameters": [
                            "type": "object",
                            "properties": [
                                "query": [
                                    "type": "string"
                                ]
                            ],
                            "required": [
                                "query"
                            ]
                        ]
                    ]
                ])
            }
        }
        
        let provider = UserDefaults.standard.string(forKey: "defaultPromptProvider") ?? ""
        let model = UserDefaults.standard.string(forKey: "defaultPromptModel") ?? ""
        
        if provider == "Anthropic" {
            print("AnthropicApi")
            
            if !UserDefaults.standard.bool(forKey: "Anthropic:isEnabled") {
                alertError("Anthropic is not enabled")
                return
            }
            
            AnthropicApi().makeCompletions(model: model, messages: messagesPayload, tools: tools) { result in
                modelContext.insert(
                    Message(
                        text: (result.content.last?.type == "tool_use" ? String(data: try! JSONSerialization.data(withJSONObject: result.content.last!.input!), encoding: .utf8) : result.content.first?.text ?? "") ?? "",
                        role: result.role,
                        timestamp: Date(),
                        provider: "Anthropic",
                        model: model,
                        function: result.content.last?.type == "tool_use" ? result.content.last!.name : nil,
                        tokensIn: 0,
                        tokensOut: 0,
                        tokensTotal: 0,
                        conversation: conversation
                    )
                )
                
                self.updateViewBasedOnLastMessage(modelContext, conversation: conversation)
            }
            
        } else if provider == "Groq" {
            print("GroqAPI")
            
            if !UserDefaults.standard.bool(forKey: "Groq:isEnabled") {
                alertError("Groq is not enabled")
                return
            }
            
            GroqApi().makeCompletions(model: model, messages: messagesPayload, tools: tools) { result in
                modelContext.insert(
                    Message(
                        text: result.choices.first?.message.tool_calls?.first?.function.arguments ?? result.choices.first?.message.content ?? "",
                        role: result.choices.first?.message.role ?? "unknown",
                        timestamp: Date(),
                        provider: "Groq",
                        model: model,
                        function: result.choices.first?.message.tool_calls?.first?.function.name ?? nil,
                        tokensIn: result.usage.prompt_tokens,
                        tokensOut: result.usage.completion_tokens,
                        tokensTotal: result.usage.total_tokens,
                        conversation: conversation
                    )
                )
                
                self.updateViewBasedOnLastMessage(modelContext, conversation: conversation)
            }
        } else if provider == "Ollama" {
            print("OllamaApi")
            
            if !UserDefaults.standard.bool(forKey: "Ollama:isEnabled") {
                alertError("Ollama is not enabled")
                return
            }
            
            OllamaApi().makeCompletions(model: model, messages: messagesPayload, tools: tools) { result, content in
                modelContext.insert(
                    Message(
                        text: content != nil && content!.type == "function" ? content!.function.arguments : result.message.content,
                        role: result.message.role,
                        timestamp: Date(),
                        provider: "Ollama",
                        model: model,
                        function: content != nil && content!.type == "function" ? content!.function.name : nil,
                        tokensIn: result.prompt_eval_count,
                        tokensOut: result.eval_count,
                        tokensTotal: result.prompt_eval_count + result.eval_count,
                        conversation: conversation
                    )
                )
                
                self.updateViewBasedOnLastMessage(modelContext, conversation: conversation)
            }
        } else if provider == "OpenAI" {
            print("OpenAIApi")
            
            if !UserDefaults.standard.bool(forKey: "OpenAI:isEnabled") {
                alertError("OpenAI is not enabled")
                return
            }
            
            OpenAiApi().makeCompletions(model: model, messages: messagesPayload, tools: tools) { result in
                modelContext.insert(
                    Message(
                        text: result.choices.first?.message.tool_calls?.first?.function.arguments ?? result.choices.first?.message.content ?? "",
                        role: result.choices.first?.message.role ?? "unknown",
                        timestamp: Date(),
                        provider: "OpenAI",
                        model: model,
                        function: result.choices.first?.message.tool_calls?.first?.function.name ?? nil,
                        tokensIn: result.usage.prompt_tokens,
                        tokensOut: result.usage.completion_tokens,
                        tokensTotal: result.usage.total_tokens,
                        conversation: conversation
                    )
                )
                
                self.updateViewBasedOnLastMessage(modelContext, conversation: conversation)
            }
        } else {
            alertError("Unknown model")
            return
        }
    }
    
    func updateViewBasedOnLastMessage(_ modelContext: ModelContext, conversation: Conversation) {
        let messages = conversation.messages.sorted { $0.timestamp < $1.timestamp }
        
        guard let lastMessage = messages.last, lastMessage.role == "assistant" else {
            currentView = AnyView(Text("No new messages from assistant"))
            return
        }
        
        switch lastMessage.function {
        case "generate_image":
            currentView = AnyView(DalleImageCardSkeleton())
            isLoading = false
            
            struct Response: Codable {
                let subject: String
            }
            
            if let result = try? JSONDecoder().decode(Response.self, from: lastMessage.text.data(using: .utf8)!) {
                OpenAiApi().generateImage(prompt: result.subject) { result in
                    DispatchQueue.main.async {
                        self.currentView = AnyView(DalleImageCard(images: result))
                        self.isLoading = false
                    }
                }
            }
            
        case "get_current_weather":
            let geocoder = CLGeocoder()
            
            if let result = try? JSONDecoder().decode(OpenAIGetWeatherResponse.self, from: lastMessage.text.data(using: .utf8)!) {
                geocoder.geocodeAddressString(result.location) { (placemarks, error) in
                    guard error == nil else {
                        print("Geocoding error: \(error!.localizedDescription)")
                        return
                    }
                    
                    if let placemark = placemarks?.first {
                        let location = placemark.location
                        WeatherAPI().getWeatherPoints(
                            lat: "\(location?.coordinate.latitude ?? 0)",
                            lng: "\(location?.coordinate.longitude ?? 0)"
                        ) { forecast, forecastHourly, forecastGridData in
                            WeatherAPI().getWeatherForecast(forecastUrl: forecast) { temperature, shortForecast in
                                DispatchQueue.main.async {
                                    self.currentView = AnyView(WeatherCard(
                                        temperature: temperature,
                                        forecast: shortForecast
                                    ))
                                    
                                    self.isLoading = false
                                    
                                    let utterance = AVSpeechUtterance(string: "It is \(temperature) degrees and \(shortForecast)")
                                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                                    utterance.rate = 0.5
                                    utterance.volume = 1.0
                                    self.speechSynthesizer.speak(utterance)
                                }
                            }
                        }
                    }
                }
            } else {
                print("Failed to decode location")
            }
            
        case "get_current_time":
            currentView = AnyView(ClockCard())
            
            isLoading = false
            
        case "get_hacker_news":
            struct Response: Codable {
                let type: String
            }
            
            if let result = try? JSONDecoder().decode(Response.self, from: lastMessage.text.data(using: .utf8)!) {
                HackerNewsApi().getNewsIds(type: result.type) { result in
                    HackerNewsApi().getArticleDetails(for: result) { result in
                        print(result)
                        
                        DispatchQueue.main.async {
                            self.currentView = AnyView(HackerNewsCard(articles: result))
                            self.isLoading = false
                        }
                    }
                }
            }
            
        case "make_recipe":
            if let result = try? JSONDecoder().decode(OpenAIMakeRecipeResponse.self, from: lastMessage.text.data(using: .utf8)!) {
                let messagesPayload: [[String: String]] = [
                    [
                        "role": "system",
                        "content": "You are an expert chef."
                    ],
                    [
                        "role": "user",
                        "content": """
                            Come up with a recipe for: \(result.name)
                        
                            Do not provide an explanation.
                        
                            Only return a JSON string (NO Markdown) in a format like this:
                        
                            {
                              "title": "Vegan Spaghetti",
                              "ingredients": [
                                "400g spaghetti (make sure it's vegan)",
                                "2 tablespoons olive oil",
                                "4 cloves garlic, minced",
                                "1 onion, finely chopped",
                                "1 bell pepper, diced",
                                "1 zucchini, sliced",
                                "200g cherry tomatoes, halved",
                                "2 cups marinara sauce (store-bought or homemade)",
                                "1 teaspoon dried oregano",
                                "1 teaspoon dried basil",
                                "Salt and pepper, to taste",
                                "Fresh basil leaves, for garnish",
                                "Nutritional yeast or vegan parmesan, for serving (optional)"
                              ],
                              "directions": [
                                {
                                  name: "Cook the Spaghetti",
                                  steps: [
                                    "Bring a large pot of salted water to a boil. Add the spaghetti and cook according to the package instructions until al dente. Drain and set aside."
                                  ]
                                },
                                {
                                  name: "Sauté the Vegetables",
                                  steps: [
                                    "In a large skillet, heat the olive oil over medium heat. Add the garlic and onion, sautéing until the onion becomes translucent, about 3-4 minutes.",
                                    "Add the bell pepper and zucchini to the skillet. Continue to cook, stirring occasionally, until the vegetables are tender, about 5-7 minutes.",
                                    "Stir in the cherry tomatoes and cook for another 2-3 minutes, until the tomatoes start to soften."
                                  ]
                                },
                                {
                                  name: "Combine with Sauce",
                                  steps: [
                                    "Pour the marinara sauce into the skillet. Add oregano and basil, and season with salt and pepper. Reduce the heat and let the sauce simmer for about 5-10 minutes, allowing the flavors to meld."
                                  ]
                                },
                                {
                                  name: "Mix Pasta and Sauce",
                                  steps: [
                                    "Add the cooked spaghetti to the skillet. Toss everything together until the pasta is well coated with the sauce. Cook for an additional 1-2 minutes to heat the spaghetti through."
                                  ]
                                },
                                {
                                  name: "Serve",
                                  steps: [
                                    "Serve the spaghetti hot, garnished with fresh basil leaves. If desired, sprinkle nutritional yeast or vegan parmesan on top for added flavor."
                                  ]
                                }
                              ]
                            }
                        """
                    ]
                ]
                
                OpenAiApi().makeCompletions(model: "gpt-3.5-turbo-0125", messages: messagesPayload, tools: nil) { result in
                    struct Recipe: Codable {
                        struct Direction: Codable {
                            let name: String
                            let steps: [String]
                        }
                        let title: String
                        let ingredients: [String]
                        let directions: [Direction]
                    }
                    
                    if let result = try? JSONDecoder().decode(Recipe.self, from: result.choices.first!.message.content!.data(using: .utf8)!) {
                        let mappedIngredients = result.ingredients.enumerated().map { index, ingredient in
                            RecipeModel.Ingredient(id: index, name: ingredient, isChecked: false)
                        }
                        
                        //                        let mappedDirections = result.directions.enumerated().map { index, direction in
                        //                            RecipeModel.Direction(id: index, content: direction.name, part: direction.part, isChecked: false)
                        //                            }
                        
                        self.currentView = AnyView(
                            RecipeCard(
                                recipeModel: RecipeModel(ingredients: mappedIngredients, directions: [])
                            )
                        )
                        
                        self.isLoading = false
                    } else {
                        print("Failed to decode recipe")
                    }
                    
                }
            }
            
        case "search_web":
            struct Response: Codable {
                let query: String
            }
            
            if let result = try? JSONDecoder().decode(Response.self, from: lastMessage.text.data(using: .utf8)!) {
                GoogleApi().fetchSearchResults(query: result.query) { result in
                    print(result)
                    
                    DispatchQueue.main.async {
                        self.currentView = AnyView(GoogleSearchCard(results: result))
                        self.isLoading = false
                    }
                }
            }
            
        case "search_wikipedia":
            struct Response: Codable {
                let query: String
            }
            
            if let result = try? JSONDecoder().decode(Response.self, from: lastMessage.text.data(using: .utf8)!) {
                WikipediaApi().fetchSearchResults(query: result.query) { result in
                    print(result)
                    
                    WikipediaApi().fetchArticle(title: result.first!.title) { result in
                        
                        DispatchQueue.main.async {
                            self.currentView = AnyView(WikipediaCard(article: result!))
                            self.isLoading = false
                            
                            let utterance = AVSpeechUtterance(string: result!.content)
                            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                            utterance.rate = 0.5
                            utterance.volume = 1.0
                            self.speechSynthesizer.speak(utterance)
                        }
                    }
                }
            }
            
        case "text":
            struct Response: Codable {
                let text: String
            }
            
            if let result = try? JSONDecoder().decode(Response.self, from: lastMessage.text.data(using: .utf8)!) {
                currentView = AnyView(TextCard(text: LocalizedStringKey(result.text)))
                
                isLoading = false
            }
            
        default:
            currentView = AnyView(TextCard(text: LocalizedStringKey(lastMessage.text)))
            
            let utterance = AVSpeechUtterance(string: lastMessage.text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            utterance.rate = 0.5
            utterance.volume = 1.0
            speechSynthesizer.speak(utterance)
            
            isLoading = false
        }
        
        
    }
}
