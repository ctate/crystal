import Foundation
import SwiftUI

class RecipeModel: ObservableObject {
    struct Ingredient: Codable, Identifiable {
        var id: Int
        var name: String
        var isChecked: Bool
    }
    
    struct Direction: Codable, Identifiable {
        var id: Int
        var content: String
        var part: String
        var isChecked: Bool
    }
    
    @Published var ingredients: [Ingredient]
    @Published var directions: [Direction]
    
    init(ingredients: [Ingredient], directions: [Direction]) {
        self.ingredients = ingredients
        self.directions = directions
    }
}

struct RecipeCard: View {
    @ObservedObject var recipeModel: RecipeModel
    
    var body: some View {
        List {
            Section(header: Text("Ingredients").foregroundColor(.white)) {
                ForEach($recipeModel.ingredients) { $ingredient in
                    HStack {
                        Text(ingredient.name)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: ingredient.isChecked ? "checkmark.square" : "square")
                            .foregroundColor(.white)
                            .onTapGesture {
                                ingredient.isChecked.toggle()
                            }
                    }
                }
            }
            .listRowBackground(Color.clear)
            
            Section(header: Text("Directions").foregroundColor(.white)) {
                let parts = Dictionary(grouping: recipeModel.directions, by: { $0.part })
                ForEach(parts.keys.sorted(), id: \.self) { part in
                    Section(header: Text(part).foregroundColor(.white)) {
                        ForEach(parts[part]!) { direction in
                            HStack {
                                Text(direction.content)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: direction.isChecked ? "checkmark.square" : "square")
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        if let index = recipeModel.directions.firstIndex(where: { $0.id == direction.id }) {
                                            recipeModel.directions[index].isChecked.toggle()
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
#if os(iOS)
        .listStyle(GroupedListStyle())
#endif
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    RecipeCard(
        recipeModel: RecipeModel(
            ingredients: [
                RecipeModel.Ingredient(
                    id: 1,
                    name: "1 cup water",
                    isChecked: false
                ),
                RecipeModel.Ingredient(
                    id: 2,
                    name: "1 cup water",
                    isChecked: false
                )
            ],
            directions: []
        )
    )
}

class MakeRecipeTool {
    static let name = "make_recipe"
    
    static let function = [
        "type": "function",
        "function": [
            "name": name,
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
    ] as [String: Any]
    
    static func render(_ message: Message) -> AnyView {
        struct Props: Codable {
            let ingredients: [RecipeModel.Ingredient]
            let directions: [RecipeModel.Direction]
        }
        
        guard let result = try? JSONDecoder().decode(Props.self, from: (message.props ?? "{}").data(using: .utf8)!) else {
            return AnyView(TextCard(text: LocalizedStringKey("Failed")))
        }
        
        return AnyView(
            RecipeCard(
                recipeModel: RecipeModel(ingredients: result.ingredients, directions: result.directions)
            )
        )
    }
}
