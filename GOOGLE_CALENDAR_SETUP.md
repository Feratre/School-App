# 🔗 Configurazione Google Calendar — School App

> [!IMPORTANT]
> Questi passaggi vanno eseguiti **una sola volta** per abilitare il login Google e la sincronizzazione con Google Calendar. Richiedono circa 10-15 minuti.

---

## Passo 1 — Crea un progetto su Google Cloud Console

1. Vai su **[console.cloud.google.com](https://console.cloud.google.com)**
2. Clicca **"Seleziona un progetto"** → **"Nuovo progetto"**
3. Nome: `SchoolApp` → **Crea**

---

## Passo 2 — Abilita Google Calendar API

1. Nel menu a sinistra: **API e Servizi → Libreria**
2. Cerca **"Google Calendar API"** → clicca → **Abilita**

---

## Passo 3 — Configura la schermata di consenso OAuth

1. **API e Servizi → Schermata consenso OAuth**
2. Tipo utente: **Esterno** → **Crea**
3. Compila:
   - Nome app: `SchoolMaster`
   - Email supporto: la tua email
4. **Salva e continua** su tutti i passaggi
5. Nella sezione **"Ambiti"** → **"Aggiungi o rimuovi ambiti"** → cerca e aggiungi:
   - `https://www.googleapis.com/auth/calendar`
6. Nella sezione **"Utenti di test"** → aggiungi la tua email Google
7. **Salva e continua** → **Torna al dashboard**

---

## Passo 4 — Crea le credenziali OAuth

### Per Android:

1. **API e Servizi → Credenziali → Crea credenziali → ID client OAuth 2.0**
2. Tipo applicazione: **Android**
3. Nome pacchetto: `com.schoolmaster.school_app`
4. Impronta SHA-1: esegui nel terminale:
   ```bash
   cd /home/reda/Documenti/Coding/school_master/school_app
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
   ```
5. Incolla l'impronta SHA-1 → **Crea**

### Per Web (sviluppo locale):

1. **Crea credenziali → ID client OAuth 2.0**
2. Tipo: **Applicazione web**
3. Nome: `SchoolApp Web`
4. **Origini JavaScript autorizzate**: aggiungi `http://localhost`
5. **URI di reindirizzamento**: aggiungi `http://localhost`
6. **Crea** → copia il **Client ID**

---

## Passo 5 — Aggiungi il Client ID all'app

### Android — `android/app/src/main/res/values/strings.xml`

Crea il file se non esiste:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">IL_TUO_CLIENT_ID_WEB.apps.googleusercontent.com</string>
</resources>
```

### Web — `web/index.html`

Aggiungi nel `<head>`:
```html
<meta name="google-signin-client_id" content="IL_TUO_CLIENT_ID_WEB.apps.googleusercontent.com">
```

---

## Passo 6 — Verifica finale

```bash
cd /home/reda/Documenti/Coding/school_master/school_app
flutter run
```

Vai su **Calendario** nell'app → tocca il banner **"Sincronizza Google Calendar"** → si aprirà il login Google → dopo l'accesso gli eventi appariranno automaticamente.

---

## Come funziona la sincronizzazione

| Azione | Comportamento |
|--------|---------------|
| Login Google | Scarica tutti gli eventi (mese precedente + 3 mesi) |
| Aggiungi evento nell'app | Creato immediatamente su Google Calendar con reminder |
| Elimina evento nell'app | Eliminato da Google Calendar in tempo reale |
| Aggiornamento automatico | Ogni **60 secondi** in background |
| Pulsante 🔄 | Sync manuale immediato |
| Logout | Rimuove eventi Google dall'app, quelli locali rimangono |

> [!NOTE]
> Gli eventi Google Calendar vengono categorizzati automaticamente: titoli con "verifica", "esame", "test", "interrogazione" → **VERIFICA** 🔴; "compito", "homework", "consegna" → **COMPITO** 🟡; tutti gli altri → **ALTRO**
