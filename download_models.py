import os
import shutil
from huggingface_hub import hf_hub_download, login

token = os.environ.get("HF_TOKEN")
if not token:
    raise RuntimeError("HF_TOKEN build arg is not set. Pass it with --build-arg HF_TOKEN=hf_xxx")

print("Authenticating with Hugging Face...")
login(token=token, add_to_git_credential=False)

os.makedirs("/ComfyUI/models/diffusion_models", exist_ok=True)

# Dasiwa BoundBite v10 — path confirmed from darksidewalker/DaSiWa-WAN2.2-I2V repo
# Saved with the same filenames the original workflow JSON expects
models = [
    (
        "darksidewalker/DaSiWa-WAN2.2-I2V",
        "Distilled/FP8/v10/DasiwaWAN22I2V14BLightspeed_boundbiteHighV10.safetensors",
        "/ComfyUI/models/diffusion_models/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors",
    ),
    (
        "darksidewalker/DaSiWa-WAN2.2-I2V",
        "Distilled/FP8/v10/DasiwaWAN22I2V14BLightspeed_boundbiteLowV10.safetensors",
        "/ComfyUI/models/diffusion_models/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors",
    ),
]

for repo_id, filename, dest in models:
    print(f"Downloading: {filename} ...")
    path = hf_hub_download(
        repo_id=repo_id,
        filename=filename,
        token=token,
        local_dir="/tmp/hf_downloads",
        local_dir_use_symlinks=False,
    )
    shutil.move(path, dest)
    print(f"  -> Saved to {dest} [OK]")

print("All Dasiwa model downloads complete.")
