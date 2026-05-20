# Simulatore Concorso UPP

Questo progetto è un **simulatore di quiz** sviluppato per esercitarsi in vista del Concorso per l'Ufficio per il Processo (UPP).
Si tratta di un'applicazione web "Single Page" leggera e veloce, che elabora e gestisce tutto localmente all'interno del browser, senza necessità di un server backend complesso o di un database.

## 🚀 Caratteristiche Principali

* **Gestione a Blocchi:** I quesiti (circa 300) vengono raggruppati in blocchi progressivi da 30 domande alla volta, simulando così vere e proprie sessioni di esame.
* **Timer Integrato:** Ogni blocco ha un tempo limite di 90 minuti (5400 secondi). Il timer offre un avviso visivo (rosso lampeggiante) negli ultimi 5 minuti.
* **Punteggio Real-Time:** Viene calcolato istantaneamente dopo ogni selezione.
  * Risposta esatta: +1.00 punti
  * Risposta errata: -0.33 punti
  * Quesito saltato: 0 punti
* **Randomizzazione:** L'applicazione rimescola automaticamente in modo casuale sia l'ordine in cui si presentano i quesiti, sia le tre opzioni di risposta per ogni singola domanda.
* **Persistenza e Salvataggio (Auto-Save):** Il progetto usa il `localStorage` del browser per salvare costantemente lo stato della simulazione (tempo, punteggio e avanzamento). Se il browser viene chiuso accidentalmente, è possibile riprendere esattamente dal punto di interruzione.
* **Barra di Progresso:** Mostra un indicatore visivo del completamento del blocco attuale di 30 domande.
* **Feedback Immediato:** Conferma la risposta esatta in verde e segnala visivamente la risposta errata o saltata.

## 📁 Struttura del Progetto

Il progetto è essenziale e si compone di due file:

1. `index.html`: È l'interfaccia utente (UI) e il "motore" dell'applicazione. Contiene il markup HTML, le classi per lo stile e tutto lo script Vue.js che orchestra il quiz.
2. `banca_dati.json`: Contiene l'intero database delle domande in formato JSON. Ogni quesito è strutturato così:
   ```json
   {
       "numero": 1,
       "domanda": "Testo dello scenario pratico o della domanda...",
       "risposta_esatta": "Opzione corretta",
       "opzione_errata_1": "Opzione sbagliata 1",
       "opzione_errata_2": "Opzione sbagliata 2"
   }
   ```

## 🛠️ Tecnologie Utilizzate

Il progetto non richiede l'installazione di librerie tramite NPM (Node Package Manager). Le dipendenze vengono importate tramite CDN:
* **HTML5**
* **Vue.js 3**: Framework JavaScript utilizzato per gestire reattività, stati e logica del flusso del quiz.
* **Tailwind CSS (v4)**: Framework CSS per l'implementazione rapida di uno stile moderno e responsivo.

## 🏃‍♂️ Come Avviare il Progetto

Per utilizzare il simulatore è importante non aprirlo facendo un semplice "doppio clic" sul file `.html`. I browser moderni bloccano le richieste interne a file JSON per motivi di sicurezza (CORS policy su protocollo `file://`).

**Serve un server web locale.**

* **Se usi Visual Studio Code**: 
  Installa l'estensione **Live Server**. Fai clic col tasto destro su `index.html` e seleziona _"Open with Live Server"_.
* **Usando Python** (se installato sul computer): 
  Apri un terminale nella cartella del progetto ed esegui:
  `python -m http.server`
  Poi apri il browser e vai su `http://localhost:8000`.
* **Usando Node.js / NPM**:
  Nel terminale esegui:
  `npx serve` oppure `npx http-server`

## 💾 Gestione del Progresso

Una volta completati tutti i blocchi fino ad esaurimento delle domande disponibili nel `banca_dati.json`, l'applicazione propone un pulsante per resettare del tutto i progressi archiviati nel browser, rimescolare i quiz e avviare un nuovo ciclo di studio.

## ⚙️ Personalizzare i Punteggi

Se desideri modificare i punti assegnati per le risposte esatte o la penalità per quelle errate (ad esempio per rimuovere le penalità, impostandole a zero), puoi farlo modificando direttamente il file `index.html`:

1. Apri `index.html` con un editor di testo o di codice (es. Blocco Note, Visual Studio Code).
2. Trova la funzione `selezionaRisposta(opzione)` nella sezione `<script>` (verso la fine del file) e modifica i valori numerici:
   ```javascript
   if (opzione.isCorrect) {
       this.punteggio += 1.00; // <- Modifica i punti per la risposta esatta qui
       this.risposteEsatte++;
   } else {
       this.punteggio -= 0.33; // <- Modifica la penalità per la risposta errata (es. metti -= 0)
   }
   ```
3. Per mantenere coerente anche l'interfaccia grafica, cerca all'interno dell'HTML (nella parte superiore del file) i testi descrittivi nei banner:
   * Cerca `Risposta Esatta! (+1.00 punti)`
   * Cerca `Errato (-0.33 punti)`
   
   E aggiorna il testo con i nuovi valori scelti.

*Nota bene: dopo aver salvato le modifiche al file `index.html`, ricordati di ricaricare la pagina del browser (F5) per rendere effettivi i nuovi punteggi.*

## 📄 Ricavare il file JSON dal PDF

Il progetto utilizza il file `banca_dati.json` per leggere i quesiti. Se possiedi il file PDF originale con le domande e vuoi generare o aggiornare questo file, il processo richiede due passaggi principali:
1.  **Estrazione del testo** dal file PDF.
2.  **Conversione del testo grezzo** in un formato JSON strutturato.

Per automatizzare il processo, puoi usare lo script fornito.

### Approccio con Script (Avanzato)

Lo script `crea_json_da_pdf.sh` (incluso nel progetto) automatizza l'estrazione del testo e tenta la conversione in JSON. **Richiede `pdftotext` (parte di poppler-utils) e `jq` installati sul sistema.**

1.  **Esegui lo script**: Apri un terminale nella cartella del progetto e lancia lo script, passando come argomenti il PDF di input e il nome del file JSON di output.
    ```bash
    bash crea_json_da_pdf.sh nome_file.pdf banca_dati.json
    ```
2.  **Verifica del risultato**: Lo script è progettato per funzionare con una struttura di testo specifica. Al termine, **è fondamentale verificare manualmente il file `banca_dati.json`** per correggere eventuali errori di parsing dovuti a variazioni nel layout del PDF. Puoi usare un validatore online come *JSONLint* per controllare la sintassi.

### Approccio con AI (Semplice e Consigliato)

Se non hai familiarità con la riga di comando o se lo script non produce un risultato perfetto, questo metodo è più rapido e affidabile.

1.  **Estrai il testo**: Puoi usare uno strumento online per convertire il PDF in testo, oppure copiare e incollare manualmente tutto il contenuto del PDF in un file di testo.
2.  **Usa un'AI**: Incolla il testo grezzo in un'intelligenza artificiale (come Gemini, Claude, ChatGPT) usando un prompt chiaro:
    > *"Converti il seguente testo di un quiz in un array JSON valido, strutturando ogni oggetto così: `{"numero": 1, "domanda": "...", "risposta_esatta": "...", "opzione_errata_1": "...", "opzione_errata_2": "..."}`. Assicurati che il JSON finale sia un array singolo contenente tutti gli oggetti. Ecco il testo: [incolla qui il testo estratto]"*
3.  **Salva e Verifica**: Copia l'output JSON generato dall'AI, incollalo nel file `banca_dati.json` e verifica la sua validità con *JSONLint* prima di avviare il simulatore.