FROM wlsdml1114/engui_genai-base_blackwell:1.1 as runtime
RUN pip install -U "huggingface_hub[hf_transfer]"
RUN pip install runpod websocket-client
WORKDIR /
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip install -r requirements.txt
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    pip install -r requirements.txt
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/city96/ComfyUI-GGUF && \
    cd ComfyUI-GGUF && \
    pip install -r requirements.txt
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-KJNodes && \
    cd ComfyUI-KJNodes && \
    pip install -r requirements.txt
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    cd ComfyUI-VideoHelperSuite && \
    pip install -r requirements.txt
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kael558/ComfyUI-GGUF-FantasyTalking && \
    cd ComfyUI-GGUF-FantasyTalking && \
    pip install -r requirements.txt
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/orssorbit/ComfyUI-wanBlockswap
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper && \
    cd ComfyUI-WanVideoWrapper && \
    pip install -r requirements.txt
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/eddyhhlure1Eddy/IntelligentVRAMNode && \
    git clone https://github.com/eddyhhlure1Eddy/auto_wan2.2animate_freamtowindow_server && \
    git clone https://github.com/eddyhhlure1Eddy/ComfyUI-AdaptiveWindowSize && \
    cd ComfyUI-AdaptiveWindowSize/ComfyUI-AdaptiveWindowSize && \
    mv * ../
# ── Ungated models — no token needed ──────────────────────────────────────────
RUN wget -q https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors \
      -O /ComfyUI/models/clip_vision/clip_vision_h.safetensors
RUN wget -q https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors \
      -O /ComfyUI/models/text_encoders/umt5-xxl-enc-bf16.safetensors
RUN wget -q https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors \
      -O /ComfyUI/models/vae/Wan2_1_VAE_bf16.safetensors
# ── Gated Dasiwa BoundBite v10 — requires HF token ────────────────────────────
ARG HF_TOKEN
COPY download_models.py /download_models.py
RUN HF_TOKEN=${HF_TOKEN} python /download_models.py
# ── Download LoRAs ────────────────────────────────────────────────────────────
# ── Download LoRAs ────────────────────────────────────────────────────────────
RUN mkdir -p /ComfyUI/models/loras && HF_TOKEN=${HF_TOKEN} python << 'EOF'
from huggingface_hub import hf_hub_download
import os
os.makedirs('/ComfyUI/models/loras', exist_ok=True)
hf_hub_download('BillyInns/WAN_DR34ML4Y_All-In-One_NSFW', 'T2V_14b_HighNoise_v2.safetensors', local_dir='/ComfyUI/models/loras')
hf_hub_download('BillyInns/WAN_DR34ML4Y_All-In-One_NSFW', 'T2V_14b_LowNoise_v2.safetensors', local_dir='/ComfyUI/models/loras')
hf_hub_download('7777777sleep/CumFacial-Wan2.2-I2V', 'Wan22_CumV2_High.safetensors', local_dir='/ComfyUI/models/loras')
hf_hub_download('7777777sleep/CumFacial-Wan2.2-I2V', 'Wan22_CumV2_Low.safetensors', local_dir='/ComfyUI/models/loras')
print('LoRAs downloaded')
EOF
# ── Copy repo files ────────────────────────────────────────────────────────────
COPY . .
COPY extra_model_paths.yaml /ComfyUI/extra_model_paths.yaml
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
