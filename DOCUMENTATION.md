# Flutter-harjoitustyö: RecipeAppFlutter

## Tekijä

- Tekijä: Maria Piili  
- Kurssi: Mobiilisovelluskehitys / Flutter  
- Harjoitustyö on tehty yksin.

---

## Mitä sovellus tekee?

Sovelluksen nimi on **RecipeAppFlutter**.  
Se on Flutterilla tehty reseptisovellus, jossa käyttäjä voi:

- hakea ruokaohjeita verkosta hakusanan perusteella (esim. "chicken", "pasta");
- selata hakutuloksia listana;
- avata yksittäisen reseptin näkymän, jossa näkyvät kuva, ainesosat ja valmistusohje;
- lisätä reseptin **suosikkeihin**;
- lisätä reseptin ainesosat omaan **ostoslistaan**;
- merkitä ostoslistan rivejä tehdyksi (checkbox);
- jakaa reseptin tekstimuodossa esim. WhatsAppiin tai muihin sovelluksiin;
- kirjautua sisään omalla sähköpostilla ja salasanalla (Firebase Auth);
- käyttää samaa käyttäjätiliä usealla laitteella, jolloin suosikit ja ostoslista synkronoituvat pilven kautta;
- ostoslista-näkymässä painaa nappia **“Find nearby grocery store”**, joka avaa karttasovelluksen ja näyttää lähialueen ruokakauppoja.

Käynnistyksessä käyttäjä näkee lyhyen **onboarding-esittelyn** (3 ruutua). Sen jälkeen näytetään **Sign up / Sign in** -lomake. Onnistuneen kirjautumisen jälkeen avautuu varsinainen sovellus, jossa on alaosan navigointipalkki (Recipes, Favorites, Shopping list).

---

## Tilan hallinta (state management)

Sovellus käyttää Flutterin omaa tilanhallintaa:

- Pääsivu on `HomeScreen` (StatefulWidget), jossa ylläpidetään:
  - kirjautuneen käyttäjän suosikkireseptien listaa,
  - ostoslistan tilaa (tehty / ei tehty),
  - valitun välilehden tilaa (bottom navigation).
- Lapsiwidgetit (`_RecipesPage`, `_FavoritesPage`, `_ShoppingListPage`) saavat datan ja callbackit ylhäältä `HomeScreenistä`.
- Tila päivitetään `setState`-kutsuilla.

---

## Tiedon tallentaminen

### Paikallinen tallennus (laite)

Paikalliseen tallennukseen käytetään `shared_preferences` -pakettia ja omaa `LocalStorageService`-luokkaa.

- Tallennetaan:
  - paikallinen ostoslista (kun käyttäjä lisää / poistaa rivejä tai vaihtaa checkboxin tilaa),
  - tarvittaessa myös suosikkireseptien lista.
- Tiedot serialisoidaan JSON-muotoon (`toJson` / `fromJson` mallit `Meal` ja `ShoppingItem` -luokissa).

### Pilvitallennus (verkko / pilvi)

Pilvitallennukseen käytetään **Firebase Cloud Firestorea** (`cloud_firestore` + oma `FirestoreService`):

- Jokaiselle käyttäjälle luodaan oma dokumenttirakenne:
  - `users/{uid}/favorites` – suosikkireseptit,
  - `users/{uid}/shoppingList` – ostoslistan rivit.
- Kun käyttäjä lisää reseptin suosikkeihin tai päivittää ostoslistaa, muutokset kirjoitetaan Firestoreen.
- Kun käyttäjä kirjautuu sisään toisella laitteella, samat tiedot luetaan Firestoresta.

Lisäksi sama Firebase-datarakenne mahdollistaa sen, että samaa käyttäjätiliä voidaan käyttää usealla laitteella – näin resepti- ja ostoslistatiedot siirtyvät käytännössä käyttäjien välillä pilvipalvelun kautta.

---

## Tietojen haku verkosta

Sovellus hakee reseptit **TheMealDB**-rajapinnasta (ilmainen API resepteille).

- Rajapintakutsu tehdään `MealApiService`-luokassa käyttäen `http`-pakettia.
- Sovellus kutsuu esim. osoitetta  
  `https://www.themealdb.com/api/json/v1/1/search.php?s={query}`.
- Vastauksesta luodaan `Meal`-oliot (id, nimi, kuva, kategoria, alue, ainesosat, ohjeet).

---

## Käyttäjän tunnistaminen (Authentication)

Käyttäjien tunnistaminen toteutetaan **Firebase Authenticationin** avulla.

- Käytössä on **email + password** -kirjautuminen.
- `AuthService`-luokka kapseloi Firebase Auth -logiikan:
  - `signUpWithEmail` – luo uuden käyttäjän,
  - `signInWithEmail` – kirjaa sisään olemassa olevan käyttäjän,
  - `signOut` – kirjaa ulos.
- `SignupSheet`-widgetissä on kaksi tilaa:
  - **Sign Up** (uusi käyttäjä),
  - **Sign In** (kirjautuminen).
- Kirjautumistila ohjaa, kutsutaanko sign up vai sign in -metodia.

---

## Puhelimen ominaisuuksien hyödyntäminen

Sovellus hyödyntää seuraavaa laitteen ominaisuutta:

### Paikannus + karttasovellus

- Käytetään `geolocator`-pakettia nykyisen sijainnin hakemiseen.
- `LocationService`:
  - tarkistaa käyttöoikeudet (location permission),
  - kysyy tarvittaessa luvan käyttäjältä,
  - hakee `Position`-olion (latitude, longitude).
- Käytetään `url_launcher`-pakettia avaamaan karttasovellus (esim. Google Maps) hakukyselyllä:
  - tyyliin `https://www.google.com/maps/search/grocery+store/@lat,lng,15z`.
- Ostoslista-näkymässä on painike **“Find nearby grocery store”**, joka:
  - käyttää ensin laitteen sijaintia (`geolocator`),
  - avaa sen jälkeen kartan, josta käyttäjä näkee lähialueen ruokakauppoja.

---

## Käytetyt paketit

Tärkeimmät pub.dev -paketit:

- `http` – REST-rajapintakutsut TheMealDB:hen.
- `shared_preferences` – paikallinen tallennus (ostoslista, suosikit).
- `firebase_core` – Firebase-initialisointi.
- `firebase_auth` – kirjautuminen sähköpostilla ja salasanalla.
- `cloud_firestore` – pilvitietokanta (suosikit ja ostoslista käyttäjäkohtaisesti).
- `share_plus` – reseptin jakaminen tekstinä muihin sovelluksiin.
- `geolocator` – laitteen sijainti (GPS / verkko).
- `url_launcher` – karttasovelluksen (Google Maps tms.) avaaminen “Find nearby grocery store” -painikkeesta.
- `cupertino_icons` – ikonit (oletuspaketti).

---

## Ulkoiset palvelut

Sovellus käyttää seuraavia ulkoisia palveluita:

1. **TheMealDB API**  
   - Reseptien haku hakusanan perusteella.  
   - Käytetään vain lukuoikeuksilla (public API).

2. **Firebase Authentication**  
   - Email + password –kirjautuminen.  
   - Käyttäjätilien hallinta.

3. **Firebase Cloud Firestore**  
   - Käyttäjäkohtaiset suosikit ja ostoslista.

---

## Tietojen siirto käyttäjien välillä

Tietoja siirtyy käyttäjien ja laitteiden välillä kahdella tavalla:

- Firebase Cloud Firestoren avulla sama käyttäjätili voi käyttää samoja suosikki- ja ostoslistatietoja usealla laitteella.
- `share_plus`-paketin avulla käyttäjä voi jakaa reseptin sisällön muihin sovelluksiin (esimerkiksi viestisovelluksiin) ja näin välittää reseptitietoa toiselle henkilölle.

---

## Näkymät (views)

Sovelluksessa on seuraavat päänäkymät:

1. **Onboarding-näkymät (3 ruutua)**  
   - Lyhyt esittely sovelluksen ideasta (explore – welcome – sign up).  
   - Kuvalliset ruudut ja napit “Skip / Next / Done”.

2. **Signup / Sign in -bottom sheet**  
   - Avautuu alareunasta.  
   - Tekstikentät: email, password.  
   - Painike:
     - “Create account” (Sign up -tila),
     - “Log in” (Sign in -tila).  
   - Linkki tekstinä: “Already have an account? Sign in” / “Don’t have an account? Sign up”.

3. **`HomeScreen`, jossa bottom navigation**  
   - Tabit:
     - **Recipes** – hakukenttä + API:sta haettujen reseptien lista.
     - **Favorites** – käyttäjän suosikkireseptit (Firestore + local storage).
     - **Shopping list** – ostoslista, checkboxit ja “Find nearby grocery store” -painike.

4. **`MealDetailScreen`** (reseptin yksityiskohtanäkymä)  
   - Suuri kuva reseptistä (verkosta).  
   - Chipit kategoriasta ja alueesta (esim. "Dessert", "Italian").  
   - Ainesosat listana (bulletteina).  
   - Valmistusohjeet tekstinä.  
   - Painikkeet:
     - lisäys ostoslistaan (“Add ingredients to shopping list”),
     - jakaminen (share-ikoni AppBarissa),
     - suosikkisydän listan puolella.

---

## Kuvakaappaukset

### Onboarding

![Onboarding-näkymä](docs/screenshots/onboard1.png)
![Onboarding-näkymä](docs/screenshots/onboard2.png)
![Onboarding-näkymä](docs/screenshots/onboard3.png)

### Sign Up/ Sign In

![Sign Up](docs/screenshots/signUp.png)
![Sign In](docs/screenshots/signIn.png)

### Reseptien haku

![Recipes-välilehti](docs/screenshots/homeScreen.png)

### Suosikit

![Favorites-välilehti](docs/screenshots/favourites.png)

### Ostoslista ja lähikaupat

![Shopping list -välilehti](docs/screenshots/shoppingList.png)
![location](docs/screenshots/location1.png)
![location](docs/screenshots/location2.png)

---

## Perustuuko esimerkkikoodiin?

Sovelluksen toteutuksessa en käyttänyt mitään yksittäistä esimerkkiprojektia suoraan pohjana.

Harjoitustyön alussa selasin muutamia resepti- ja ruoka-aiheisia sovelluksia (esimerkiksi kuvakaappauksia ja UI-esimerkkejä netissä), jotta sain ideoita:

- värimaailmaan ja typografiaan,
- korttien ja kuvien asetteluun,
- bottom navigation -rakenteeseen ja onboarding-näkymien tyyliin.

En kuitenkaan kopioinut valmista koodia mistään projektista, vaan:

- koko sovelluksen rakenne (`models` / `services` / `screens` / `widgets`),
- logiikka (API-kutsut, Firebase-integraatio, paikallinen tallennus, ostoslista, suosikit),
- sekä käyttöliittymän toteutus

on kirjoitettu itse tätä harjoitustyötä varten.

---

## Tekoälyn käyttö toteutuksessa

Tässä projektissa on käytetty tekoälyä (ChatGPT / vastaava kielimalli) **tukityökaluna**, ei automaattisena koodigeneraattorina.

Tekoälyä on hyödynnetty erityisesti:

- **koodin siistimiseen ja parantamiseen**  
  - pienet refaktoroinnit,  
  - virheilmoitusten tulkinta ja ratkaisuehdotukset (esim. Firebase-konfiguraation ongelmat);
- **onboarding-näkymien kuvien suunnitteluun / generointiin**  
  - kuvien luominen ja muokkaus, jotka sitten tuotiin `assets/images` -kansioon.

Lopullinen koodi, logiikka ja integraatiot on kirjoitettu, testattu ja sovitettu kurssitehtävän vaatimuksiin itse.
