import os
import requests
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv("env")

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Помилка: Не знайдено ключі Supabase у змінних оточення.")
    exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def fetch_nbu_rates():
    """Функція стягує актуальний курс з API Нацбанку України"""
    print("Запит до API НБУ...")
    url = "https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json"
    response = requests.get(url)
    
    if response.status_code != 200:
        raise Exception(f"Помилка API НБУ: {response.status_code}")
        
    data = response.json()
    
    usd_rate = next(item for item in data if item["cc"] == "USD")["rate"]
    eur_rate = next(item for item in data if item["cc"] == "EUR")["rate"]
    
    return usd_rate, eur_rate

def update_database():
    try:
        usd, eur = fetch_nbu_rates()
        print(f"Отримано курси: 1 USD = {usd} UAH, 1 EUR = {eur} UAH")
        
        eur_to_usd_cross = usd / eur 

        print("Оновлення бази даних Supabase...")
        
        # Оновлюємо курс гривні (до долара)
        supabase.table('exchange_rates').update({'rate': usd}).eq('currency_code', 'UAH').execute()
        
        # Оновлюємо курс євро (до долара)
        supabase.table('exchange_rates').update({'rate': eur_to_usd_cross}).eq('currency_code', 'EUR').execute()
        
        print("✅ Успіх! Курси валют оновлено.")

    except Exception as e:
        print(f"❌ Сталася помилка під час оновлення: {e}")

if __name__ == "__main__":
    update_database()