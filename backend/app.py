import pipe
import setup
import yaml
import fastapi
import uvicorn
from typing import List, Union
from pydantic import BaseModel

class DiseaseInput(BaseModel):
    disease: str

class SymptomsInput(BaseModel):
    symptoms: List[str]

app = fastapi.FastAPI()
pipeline = None

@app.post("/get_symptoms")
def start_chat(query: DiseaseInput):

    result = pipeline.start_chat(query.disease)

    return result

@app.post("/submit_symptoms", response_model=List[str])
def send_symptoms(data: SymptomsInput):
    result = pipeline.send_symptoms(data.symptoms)

    # Debugging: Print the actual output
    print("Pipeline Output:", result.encode("utf-8"))

    # Ensure result is always a list
    if isinstance(result, str):
        result = [result]  # Convert string to list
    elif not isinstance(result, list):
        raise ValueError("pipeline.send_symptoms() must return a list of strings")

    return result

if __name__ == "__main__":

    #run setup
    config_file = setup.startup()

    #read config
    with open(config_file, "r") as file:
        data = yaml.safe_load(file)

    pipeline = pipe.DiseaseDiagnosisPipeline(model_name=data["embed_model"], base_path=data["database_path"])

    host = data["ip_config"]
    port = data["port_config"]

    #run app
    uvicorn.run(app, host=host, port=port)