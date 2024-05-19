"use client";

import Chip from "@/components/Chip";
import Meter from "@/components/Meter";
import RightArrowIcon from "@/components/icons/RightArrowIcon";

export default function PokedexCardPage() {
  return (
    <div className="flex flex-col gap-4">
      <div
        className="aspect-video object-contain rounded-2xl w-full"
        style={{
          backgroundImage:
            "url(https://img.freepik.com/free-photo/anime-style-clouds_23-2151071731.jpg?t=st=1714972711~exp=1714976311~hmac=cc178f1d3fc4858431214db2ea033225e99a947eb9cb3a623e26c6d0d4f65b2a&w=1800)",
          backgroundPosition: "bottom -1px center",
          backgroundSize: "200% auto",
        }}
      >
        <img
          className="aspect-video object-contain rounded-2xl w-full -mt-2"
          src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png"
        />
      </div>
      <div className="flex justify-between text-2xl">
        <h2>Bulbasaur</h2>
        <div>#001</div>
      </div>
      <div className="flex justify-between">
        <ul className="flex gap-4">
          <li>
            <Chip>Grass</Chip>
          </li>
          <li>
            <Chip>Poison</Chip>
          </li>
        </ul>
        <ul className="flex gap-4">
          <li>8.74 kg</li>
          <li>0.78 m</li>
        </ul>
      </div>
      <p className="text-sm">
        Bulbasaur is a dual-type Grass/Poison Pokémon, known as the Seed
        Pokémon. It is distinguished by its blue-green body with darker
        blue-green spots. Bulbasaur carries a green plant bulb on its back,
        which grows into a plant as it evolves.
      </p>

      <div className="bg-black bg-opacity-20 flex flex-col p-4 gap-4 rounded-2xl">
        <ul className="grid grid-cols-3 text-xs">
          <li className="flex flex-col justify-center items-center">
            <Meter size={50} strokeWidth={5} value={45} maxValue={216} />
            <div>HP</div>
          </li>
          <li className="flex flex-col justify-center items-center">
            <Meter size={50} strokeWidth={5} value={49} maxValue={152} />
            <div>Attack</div>
          </li>
          <li className="flex flex-col justify-center items-center">
            <Meter size={50} strokeWidth={5} value={49} maxValue={152} />
            <div>Defense</div>
          </li>
        </ul>
        <ul className="grid grid-cols-3 text-xs">
          <li className="flex flex-col justify-center items-center">
            <Meter size={50} strokeWidth={5} value={65} maxValue={194} />
            <div>Special Attack</div>
          </li>
          <li className="flex flex-col justify-center items-center">
            <Meter size={50} strokeWidth={5} value={65} maxValue={194} />
            <div>Special Defense</div>
          </li>
          <li className="flex flex-col justify-center items-center">
            <Meter size={50} strokeWidth={5} value={45} maxValue={152} />
            <div>Speed</div>
          </li>
        </ul>
      </div>
      <h3 className="text-2xl">Evolution</h3>
      <ul className="grid grid-cols-3 gap-4 -mt-6 text-center text-xs">
        <li className="flex flex-col gap-2 relative">
          <img
            className="aspect-square object-contain opacity-30 rounded-2xl w-full"
            src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png"
          />
          <div>Bulbasaur</div>
          <div className="absolute -right-5 top-16">
            <RightArrowIcon size={18} />
          </div>
        </li>
        <li className="flex flex-col gap-2 relative">
          <img
            className="aspect-square object-contain rounded-2xl w-full"
            src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/2.png"
          />
          <div>Ivysaur</div>
          <div className="absolute -right-5 top-16">
            <RightArrowIcon size={18} />
          </div>
        </li>
        <li className="flex flex-col gap-2 relative">
          <img
            className="aspect-square object-contain rounded-2xl w-full"
            src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/3.png"
          />
          <div>Venusaur</div>
        </li>
      </ul>
    </div>
  );
}
