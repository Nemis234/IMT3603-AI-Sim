from chromadb.config import Settings
from chromadb import Client

##To view memory
client = Client(Settings(persist_directory="./store/"))
collections = client.list_collections()
print("Collections:", [c.name for c in collections])