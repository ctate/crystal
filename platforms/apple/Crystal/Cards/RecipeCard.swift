import SwiftUI

class RecipeModel: ObservableObject {
    struct Ingredient: Identifiable {
        var id: Int
        var name: String
        var isChecked: Bool
    }
    
    struct Direction: Identifiable {
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
