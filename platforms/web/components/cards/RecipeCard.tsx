"use client";

import "swiper/css";
import { useState } from "react";
import { Swiper, SwiperClass, SwiperSlide } from "swiper/react";
import Checkbox from "../Checkbox";
import { Tabs } from "../Tabs";
import { TabList } from "../TabList";
import { Tab } from "../Tab";

export interface RecipeCardProps {
  imageUrl: string;
  ingredients: string[];
  directions: Array<{
    name: string;
    steps: string[];
  }>;
}

export default function RecipeCard({
  imageUrl,
  ingredients,
  directions,
}: RecipeCardProps) {
  const [selectedTab, setSelectedTab] = useState<"ingredients" | "directions">(
    "ingredients"
  );
  const [swiper, setSwiper] = useState<SwiperClass>();

  return (
    <div className="flex flex-col gap-4">
      <img
        className="aspect-video object-cover rounded-2xl w-full"
        src={imageUrl}
      />
      <Tabs
        onChange={(value) => {
          setSelectedTab(value as "ingredients" | "directions");
          swiper?.slideTo(value === "ingredients" ? 0 : 1);
        }}
        value={selectedTab}
      >
        <TabList>
          <Tab value="ingredients">Ingredients</Tab>
          <Tab value="directions">Directions</Tab>
        </TabList>
      </Tabs>
      <div>
        <Swiper
          spaceBetween={50}
          slidesPerView={1}
          onSlideChange={(swiper) => {
            console.log(swiper.activeIndex);
            setSelectedTab(
              swiper.activeIndex === 0 ? "ingredients" : "directions"
            );
          }}
          onSwiper={(swiper) => {
            setSwiper(swiper);
          }}
        >
          <SwiperSlide>
            <div className="flex flex-col gap-4">
              <ul className="flex flex-col gap-2">
                {ingredients.map((ingredient) => (
                  <li key={ingredient}>
                    <Checkbox label={ingredient} />
                  </li>
                ))}
              </ul>
            </div>
          </SwiperSlide>
          <SwiperSlide>
            <div className="flex flex-col gap-4">
              <ol className="list-decimal ml-6 space-y-4">
                {directions.map((direction) => (
                  <li className="ml-1 space-y-2" key={direction.name}>
                    <div>{direction.name}</div>
                    <ul className="space-y-2">
                      {direction.steps.map((step) => (
                        <li key={step}>
                          <Checkbox label={step} />
                        </li>
                      ))}
                    </ul>
                  </li>
                ))}
              </ol>
            </div>
          </SwiperSlide>
        </Swiper>
      </div>
    </div>
  );
}
