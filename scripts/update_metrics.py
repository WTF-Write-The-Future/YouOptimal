import os
import requests
from supabase import create_client, Client
from dotenv import load_dotenv

# Завантажуємо ключі з файлу .env
load_dotenv("env")

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
WEATHER_API_KEY = os.environ.get("OPENWEATHER_API_KEY")

if not all([SUPABASE_URL, SUPABASE_KEY, WEATHER_API_KEY]):
    raise ValueError("Помилка: Не знайдено ключі API. Перевір файл .env")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_weather_and_aqi(city_name):
    try:
        # 1. Отримуємо координати міста
        geo_url = f"http://api.openweathermap.org/geo/1.0/direct?q={city_name}&limit=1&appid={WEATHER_API_KEY}"
        geo_res = requests.get(geo_url).json()
        
        if isinstance(geo_res, dict) and "message" in geo_res:
            print(f"Відмова від OpenWeather: {geo_res['message']}")
            return None
            
        if not geo_res: return None
        
        lat, lon = geo_res[0]['lat'], geo_res[0]['lon']

        # 2. Отримуємо прогноз погоди на 5 днів (інтервал 3 години) замість поточного /weather
        forecast_url = f"https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={WEATHER_API_KEY}&units=metric"
        f_data = requests.get(forecast_url).json()
        
        if 'list' not in f_data or not f_data['list']:
            return None

        # Беремо перші 8 записів (8 * 3 години = 24 години)
        next_24_hours = f_data['list'][:8]

        # Вираховуємо мінімальну та максимальну температуру за добу
        temp_min = min(item['main']['temp_min'] for item in next_24_hours)
        temp_max = max(item['main']['temp_max'] for item in next_24_hours)
        
        # Тиск беремо з поточного слоту прогнозу
        pressure = next_24_hours[0]['main']['pressure']

        # 3. Отримуємо якість повітря (залишається без змін)
        aqi_url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={WEATHER_API_KEY}"
        aqi_data = requests.get(aqi_url).json()

        raw_aqi = aqi_data['list'][0]['main']['aqi']
        converted_aqi = 100 - ((raw_aqi - 1) * 20) 

        return {
            "temp_min": round(temp_min, 1),
            "temp_max": round(temp_max, 1),
            "press": pressure,
            "aqi": converted_aqi
        }
    except Exception as e:
        print(f"Системна помилка для {city_name}: {e}")
        return None

def update_cities():
    print("З'єднання з базою Supabase...")
    cities = supabase.table("city").select("city_id, name").execute()
    
    for city in cities.data:
        data = get_weather_and_aqi(city['name'])
        
        if data:
            # Оновлюємо дані в таблиці citymetrics з новими полями temp_min та temp_max
            supabase.table("citymetrics").update({
                "temp_min": data['temp_min'],
                "temp_max": data['temp_max'],
                "atmospheric_pressure": data['press'],
                "air_quality_index": data['aqi']
            }).eq("city_id", city['city_id']).execute()
            print(f"✅ {city['name']} оновлено! (Мін: {data['temp_min']}°C, Макс: {data['temp_max']}°C, Тиск: {data['press']} hPa, AQI: {data['aqi']})")
        else:
            print(f"❌ Не вдалося знайти дані для {city['name']}")
             
    print("\n🎉 Всі міста успішно оновлено реальними даними!")

if __name__ == "__main__":
    update_cities()