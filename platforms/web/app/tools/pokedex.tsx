import Spinner from "@/components/Spinner";
import PokedexCardPage from "@/components/cards/PokedexCard";
import { nanoid } from "nanoid";
import { z } from "zod";

export default function pokedex({ aiState }: any) {
  return {
    description: "Identify a Pokemon using a picture",
    parameters: z
      .object({
        name: z.string(),
      })
      .required(),
    render: async function* ({ name }: { name: string }) {
      console.log("pokedex");

      yield <Spinner />;

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: nanoid(),
          content:
            "Bulbasaur is a dual-type Grass/Poison Pokémon, known as the Seed Pokémon. It is distinguished by its blue-green body with darker blue-green spots. Bulbasaur carries a green plant bulb on its back, which grows into a plant as it evolves. It is one of the three starter Pokémon available at the beginning of Pokémon games Red, Blue, Green, FireRed, and LeafGreen. As Bulbasaur gains experience, its bulb grows into a large plant, which is evident in its evolved forms, Ivysaur and eventually Venusaur. This Pokémon is known for its ability to absorb sunlight and convert it into energy, making it stronger in sunny conditions.",
          complete: true,
        },
      ]);

      return <PokedexCardPage />;
    },
  };
}
