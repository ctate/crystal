import Spinner from "@/components/Spinner";
import RecipeCard from "@/components/cards/RecipeCard";
import { google } from "googleapis";
import { nanoid } from "nanoid";
import OpenAI from "openai";
import { z } from "zod";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || "",
});

export default function makeRecipe({ aiState }: any) {
  return {
    description: "Find a recipe and return it",
    parameters: z
      .object({
        name: z.string().describe("The name of the recipe"),
      })
      .required(),
    render: async function* ({ name }: { name: string }) {
      console.log("recipe");

      yield <Spinner />;

      const res = await google.customsearch("v1").cse.list({
        auth: process.env.GOOGLE_API_KEY!,
        cx: process.env.GOOGLE_SEARCH_ENGINE_ID!,
        q: `${name} recipe`,
        searchType: "image",
      });

      const completion = await openai.chat.completions.create({
        messages: [
          {
            role: "system",
            content: "You are an expert chef",
          },
          {
            role: "user",
            content: `
              Come up with a recipe for: ${name}
              
              Do not provide an explanation.
              
              Only return a JSON string in a format like this:

              {
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
            `,
          },
        ],
        model: "gpt-3.5-turbo-0125",
      });

      const content = completion.choices[0].message.content!;
      const data = JSON.parse(content.replace(/(^```json|```$)/, "")) as {
        ingredients: string[];
        directions: Array<{
          name: string;
          steps: string[];
        }>;
      };

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: nanoid(),
          content: `Here is a recipe for ${name}`,
          complete: true,
        },
      ]);

      return (
        <RecipeCard
          imageUrl={res.data.items![0].link!}
          ingredients={data.ingredients}
          directions={data.directions}
        />
      );
    },
  };
}
