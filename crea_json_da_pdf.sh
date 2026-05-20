#!/bin/bash

# Script per estrarre il testo da un PDF e tentare di convertirlo in un file JSON
# strutturato, utilizzando pdftotext per l'estrazione e jq per la formattazione.

# --- CONTROLLI PRELIMINARI ---

set -e

# Controlla se sono stati forniti i due argomenti necessari (input e output)
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "❌ Errore: Argomenti mancanti."
  echo "Uso: bash $0 <file_input.pdf> <file_output.json>"
  exit 1
fi

INPUT_PDF="$1"
OUTPUT_JSON="$2"
TEMP_TEXT_FILE="testo_estratto_temp.txt"

# Controlla se il comando 'pdftotext' è disponibile
if ! command -v pdftotext &> /dev/null; then
    echo "❌ Errore: 'pdftotext' non è installato. Per favore, installa 'poppler-utils'."
    exit 1
fi

# Controlla se il comando 'jq' è disponibile
if ! command -v jq &> /dev/null; then
    echo "❌ Errore: 'jq' non è installato. Per favore, installalo."
    exit 1
fi

# --- ESECUZIONE ---

echo "1. 📄 Estrazione del testo da '$INPUT_PDF'..."
# L'opzione -layout cerca di preservare l'impaginazione del testo originale
pdftotext -layout "$INPUT_PDF" "$TEMP_TEXT_FILE"
echo "   -> Testo estratto con successo in '$TEMP_TEXT_FILE'."

echo "2. ⚙️  Pre-elaborazione del testo e conversione in JSON..."

# Questo passaggio è il più delicato. Lo script 'awk' seguente tenta di raggruppare
# il testo in blocchi logici (numero, domanda, 3 risposte).
# Si assume che ogni nuova domanda inizi con un numero seguito da un punto.
# Il testo di ogni blocco viene poi unito e separato da un carattere pipe "|".

awk '
  # Se la riga inizia con un numero seguito da un punto, è una nuova domanda
  /^[0-9]+\./ {
    # Stampa il record precedente, se esiste
    if (NR > 1) { print record }
    # Pulisci il record e inizia con il nuovo numero (rimuovendo il punto)
    sub(/\./, "");
    record = $0;
    next
  }
  # Per tutte le altre righe non vuote, uniscile al record corrente
  NF > 0 {
    # Sostituisci i caratteri speciali per evitare errori nel JSON
    gsub(/\\/, "\\\\");
    gsub(/"/, "\\\"");
    gsub(/\|/, "/"); # Sostituisci eventuali pipe nel testo
    record = record "|" $0
  }
  END {
    # Stampa l'ultimo record
    print record
  }
' "$TEMP_TEXT_FILE" | jq -R '
    split("|") |
    {numero: .[0] | tonumber, domanda: .[1], risposta_esatta: .[2], opzione_errata_1: .[3], opzione_errata_2: .[4]}
' | jq -s . > "$OUTPUT_JSON"

echo "3. ✅ Fatto! Il file '$OUTPUT_JSON' è stato creato."
echo "   ⚠️ ATTENZIONE: Verifica manualmente il contenuto del file JSON per assicurarti che la conversione sia corretta, poiché il processo è complesso."

# --- PULIZIA ---
rm "$TEMP_TEXT_FILE"
exit 0