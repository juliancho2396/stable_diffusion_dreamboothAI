if ! test -d "venv"; then
    echo "Creando ambiente virtual"
    python3 -m venv venv
    wait
    source ./venv/bin/activate
    
else
    # Si la carpeta no existe, imprimir otro mensaje
    source ./venv/bin/activate
    wait
fi


if ! dpkg -s python3 &> /dev/null; then
  sudo apt install python3
fi

if ! dpkg -s python3-tk &> /dev/null; then
  sudo apt install python3-tk
fi

# Comprobar si los archivos existen
if [ ! -f "./train_dreambooth.py" ]; then
    # Si el archivo no existe, descargarlo
    wget -q https://github.com/ShivamShrirao/diffusers/raw/main/examples/dreambooth/train_dreambooth.py
fi

if [ ! -f "convert_diffusers_to_original_stable_diffusion.py" ]; then
    # Si el archivo no existe, descargarlo
    wget -q https://github.com/ShivamShrirao/diffusers/raw/main/scripts/convert_diffusers_to_original_stable_diffusion.py
fi

if ! pip freeze | grep -q "torchvision"; then
    pip install torchvision
fi

if ! pip freeze | grep -q "diffusers"; then
    pip install -qq git+https://github.com/ShivamShrirao/diffusers
fi

if ! pip freeze | grep -q "triton"; then
    pip install -q -U --pre triton
fi

if ! pip freeze | grep -q "tkinter"; then
    
    pip3 install tk
fi

if ! pip freeze | grep -q "accelerate"; then
    pip install -q accelerate==0.12.0 transformers ftfy bitsandbytes gradio natsort
fi


if ! test -d "~/.huggingface"; then
    mkdir -p ~/.huggingface
fi

if ! test -d "stable_diffusion_weights"; then
    mkdir -p stable_diffusion_weights

fi

if cat ~/.huggingface/token | grep -q "."; then
    HUGGINGFACE_TOKEN=$(cat ~/.huggingface/token)
else
    echo "Ingresa la app token (HUGGINGFACE_TOKEN):"
    read TOKEN
    echo "$TOKEN" > ~/.huggingface/token
        
fi


if ! pip freeze | grep -q xformers; then
    pip install git+https://github.com/facebookresearch/xformers@4c06c79#egg=xformers
fi



MODEL_NAME="runwayml/stable-diffusion-v1-5" #@parm {type:"string"}
echo "Ingresa un nombre para el modelo:"
read nombremodelo
OUTPUT_DIR="stable_diffusion_weights/$nombremodelo" #@param {type:"string"}


if ! test -d "$OUTPUT_DIR"; then
    mkdir "$OUTPUT_DIR"
    python3 model_output_settings.py "$nombremodelo"
else
    echo "YA EXISTE UNA FIGURA CON ESTE NOMBRE"
fi
echo "$OUTPUT_DIR"

accelerate launch train_dreambooth.py \
  --pretrained_model_name_or_path="runwayml/stable-diffusion-v1-5" \
  --pretrained_vae_name_or_path="stabilityai/sd-vae-ft-mse" \
  --output_dir="./$OUTPUT_DIR" \
  --revision="fp16" \
  --with_prior_preservation --prior_loss_weight=1.0 \
  --seed=1337 \
  --resolution=512 \
  --train_batch_size=1 \
  --train_text_encoder \
  --mixed_precision="fp16" \
  --use_8bit_adam \
  --gradient_accumulation_steps=1 \
  --learning_rate=1e-6 \
  --lr_scheduler="constant" \
  --lr_warmup_steps=0 \
  --num_class_images=50 \
  --sample_batch_size=4 \
  --max_train_steps=1500 \
  --save_interval=10000 \
  --save_sample_prompt="photo of $nombremodelo person" \
  --concepts_list="./concepts_list.json"

# Reduce the `--save_interval` to lower than `--max_train_steps` to save weights from intermediate steps.
# `--save_sample_prompt` can be same as `--instance_prompt` to generate intermediate samples (saved along with weights in samples directory).

