from huggingface_hub import HfApi

api = HfApi()


file_path = api.hf_hub_download(
    repo_id="freznelai/FreznelAI_1.0_Face-Landmarker_500M_FZFP4_FRZm", 
    filename="FreznelAI_1.0_Face-Landmarker_500M_FZFP4.frzm"
)
print(f"File downloaded to: {path}")
