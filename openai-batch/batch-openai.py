#!/usr/bin/env python3

import json
import os
from openai import OpenAI
import time
from typing import List, Dict
import csv


# ----------------------------- Configuration ----------------------------- #

# Path to the input JSON file
INPUT_FILE = "filtered-part2.json"

# Path to the output CSV file
OUTPUT_FILE = "filtered_ratings-part2.csv"

# OpenAI API Configuration
OPENAI_MODEL = "gpt-4o-mini"  # You can change this to "gpt-3.5-turbo" or another available model
MAX_TOKENS = 150
TEMPERATURE = 0

# Delay between API requests to respect rate limits (in seconds)
DELAY_BETWEEN_REQUESTS = 1  # Adjust based on your API plan

# Number of retries for failed API requests
MAX_RETRIES = 3

# -------------------------- End Configuration ---------------------------- #

client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),  # This is the default and can be omitted
)

def read_json(file_path: str) -> List[Dict]:
    """
    Read JSON data from a file and return as a list of dictionaries.
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data

def create_prompt(content: str) -> str:
    """
    Create a prompt for the OpenAI API based on the article's title and content.
    """
    prompt = (
        """
        Du bekommt im Folgenden eine Liste von schriftlichen Gutachten über einen wissenschaftlichen Text. Bewerte den Gutachtentext mit einem Wert zwischen 0 und 1 anhand folgender Kriterien:
            - K0: Prüfung der Forschungsfrage (z. B. sind Ziele und Begründung klar formuliert?)
            - K1: Bewertung der Originalität (Beitrag, Wissenszuwachs in der wissenschaftlichen Literatur oder im Fachgebiet)
            - K2: die Stärken und Schwächen der beschriebenen Methode werden klar benannt
            - K3: spezifische Anmerkungen zur Abfassung des Manuskripts (z. B. Schreibweise, Organisation, Abbildungen usw.)
            - K4: Interpretation der Ergebnisse durch den Autor und zu den aus den Ergebnissen gezogenen Schlussfolgerungen
            - K5: Gegebenenfalls Kommentare zu den Statistiken (z. B. die Frage, ob sie robust und zweckmäßig sind und ob die Kontrollen und Stichprobenmechanismen ausreichend und gut beschrieben sind)

        Bei deinen Bewertungen sollen Werte nahe 0 bedeuten, dass die Gutachter Schwächen oder Probleme in den jeweiligen Bewertungskriterien zum Ausdruck bringen. Werte nahe 1 bedeutet, dass die Bewertungskriterien zur vollsten Zufriedenheit der Gutachter erfüllt wurden. Wenn für die Bewertungskriterium keine ausreichenden Daten vorliegen oder eine Entscheidung nicht eindeutig ist, dann vergebe bitte den Wert "na".

        Bitte gib für jedes Gutachten Bewertungen nach allen Kriterien ab.

        Formatiere deine Antwort in folgendem CSV-Schema, pro Zeile soll ein Statement bewertet werden: "title";"primary_source";"expert";K0;K1;K2;K3;K4;K5
    
        Kommentiere das Ergebnis nicht weiter, sondern gebe nur CSV als Ergebnis aus. Bitte keine Code-Formatierung um das CSV.

        Hier ist die Liste der Gutachten. Sie liegen im JSON-Format vor. Die Gutachten befinden sich im Objekt "statements".
        
        {}
        """.format(content)    
    )

    return prompt

def get_openai_answer(prompt: str) -> str:
    
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = client.chat.completions.create(
                model=OPENAI_MODEL,
                messages=[
                    {"role": "system", "content": "You are a helpful assistant."},
                    {"role": "user", "content": prompt}
                ],
                #max_tokens=MAX_TOKENS,
                temperature=TEMPERATURE,
            )
            response_message = response.choices[0].message.content
            print(response_message)
            return response_message
        except Exception as e:
            print(f"Attempt {attempt} failed with error: {e}")
            if attempt < MAX_RETRIES:
                print(f"Retrying after {DELAY_BETWEEN_REQUESTS} seconds...")
                time.sleep(DELAY_BETWEEN_REQUESTS)
            else:
                print("Max retries reached. Skipping this entry.")
                return "Annotation failed."

def main():
            
    # Read the input JSON data
    try:
        articles = read_json(INPUT_FILE)
    except FileNotFoundError:
        print(f"Input file '{INPUT_FILE}' not found.")
        return
    except json.JSONDecodeError as jde:
        print(f"Error decoding JSON: {jde}")
        return    

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        # Initialize output file
        f.write('"article_id";"expert_id";"title";"primary_source";"expert";"K0";"K1";"K2";"K3";"K4";"K5"\n')        
    
        # Annotate articles
        for i,article in enumerate(articles):
            output = ""
            article_obj = json.dumps(article)

            # Create prompt for OpenAI
            prompt = create_prompt(article_obj)

            # Get summary from OpenAI
            output += get_openai_answer(prompt) + "\n"
            
            # Split the string by line breaks
            lines = output.splitlines()
    
            # Write each line to the output file
            for j,line in enumerate(lines):
                f.write(f"{i};{j};" + line + '\n')

            # Optional: Delay to respect rate limits
            time.sleep(DELAY_BETWEEN_REQUESTS)    

    print(f"Annotated data has been saved to '{OUTPUT_FILE}'.")

if __name__ == "__main__":
    main()