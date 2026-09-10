# Kelime Rotası — Kurulum Rehberi

Bu klasördeki dosyalar, öğretmen paneli + öğrenci hesapları olan "gerçek ürün" versiyonu. Aşağıdaki adımları tek seferlik yapman yeterli; sonrasında hem sen hem öğrencilerin normal bir web sitesi gibi kullanır.

Toplam süre: yaklaşık 20-30 dakika. Kredi kartı gerekmiyor, her iki servisin de ücretsiz planı bu ölçekte fazlasıyla yeterli.

---

## Adım 1 — Supabase hesabı ve projesi oluştur

1. [supabase.com](https://supabase.com) adresine git, **"Start your project"** ile e-posta veya GitHub hesabınla kaydol.
2. Giriş yaptıktan sonra **"New Project"** butonuna bas.
3. İstenen bilgileri doldur:
   - **Name**: `kelime-rotasi` (istediğin bir isim)
   - **Database Password**: güçlü bir şifre oluştur ve bir yere not al (bu şifreyi kodda kullanmayacaksın, sadece ileride ihtiyaç olursa lazım)
   - **Region**: sana en yakın bölgeyi seç (örn. Frankfurt/EU)
4. **"Create new project"** de ve projenin hazırlanmasını bekle (1-2 dakika sürebilir).

## Adım 2 — Veritabanı şemasını kur

1. Sol menüden **SQL Editor**'a tıkla.
2. **"New query"** ile boş bir sorgu aç.
3. Bu klasördeki **`supabase-schema.sql`** dosyasını aç, içindeki her şeyi kopyala, SQL Editor'a yapıştır.
4. Sağ alttaki **"Run"** (veya Ctrl/Cmd+Enter) ile çalıştır. "Success" mesajını görmelisin.

Bu adım; öğretmen, sınıf, öğrenci ve kelime ilerlemesi tablolarını ve güvenlik kurallarını (bir öğretmenin sadece kendi öğrencilerini görebilmesi gibi) tek seferde kuruyor.

## Adım 3 — Öğrencilerin hesapsız girebilmesini aç

1. Sol menüden **Authentication → Sign In / Providers**'a git.
2. **"Anonymous Sign-Ins"** seçeneğini bul ve **aktif et**.

Bu, öğrencilerin e-posta/şifre olmadan sadece sınıf kodu + isimle girebilmesini sağlıyor.

## Adım 4 — Bağlantı bilgilerini al ve `config.js`'e yapıştır

1. Sol menüden **Project Settings → API**'ye git.
2. **Project URL** ve **anon public** anahtarını kopyala. (Bunlar gizli değil, tarayıcıda görünmesi normal — "service_role" anahtarını ASLA kullanma, o farklı bir şey.)
3. Bu klasördeki **`config.js`** dosyasını bir metin editörüyle aç, şu satırları kendi bilgilerinle değiştir:

   ```js
   window.KELIME_ROTASI_CONFIG = {
     SUPABASE_URL: "https://senin-projen.supabase.co",
     SUPABASE_ANON_KEY: "senin-anon-anahtarın"
   };
   ```
4. Kaydet.

## Adım 5 — Vercel'e yayınla

1. [vercel.com](https://vercel.com) adresine git, **"Sign Up"** ile kaydol (GitHub hesabınla girmek en kolayı).
2. Giriş yaptıktan sonra kontrol panelinde **"Add New… → Project"** de.
3. En basit yol: sağ üstte / ekranda **"Deploy without Git"** ya da proje oluşturma ekranındaki **sürükle-bırak alanına** bu klasördeki tüm dosyaları (`index.html`, `ogrenci.html`, `ogretmen.html`, `config.js` — `supabase-schema.sql` ve bu rehber hariç, onlar sadece senin için) sürükleyip bırak.
   - Eğer GitHub'a yüklemeyi tercih edersen: bu klasörü bir GitHub deposuna at, Vercel'de "Import Git Repository" ile o depoyu seç. Build ayarı gerekmiyor (saf HTML), "Deploy" demen yeterli.
4. Birkaç saniye içinde Vercel sana `kelime-rotasi-xxxx.vercel.app` gibi bir adres verecek. Bu, ürününün canlı adresi.

İstersen daha sonra Vercel proje ayarlarından kendi alan adını (`kelimerotasi.com` gibi) da bağlayabilirsin.

## Adım 6 — Test et

1. Yayınlanan adrese git (`.../index.html` ya da direkt `.../ogretmen.html`).
2. **Öğretmenim** ile kayıt ol, bir sınıf oluştur, oluşan **sınıf kodunu** not al.
3. Yeni bir sekmede (ya da telefonundan) **`.../ogrenci.html`**'e git, o kod + bir isimle katıl, birkaç kelime çalış.
4. Öğretmen paneline dön, sınıf detayına gir — az önce çalıştığın ilerlemenin göründüğünü doğrula.

Bir şey çalışmazsa ya da takılırsan, ekran görüntüsüyle birlikte buraya, bana yaz — birlikte çözeriz.

---

### Merak edebileceğin sorular

**Öğrenci farklı bir cihazdan girerse ilerlemesi kaybolur mu?**
Hayır — aynı sınıf kodu + aynı isimle değil, öğrencinin kendi cihazındaki tarayıcı hatırlıyor (bir kere katıldıktan sonra o cihazda otomatik devam ediyor). Cihaz değişirse şu an için yeniden katılması ve sıfırdan başlaması gerekir; ileride "kod ile eski hesaba bağlan" gibi bir geliştirme ekleyebiliriz, şimdilik bunu bilerek ilerliyoruz.

**Ücretsiz plan yeterli mi?**
Bu ölçek (birkaç sınıf, yüzlerce öğrenci) için Supabase ve Vercel'in ücretsiz planları rahatlıkla yeter. Kullanıcı sayın gerçekten büyürse (binlerce aktif öğrenci) o zaman ücretli plana geçmeyi konuşuruz — o da ayda birkaç dolar seviyesinde.

**`config.js`'i doldurmadan siteyi yayınlarsam ne olur?**
Hiçbir şey bozulmaz — `ogrenci.html` otomatik olarak eski "bu cihazda sakla" moduna döner, `ogretmen.html` ise "henüz bağlı değil" mesajı gösterir. Yani adımları istediğin hızda, panik olmadan ilerleyebilirsin.
