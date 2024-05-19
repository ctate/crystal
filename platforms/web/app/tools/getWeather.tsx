import Rain from "@/components/Rain";
import Stars from "@/components/Stars";
import { Client } from "@googlemaps/google-maps-services-js";
import { z } from "zod";

const client = new Client({});

interface WeatherInfo {
  name: string;
  temperature: number;
  windSpeed: string;
  windDirection: string;
  shortForecast: string;
}

function WeatherCard({ weather }: { weather: WeatherInfo }) {
  return (
    <div className="flex flex-col gap-2 justify-center items-center">
      <h2 className="flex justify-end text-6xl">
        {weather.temperature}
        <span className="text-lg">&deg;F</span>
        {/* <span className="text-gray-600 text-lg">&deg;C</span> */}
      </h2>
      <p className="text-sm">{weather.shortForecast}</p>
      {weather.shortForecast.toLowerCase().includes("rain") && <Rain />}
      <div
        className={
          weather.shortForecast.toLowerCase().includes("rain")
            ? "opacity-50"
            : ""
        }
      >
        <Stars />
      </div>
    </div>
  );
}

async function getWeatherApi(location: string) {
  const loc = await client.geocode({
    params: {
      key: process.env.GOOGLE_API_KEY!,
      address: location,
    },
  });

  const { lat, lng } = loc.data.results[0].geometry.location;

  const res = await fetch(`https://api.weather.gov/points/${lat},${lng}`);

  const data = (await res.json()) as {
    properties: {
      forecast: string;
      forecastHourly: string;
      forecastGridData: string;
    };
  };

  const res2 = await fetch(data.properties.forecast);

  const data2 = (await res2.json()) as {
    properties: {
      periods: Array<{
        name: string;
        temperature: number;
        windSpeed: string;
        windDirection: string;
        shortForecast: string;
      }>;
    };
  };

  return {
    name: data2.properties.periods[0].name,
    shortForecast: data2.properties.periods[0].shortForecast,
    temperature: data2.properties.periods[0].temperature,
    windSpeed: data2.properties.periods[0].windSpeed,
    windDirection: data2.properties.periods[0].windDirection,
  };
}

export default function getWeather({ aiState }: any) {
  return {
    description: "Get weather",
    parameters: z
      .object({
        location: z.string().describe("a location"),
      })
      .required(),
    render: async function* ({ location }: { location: string }) {
      console.log("getWeather");

      yield (
        <div className="text-center">
          <h2 className="animate-pulse bg-gray-300 text-4xl w-32">&nbsp;</h2>
        </div>
      );

      const weather = await getWeatherApi(location);

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "get_weather",
          content: JSON.stringify(weather),
          complete: true,
        },
      ]);

      return <WeatherCard weather={weather} />;
    },
  };
}
