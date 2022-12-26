# `class_data_dir` contains regularization images
import json
import os
import sys


import tkinter as tk
from tkinter import filedialog
import shutil
def main():
    folder_name = str(sys.argv[1])
    concepts_list = [
    {
        "instance_prompt":      "photo of " + folder_name + " person",
        "class_prompt":         "photo of a person",
        "instance_data_dir":    "./data/"+ folder_name,
        "class_data_dir":       "./data/person"
    },
    ]
    for c in concepts_list:
        os.makedirs(c["instance_data_dir"])

    with open("concepts_list.json", "w") as f:
        json.dump(concepts_list, f, indent=4)
    root = tk.Tk()
    root.withdraw()

    # Mostramos un diálogo para seleccionar las imágenes
    files = filedialog.askopenfilenames(title="Selecciona las imágenes")
    # Obtenemos la ruta de la carpeta local
    folder = os.path.join("data", folder_name)

    # Recorremos todas las imágenes seleccionadas y las copiamos a la carpeta local
    for file in files:
        shutil.copy(file, folder)

    # Mostramos un mensaje de éxito
    tk.messagebox.showinfo("Listo!", "Las imágenes se han subido correctamente a la carpeta seleccionada.")

    # Cerramos la ventana
    root.destroy()

main()

