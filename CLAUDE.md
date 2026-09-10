# Kelime Rotası — Proje Notları

## Proje özeti
- 8. sınıf öğrencilerinin İngilizce kelime ve LGS/MEB müfredatına çalışması için bir web uygulaması.
- Öğretmen paneli + öğrenci girişi (öğrenciler sınıf koduyla, e-posta olmadan giriş yapıyor).
- Saf HTML/CSS/JS — ayrı bir build adımı yok. Backend olarak Supabase (auth + veritabanı), yayın için Vercel kullanılıyor.
- Önemli dosyalar:
  - `index.html` — giriş/karşılama sayfası
  - `ogretmen.html` — öğretmen paneli
  - `ogrenci.html` — öğrenci arayüzü (kelime çalışma ekranı)
  - `config.js` — Supabase bağlantı bilgileri (SUPABASE_URL / SUPABASE_ANON_KEY)
  - `supabase-schema.sql` — veritabanı şeması
  - `KURULUM-REHBERI.md` — Supabase + Vercel kurulum adımları

## Basit işler için NVIDIA API kullanımı
Basit, düşük riskli görevlerde (kısa örnek cümle üretme, basit bir kelime açıklaması,
küçük bir metin taslağı, hızlı özetleme gibi) kendi kapasiteni harcamak yerine önce
şu komutu dene:

    ./scripts/nvidia-ask.sh "<görev metni>"

Bu komut NVIDIA'nın ücretsiz, OpenAI uyumlu API'sine istek atar ve cevabı ekrana basar.
API anahtarı proje kökündeki `.env` dosyasındaki `NVIDIA_API_KEY` değişkeninden okunur
(örnek için `.env.example`'a bakabilirsin — `.env` dosyası git'e eklenmez).

Karmaşık, çok adımlı, proje bağlamı gerektiren veya doğrudan kod/dosya değişikliği
içeren işlerde bu API'yi kullanma — onları kendin yap.
