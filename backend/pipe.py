import pandas as pd
import chromadb
from sentence_transformers import SentenceTransformer
import ast
import os


class DiseaseDiagnosisPipeline:

    def __init__(self,model_name,base_path):
        """Initialize pipeline with model and database connection"""
        self.model_name = model_name if model_name else "sentence-transformers/all-mpnet-base-v2"
        self.model = SentenceTransformer(self.model_name)

        # Define dataset paths
        base_path = base_path
        self.disease_to_symptom = os.path.join(base_path, "reduced_Dataset.csv")
        self.disease_to_precaution = os.path.join(base_path, "symptom_precaution.csv")
        self.disease_to_description = os.path.join(base_path, "symptom_Description.csv")

        # Load DataFrames once to avoid redundant I/O
        self.df_symptoms = pd.read_csv(self.disease_to_symptom)
        self.df_precautions = pd.read_csv(self.disease_to_precaution)
        self.df_descriptions = pd.read_csv(self.disease_to_description)

        # Initialize ChromaDB
        self.chroma_client = chromadb.PersistentClient(path="chroma_db")
        self.collection = self.chroma_client.get_or_create_collection(name="symptoms_description")

        # Load data into ChromaDB (if not already populated)
        if self.collection.count() == 0:
            self.populate_chroma_db()

        self.closest_disease = None

    def populate_chroma_db(self):
        """Embeds and stores disease descriptions in ChromaDB."""
        for index, row in self.df_descriptions.iterrows():
            disease = row["Disease"]
            description = str(row["Description"]) if pd.notna(row["Description"]) else ""
            embedding = self.model.encode(description).tolist()

            self.collection.add(
                ids=[str(index)],
                metadatas=[{"disease": disease}],
                embeddings=[embedding],
                documents=[description]
            )

        print(f"ChromaDB populated with {self.collection.count()} records.")

    def find_similar_diseases(self, query_text, threshold=0.7, top_k=2):
        """Find diseases based on similarity with input symptoms description"""
        query_embedding = self.model.encode(query_text).tolist()

        results = self.collection.query(query_embeddings=[query_embedding], n_results=top_k)

        diseases_above_threshold = [
            results["metadatas"][0][i]["disease"]
            for i, similarity in enumerate(results["distances"][0])
            if similarity >= threshold  # Lower similarity score = better match
        ]

        return diseases_above_threshold if diseases_above_threshold else []

    def find_symptoms(self, diseases):
        """Retrieve symptoms associated with given diseases"""
        symptoms_set = set()

        for disease in diseases:
            matched_rows = self.df_symptoms[self.df_symptoms['Disease'].str.lower() == disease.lower()]
            for symptoms_str in matched_rows['Symptom']:
                try:
                    symptoms_list = ast.literal_eval(symptoms_str)
                    symptoms_set.update(symptom.strip().replace("_", " ") for symptom in symptoms_list)
                except (SyntaxError, ValueError):
                    continue

        return list(symptoms_set)

    def return_disease(self, selected_symptoms, closest_disease, threshold=0.5):
        """Find the most probable disease based on selected symptoms."""
        df = self.df_symptoms.copy()
        df['Disease'] = df['Disease'].str.lower()

        # Filter diseases
        filtered_df = df[df['Disease'].isin([d.lower() for d in closest_disease])]
        disease_matches = []

        for _, row in filtered_df.iterrows():
            try:
                symptoms_list = ast.literal_eval(row['Symptom'])
                symptoms_list = [s.strip().replace("_", " ") for s in symptoms_list]

                match_count = len(set(selected_symptoms) & set(symptoms_list))
                total_symptoms = len(set(symptoms_list))

                match_percentage = match_count / total_symptoms if total_symptoms > 0 else 0

                if match_percentage >= threshold:
                    disease_matches.append((row['Disease'], match_percentage))
            except (SyntaxError, ValueError):
                continue

        return sorted(disease_matches, key=lambda x: x[1], reverse=True)

    def return_precaution(self, disease):
        """Retrieve precautionary measures for a given disease"""
        df = self.df_precautions.copy()
        df['Disease'] = df['Disease'].str.lower()
        filtered_df = df[df['Disease'] == disease.lower()]

        if filtered_df.empty:
            return []

        return [filtered_df.iloc[0][col] for col in ['Precaution_1', 'Precaution_2', 'Precaution_3', 'Precaution_4'] if
                pd.notna(filtered_df.iloc[0][col])]

    def construct_message(self, disease, precautions):
        """Format the output message"""
        if not precautions:
            return f"No specific precautions found for {disease.capitalize()}."

        msg = f"**Precautions for {disease.capitalize()}**:\n\n"
        msg += "\n".join([f"    - {precaution}" for precaution in precautions])
        return msg


    #----  CRUD ----

    def start_chat(self,query_text):

        closest_disease = self.find_similar_diseases(query_text)

        self.closest_disease = closest_disease

        diseases = self.find_symptoms(closest_disease)

        return diseases

    def send_symptoms(self,selected_symptoms):

        matched_diseases = self.return_disease(selected_symptoms, self.closest_disease, threshold=0.2)

        self.closest_disease = None

        if matched_diseases:
            top_disease = matched_diseases[0][0]
            precautions = self.return_precaution(top_disease)
            final_message = self.construct_message(top_disease, precautions)
            return final_message
        else:
            return None


if __name__ == '__main__':

    # ---- Example Usage ----
    pipeline = DiseaseDiagnosisPipeline()

    query_text = "Pain in joints and stiffness, often worse in the morning."
    closest_disease = pipeline.find_similar_diseases(query_text)

    diseases = pipeline.find_symptoms(closest_disease)
    print(diseases)

    print(f"Closest matching diseases: {closest_disease}")

    selected_symptoms = ['movement stiffness', 'muscle weakness', 'painful walking', 'stiff neck']
    matched_diseases = pipeline.return_disease(selected_symptoms, closest_disease, threshold=0.2)

    print(f"Matched diseases: {matched_diseases}")

    if matched_diseases:
        top_disease = matched_diseases[0][0]
        precautions = pipeline.return_precaution(top_disease)
        final_message = pipeline.construct_message(top_disease, precautions)
        print(final_message)