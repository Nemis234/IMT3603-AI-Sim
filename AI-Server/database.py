import chromadb
from chromadb.utils import embedding_functions
import uuid

class Memory:
    def __init__(self,client,collection_name:str):
        self.name = collection_name
        self.client = client
        self.collection = self.client.get_or_create_collection(name=collection_name)
        print(self.collection.name,self.collection.get())
        
     
        # For simplicity, using the default embedding
        self.embed_fn = embedding_functions.DefaultEmbeddingFunction()
    
    def add(self, role: str, message: str):
        """
        Adds a message (user or assistant) to memory.
        """
        doc_id = str(uuid.uuid4())
        self.collection.add(
            ids=[doc_id],
            documents=[message],
            metadatas=[{"role": role}]
        )

    def get_recent(self, n=5):
        """
        Returns last n inserted messages.
        """
        all_items = self.collection.get()
        ids = all_items["ids"]
        docs = all_items["documents"]
        metas = all_items["metadatas"]
        
        combined = [{"id": i, "role": m["role"], "message": d}
                    for i, m, d in zip(ids, metas, docs)]
        return combined[-n:]

    def query(self, text: str, n=10):
        """
        Retrieves top-n most relevant past messages for the given query.
        """
        results = self.collection.query(
            query_texts=[text],
            n_results=n
        )
        
        matches = [
            {"role": meta["role"], "content": doc}
            for doc, meta, in zip(
                results["documents"][0],
                results["metadatas"][0],
            )
        ]

        
        return matches

    def gemini_query(self, text: str, n=10):
        """
        Retrieves top-n most relevant past messages for the given query. Matches are returned in standard gemini request format
        """
        results = self.collection.query(
            query_texts=[text],
            n_results=n
        )
        
        matches = [
            {"role": meta["role"], "parts": [{'text': doc}]}
            for doc, meta, in zip(
                results["documents"][0],
                results["metadatas"][0],
            )
        ]

        
        return matches

