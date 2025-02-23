import pandas as pd
import chromadb
from sentence_transformers import SentenceTransformer

file_path = "/archive-5/symptom_Description.csv"  # Adjusted path
df = pd.read_csv(file_path)

# Initialize ChromaDB client
chroma_client = chromadb.PersistentClient(path="../chroma_db")

# Create or get a collection
collection_name = "symptoms_description"
collection = chroma_client.get_or_create_collection(name=collection_name)

# Load Hugging Face Sentence Transformer model
model = SentenceTransformer("sentence-transformers/all-mpnet-base-v2")

# Process and add data
for index, row in df.iterrows():
    disease = row["Disease"]
    description = str(row["Description"]) if pd.notna(row["Description"]) else ""

    # Generate embedding
    embedding = model.encode(description).tolist()

    # Insert into ChromaDB
    collection.add(
        ids=[str(index)],  # Unique identifier
        metadatas=[{"disease": disease}],
        embeddings=[embedding],
        documents=[description]
    )