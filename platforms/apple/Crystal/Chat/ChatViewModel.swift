import AVFoundation
import CoreLocation
import Foundation
import SwiftUI
import SwiftData

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}


class ChatViewModel: ObservableObject {
    @Published var currentView: AnyView = AnyView(TextCard(text: "How can I help?"))
    @Published var prompt = ""
    @Published var isLoading = false
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func sendMessage(_ text: String, conversationManager: ConversationManager, modelContext: ModelContext) {
        let newMessage = Message(text: text, role: "user", timestamp: Date(), provider: nil, model: nil, function: nil, arguments: nil, props: nil, tokensIn: nil, tokensOut: nil, tokensTotal: nil)
        
        if conversationManager.selectedConversation == nil {
            let newConversation = Conversation(messages: [newMessage])
            conversationManager.selectedConversation = newConversation
            modelContext.insert(newConversation)
        } else {
            conversationManager.selectedConversation?.messages.append(newMessage)
        }
        
        func fetchData(completion: @escaping ((Message, ToolResponse?)?, Error?) -> Void) {
            Task {
                do {
                    let result = try await fetchAiResponse(text, conversation: conversationManager.selectedConversation!)
                    completion(result, nil)
                } catch let error {
                    completion(nil, error)
                }
            }
        }
        
        isLoading = true
        prompt = text
        
        fetchData { (result, error) in
            if let error = error {
                alertError(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                modelContext.insert(result!.0)
                
                if result!.1 != nil {
                    result!.0.text = result!.1!.text
                    result!.0.props = result!.1!.props
                }
                
                self.currentView = result!.1?.view ?? AnyView(TextCard(text: LocalizedStringKey(result!.0.text)))
                self.isLoading = false
                
                if !UserSettings.isMuted {
                    let utterance = AVSpeechUtterance(string: newMessage.text)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.rate = 0.5
                    utterance.volume = 1.0
                    self.speechSynthesizer.speak(utterance)
                }
            }
        }
    }
    
    private func fetchAiResponse(_ text: String, conversation: Conversation) async throws -> (Message, ToolResponse?) {
        var messagesPayload: [[String: String]] = [["role": "system", "content": "You are a helpful assistant."]]
        messagesPayload
            .append(contentsOf: conversation.messages
                .sorted { $0.timestamp < $1.timestamp }
                .map { ["role": $0.role, "content": $0.text] }
            )
        
        var tools: [[String: Any]]?
        
        if !UserSettings.functionsDisabled {
            tools = [
                GenerateImageTool.function,
                MakeRecipeTool.function
            ]
            
            if UserSettings.Integrations.Google.isEnabled {
                tools!.append(GoogleTool.function)
            }
            
            if UserSettings.Integrations.HackerNews.isEnabled {
                tools!.append(HackerNewsTool.function)
            }
            
            if UserSettings.Integrations.WeatherGov.isEnabled {
                tools!.append(WeatherTool.function)
            }
            
            if UserSettings.Integrations.Wikipedia.isEnabled {
                tools!.append(WikipediaTool.function)
            }
        }
        
        let provider = UserSettings.promptProvider ?? ""
        let model = UserSettings.promptModel ?? ""
        
        if provider == "Anthropic" {
            print("AnthropicApi")
            
            if !UserSettings.Providers.Anthropic.isEnabled {
                throw NSError(domain: "ChatViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Anthropic is not enabled."])
            }
            
            let result = try await AnthropicApi.makeCompletions(model: model, messages: messagesPayload, tools: tools)
            
            return try await updateViewBasedOnNewMessage(conversation: conversation, newMessage: Message(
                text: result.content.first?.text ?? "",
                role: result.role,
                timestamp: Date(),
                provider: "Anthropic",
                model: model,
                function: result.content.last?.type == "tool_use" ? result.content.last!.name : nil,
                arguments: result.content.last?.type == "tool_use" ? String(data: try! JSONSerialization.data(withJSONObject: result.content.last!.input!), encoding: .utf8) : nil,
                props: nil,
                tokensIn: 0,
                tokensOut: 0,
                tokensTotal: 0,
                conversation: conversation
            ))
            
        } else if provider == "Groq" {
            print("GroqAPI")
            
            if !UserSettings.Providers.Groq.isEnabled {
                throw NSError(domain: "ChatViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Groq is not enabled."])
            }
            
            let result = try await GroqApi.makeCompletions(model: model, messages: messagesPayload, tools: tools)
            return try await self.updateViewBasedOnNewMessage(conversation: conversation, newMessage: Message(
                text: result.choices.first?.message.content ?? "",
                role: result.choices.first?.message.role ?? "unknown",
                timestamp: Date(),
                provider: "Groq",
                model: model,
                function: result.choices.first?.message.tool_calls?.first?.function.name ?? nil,
                arguments: result.choices.first?.message.tool_calls?.first?.function.arguments ?? nil,
                props: nil,
                tokensIn: result.usage.prompt_tokens,
                tokensOut: result.usage.completion_tokens,
                tokensTotal: result.usage.total_tokens,
                conversation: conversation
            ))
        } else if provider == "Ollama" {
            print("OllamaApi")
            
            if !UserSettings.Providers.Ollama.isEnabled {
                throw NSError(domain: "ChatViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Ollama is not enabled."])
            }
            
            let (result, content) = try await OllamaApi.makeCompletions(model: model, messages: messagesPayload, tools: tools)
            
            return try await self.updateViewBasedOnNewMessage(conversation: conversation, newMessage: Message(
                text: result.message.content,
                role: result.message.role,
                timestamp: Date(),
                provider: "Ollama",
                model: model,
                function: content != nil && content!.type == "function" ? content!.function.name : nil,
                arguments: content != nil && content!.type == "function" ? content!.function.arguments : nil,
                props: nil,
                tokensIn: result.prompt_eval_count,
                tokensOut: result.eval_count,
                tokensTotal: result.prompt_eval_count + result.eval_count,
                conversation: conversation
            ))
            
        } else if provider == "OpenAI" {
            print("OpenAIApi")
            
            if !UserSettings.Providers.OpenAI.isEnabled {
                throw NSError(domain: "ChatViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "OpenAI is not enabled."])
            }
            
            let result = try await OpenAiApi.makeCompletions(model: model, messages: messagesPayload, tools: tools)
            
            return try await self.updateViewBasedOnNewMessage(conversation: conversation, newMessage: Message(
                text: result.choices.first?.message.content ?? "",
                role: result.choices.first?.message.role ?? "unknown",
                timestamp: Date(),
                provider: "OpenAI",
                model: model,
                function: result.choices.first?.message.tool_calls?.first?.function.name ?? nil,
                arguments: result.choices.first?.message.tool_calls?.first?.function.arguments ?? nil,
                props: nil,
                tokensIn: result.usage.prompt_tokens,
                tokensOut: result.usage.completion_tokens,
                tokensTotal: result.usage.total_tokens,
                conversation: conversation
            ))
        } else {
            throw NSError(domain: "ChatViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Unknown model."])
        }
    }
    
    func updateViewBasedOnLastMessage(lastMessage: Message) {
        switch lastMessage.function {
        case "generate_image":
            currentView = GenerateImageTool.render(lastMessage)
        case "get_current_weather":
            currentView = WeatherTool.render(lastMessage)
        case "get_hacker_news":
            currentView = HackerNewsTool.render(lastMessage)
        case "make_recipe":
            currentView = MakeRecipeTool.render(lastMessage)
        case "search_web":
            currentView = GoogleTool.render(lastMessage)
        case "search_wikipedia":
            currentView = WikipediaTool.render(lastMessage)
        case "text":
            struct Props: Codable {
                let text: String
            }
            
            guard let result = try? JSONDecoder().decode(Props.self, from: (lastMessage.props ?? "{}").data(using: .utf8)!) else {
                return
            }
            
            currentView = AnyView(TextCard(text: LocalizedStringKey(result.text)))
        default:
            currentView = AnyView(TextCard(text: LocalizedStringKey(lastMessage.text)))
        }
    }
    
    func updateViewBasedOnNewMessage(conversation: Conversation, newMessage: Message) async throws -> (Message, ToolResponse?) {
        switch newMessage.function {
        case "generate_image":
            DispatchQueue.main.async {
                self.currentView = AnyView(DalleImageCardSkeleton())
                self.isLoading = false
            }
            
            let response = try await GenerateImageTool.fetch(newMessage)
            return (newMessage, response)
            
        case "get_current_weather":
            let response = try await WeatherTool.fetch(newMessage)
            return (newMessage, response)
            
        case "get_hacker_news":
            let response = try await HackerNewsTool.fetch(newMessage)
            return (newMessage, response)
            
        case "make_recipe":
            //            if let result = try? JSONDecoder().decode(OpenAIMakeRecipeResponse.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) {
            //                let messagesPayload: [[String: String]] = [
            //                    [
            //                        "role": "system",
            //                        "content": "You are an expert chef."
            //                    ],
            //                    [
            //                        "role": "user",
            //                        "content": """
            //                            Come up with a recipe for: \(result.name)
            //
            //                            Do not provide an explanation.
            //
            //                            Only return a JSON string (NO Markdown) in a format like this:
            //
            //                            {
            //                              "title": "Vegan Spaghetti",
            //                              "ingredients": [
            //                                "400g spaghetti (make sure it's vegan)",
            //                                "2 tablespoons olive oil",
            //                                "4 cloves garlic, minced",
            //                                "1 onion, finely chopped",
            //                                "1 bell pepper, diced",
            //                                "1 zucchini, sliced",
            //                                "200g cherry tomatoes, halved",
            //                                "2 cups marinara sauce (store-bought or homemade)",
            //                                "1 teaspoon dried oregano",
            //                                "1 teaspoon dried basil",
            //                                "Salt and pepper, to taste",
            //                                "Fresh basil leaves, for garnish",
            //                                "Nutritional yeast or vegan parmesan, for serving (optional)"
            //                              ],
            //                              "directions": [
            //                                {
            //                                  name: "Cook the Spaghetti",
            //                                  steps: [
            //                                    "Bring a large pot of salted water to a boil. Add the spaghetti and cook according to the package instructions until al dente. Drain and set aside."
            //                                  ]
            //                                },
            //                                {
            //                                  name: "Sauté the Vegetables",
            //                                  steps: [
            //                                    "In a large skillet, heat the olive oil over medium heat. Add the garlic and onion, sautéing until the onion becomes translucent, about 3-4 minutes.",
            //                                    "Add the bell pepper and zucchini to the skillet. Continue to cook, stirring occasionally, until the vegetables are tender, about 5-7 minutes.",
            //                                    "Stir in the cherry tomatoes and cook for another 2-3 minutes, until the tomatoes start to soften."
            //                                  ]
            //                                },
            //                                {
            //                                  name: "Combine with Sauce",
            //                                  steps: [
            //                                    "Pour the marinara sauce into the skillet. Add oregano and basil, and season with salt and pepper. Reduce the heat and let the sauce simmer for about 5-10 minutes, allowing the flavors to meld."
            //                                  ]
            //                                },
            //                                {
            //                                  name: "Mix Pasta and Sauce",
            //                                  steps: [
            //                                    "Add the cooked spaghetti to the skillet. Toss everything together until the pasta is well coated with the sauce. Cook for an additional 1-2 minutes to heat the spaghetti through."
            //                                  ]
            //                                },
            //                                {
            //                                  name: "Serve",
            //                                  steps: [
            //                                    "Serve the spaghetti hot, garnished with fresh basil leaves. If desired, sprinkle nutritional yeast or vegan parmesan on top for added flavor."
            //                                  ]
            //                                }
            //                              ]
            //                            }
            //                        """
            //                    ]
            //                ]
            //
            //                OpenAiApi().makeCompletions(model: "gpt-3.5-turbo-0125", messages: messagesPayload, tools: nil) { result in
            //                    struct Recipe: Codable {
            //                        struct Direction: Codable {
            //                            let name: String
            //                            let steps: [String]
            //                        }
            //                        let title: String
            //                        let ingredients: [String]
            //                        let directions: [Direction]
            //                    }
            //
            //                    if let result = try? JSONDecoder().decode(Recipe.self, from: result.choices.first!.message.content!.data(using: .utf8)!) {
            //                        let mappedIngredients = result.ingredients.enumerated().map { index, ingredient in
            //                            RecipeModel.Ingredient(id: index, name: ingredient, isChecked: false)
            //                        }
            //
            //                        //                        let mappedDirections = result.directions.enumerated().map { index, direction in
            //                        //                            RecipeModel.Direction(id: index, content: direction.name, part: direction.part, isChecked: false)
            //                        //                            }
            //
            //                        self.currentView = AnyView(
            //                            RecipeCard(
            //                                recipeModel: RecipeModel(ingredients: mappedIngredients, directions: [])
            //                            )
            //                        )
            //
            //                        newMessage.text = "Make Recipe"
            //                        newMessage.props = String(data: try! JSONSerialization.data(withJSONObject: [
            //                            "ingredients": mappedIngredients,
            //                            "directions": []
            //                        ]), encoding: .utf8)
            //                        modelContext.insert(newMessage)
            //
            //                        self.isLoading = false
            //                    } else {
            //                        print("Failed to decode recipe")
            //                    }
            //
            //                }
            //            }
            
            return (newMessage, nil)
            
        case "search_web":
            //            struct Response: Codable {
            //                let query: String
            //            }
            //
            //            if let result = try? JSONDecoder().decode(Response.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) {
            //                GoogleApi().fetchSearchResults(query: result.query) { result in
            //                    print(result)
            //
            //                    DispatchQueue.main.async {
            //                        self.currentView = AnyView(GoogleSearchCard(results: result))
            //
            //                        newMessage.text = "Search Web"
            //                        newMessage.props = String(data: try! JSONSerialization.data(withJSONObject: [
            //                            "results": [],
            //                        ]), encoding: .utf8)
            //                        modelContext.insert(newMessage)
            //
            //                        self.isLoading = false
            //                    }
            //                }
            //            }
            
            return (newMessage, nil)
            
        case "search_wikipedia":
            let response = try await WikipediaTool.fetch(newMessage)
            
            return (newMessage, response)
            
        case "text":
            //            struct Response: Codable {
            //                let text: String
            //            }
            //
            //            if let result = try? JSONDecoder().decode(Response.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) {
            //                currentView = AnyView(TextCard(text: LocalizedStringKey(result.text)))
            //
            //                newMessage.text = "Text"
            //                newMessage.props = String(data: try! JSONSerialization.data(withJSONObject: [
            //                    "text": result.text,
            //                ]), encoding: .utf8)
            //                modelContext.insert(newMessage)
            //
            //                isLoading = false
            //            }
            
            return (newMessage, nil)
            
        default:
            return (newMessage, nil)
        }
    }
}
