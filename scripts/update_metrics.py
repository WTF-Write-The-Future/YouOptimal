import os
import requests
from supabase import create_client, Client
from dotenv import load_dotenv

# Завантажуємо ключі з файлу .env
load_dotenv()

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
WEATHER_API_KEY = os.environ.get("OPENWEATHER_API_KEY")

if not all([SUPABASE_URL, SUPABASE_KEY, WEATHER_API_KEY]):
    raise ValueError("Помилка: Не знайдено ключі API. Перевір файл .env")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ... далі йде твоя функція get_weather_and_aqi та update_cities

def get_weather_and_aqi(city_name):
    try:
        # 1. Отримуємо координати міста
        geo_url = f"http://api.openweathermap.org/geo/1.0/direct?q={city_name}&limit=1&appid={WEATHER_API_KEY}"
        geo_res = requests.get(geo_url).json()
        
        # ДОДАНО: Перевіряємо, чи не повернув сервер помилку (наприклад, 401 Unauthorized)
        if isinstance(geo_res, dict) and "message" in geo_res:
            print(f"Відмова від OpenWeather: {geo_res['message']}")
            return None
            
        if not geo_res: return None
        
        lat, lon = geo_res[0]['lat'], geo_res[0]['lon']

        # 2. Отримуємо погоду та тиск
        w_url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={WEATHER_API_KEY}&units=metric"
        w_data = requests.get(w_url).json()
        
        # 3. Отримуємо якість повітря
        aqi_url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={WEATHER_API_KEY}"
        aqi_data = requests.get(aqi_url).json()

        raw_aqi = aqi_data['list'][0]['main']['aqi']
        converted_aqi = 100 - ((raw_aqi - 1) * 20) 

        return {
            "temp": w_data['main']['temp'],
            "press": w_data['main']['pressure'],
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
            # Оновлюємо дані в таблиці citymetrics
            supabase.table("citymetrics").update({
                "temperature": data['temp'],
                "atmospheric_pressure": data['press'],
                "air_quality_index": data['aqi']
            }).eq("city_id", city['city_id']).execute()
            print(f"✅ {city['name']} успішно оновлено! (Температура: {data['temp']}°C, Тиск: {data['press']}hPa, AQI: {data['aqi']})")
        else:
             print(f"❌ Не вдалося знайти дані для {city['name']}")
             
    print("\n🎉 Всі міста успішно оновлено реальними даними!")

if __name__ == "__main__":
    update_cities()