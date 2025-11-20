import chromadb
from chromadb import Documents,Embeddings
from chromadb.utils import embedding_functions
import uuid
import numpy as np

NUM_SAVES = 3 #Number of save slots

#Map of all saves to collection list
saves_map = {str(i+1): [] for i in range(NUM_SAVES)}

#CUSTOM EMBEDDING FUNCTION: appends recency to the standard embedding
class BiasedEmbeddingFunction(embedding_functions.EmbeddingFunction):
    def __init__(self, base_embed_fn, alpha=0):
        self.base = base_embed_fn
        #self.bias = bias_value

    def __call__(self, input:Documents, recency=1) -> Embeddings:
        base_embeds = np.array(self.base(input))
        bias_component = np.full((base_embeds.shape[0], 1), recency)
        
        # Append bias as an extra dimension
        return (np.concatenate([base_embeds, bias_component], axis=1)).tolist()

class Memory:
    def __init__(self,client,collection_name:str,slot='0'):
        self.name = collection_name
        self.client = client
        self.collection = client.get_or_create_collection(name=f"{collection_name}_{slot}")

        #Add the collection to saves map if it doesnt exist in saves map already
        if slot in saves_map:
            if self.collection.name not in saves_map:
                saves_map[slot].append(self.collection.name)


        print(self.collection.name,self.collection.get(include=["documents", "metadatas"]))
        print("\n\n\n")
        
     
        # For simplicity, using the default embedding
        #self.embed_fn = embedding_functions.DefaultEmbeddingFunction()

        #Embedding function that adds recency
        self.embed_fn =  BiasedEmbeddingFunction(base_embed_fn=embedding_functions.DefaultEmbeddingFunction())
    
    def add(self, role: str, message: str, time_stamp:str = 'None'):
        """
        Adds a message (user or assistant) to memory.
        """

        #Create embedding using custom distance function
        embedding = self.embed_fn(input = [message])
        
        doc_id = str(uuid.uuid4())
        self.collection.add(
            ids=[doc_id],
            documents=[message],
            metadatas=[{"role": role,"time_stamp": time_stamp, "recency": 1}],
            embeddings = embedding
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

        #Embedding corresponding to incoming query
        query_embedding = self.embed_fn(input=[text])
        
        results = self.collection.query(
            query_embeddings = [query_embedding],
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

        #Embedding corresponding to incoming query
        query_embedding = self.embed_fn(input=[text])

        results = self.collection.query(
            query_embeddings = query_embedding,
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
    
    def update_recency(self,decay=0.99):
        data = self.collection.get(include=["embeddings","metadatas"]) #GETS ONLY FIRST 100 BY DEFAULT ADJUST LIMIT IF REQUIRED

       
        ids = data["ids"]
        metadatas = data["metadatas"]
        embeddings = data["embeddings"]

        if ids:
            #Get new embeddings with updated recencies
            new_embeddings = []
            for ind,id in enumerate(ids):
                embeddings[ind][-1] = embeddings[ind][-1] * decay #Changing last feature in embdding (which denotes recency)
                new_embeddings.append(embeddings[ind])

                metadatas[ind]["recency"] =  embeddings[ind][-1] #Update recency in metadata
            
            #print(new_embeddings)
            self.collection.update(
                            ids=ids,
                            metadatas = metadatas ,
                            embeddings = new_embeddings       
            )


if __name__=="__main__":
    ##Experiment with chromadb embeddings##
    emb_fn_d = embedding_functions.DefaultEmbeddingFunction()
    embd_fn_new = BiasedEmbeddingFunction(base_embed_fn=emb_fn_d)

    e1 =  emb_fn_d(["foo"])
    e2 = embd_fn_new(["foo"])

    #print(e1)
    #print(e2)

    test_client = chromadb.PersistentClient(path=f"./test/")
    collection = test_client.get_or_create_collection(name="test")
    collection.add(ids = ["1"],
                    documents =["foo"],
                    metadatas = [{"role": "user","time_stamp": "8:00","recency":1}],
                    embeddings = e2)
    
    data = collection.get(include=["embeddings", "documents", "metadatas"])
    
    print(data["ids"])