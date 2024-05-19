import RecipeCard from "@/components/cards/RecipeCard";

export default function Page() {
  const ingredients = [
    `400g spaghetti (make sure it's vegan)`,
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
    "Nutritional yeast or vegan parmesan, for serving (optional)",
  ];

  const directions = [
    {
      name: "Cook the Spaghetti",
      steps: [
        "Bring a large pot of salted water to a boil. Add the spaghetti and cook according to the package instructions until al dente. Drain and set aside.",
      ],
    },
    {
      name: "Sauté the Vegetables",
      steps: [
        "In a large skillet, heat the olive oil over medium heat. Add the garlic and onion, sautéing until the onion becomes translucent, about 3-4 minutes.",
        "Add the bell pepper and zucchini to the skillet. Continue to cook, stirring occasionally, until the vegetables are tender, about 5-7 minutes.",
        "Stir in the cherry tomatoes and cook for another 2-3 minutes, until the tomatoes start to soften.",
      ],
    },
    {
      name: "Combine with Sauce",
      steps: [
        "Pour the marinara sauce into the skillet. Add oregano and basil, and season with salt and pepper. Reduce the heat and let the sauce simmer for about 5-10 minutes, allowing the flavors to meld.",
      ],
    },
    {
      name: "Mix Pasta and Sauce",
      steps: [
        "Add the cooked spaghetti to the skillet. Toss everything together until the pasta is well coated with the sauce. Cook for an additional 1-2 minutes to heat the spaghetti through.",
      ],
    },
    {
      name: "Serve",
      steps: [
        "Serve the spaghetti hot, garnished with fresh basil leaves. If desired, sprinkle nutritional yeast or vegan parmesan on top for added flavor.",
      ],
    },
  ];

  return (
    <div className="p-4">
      <RecipeCard
        imageUrl="/image.jpg"
        ingredients={ingredients}
        directions={directions}
      />
    </div>
  );
}
