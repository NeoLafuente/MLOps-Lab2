import gradio as gr
import requests

# URL of the API created with FastAPI
API_URL = "https://mlops-lab2-frdj.onrender.com"

# Function to predict image class
def predict_image(image, class_names):
    try:
        # Save image to bytes
        import io
        from PIL import Image
        
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='PNG')
        img_byte_arr.seek(0)
        
        # Prepare the request
        files = {"file": ("image.png", img_byte_arr, "image/png")}
        data = {"class_names": class_names}
        
        response = requests.post(f"{API_URL}/predict", files=files, data=data, timeout=10)
        response.raise_for_status()
        result = response.json()
        return result.get("predicted_class")
    except requests.exceptions.HTTPError as e:
        return f"Error: {response.json().get('detail', str(e))}"
    except Exception as e:
        return f"Error: {str(e)}"

# Function to resize image
def resize_image(image, width, height):
    try:
        import io
        
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='PNG')
        img_byte_arr.seek(0)
        
        files = {"file": ("image.png", img_byte_arr, "image/png")}
        data = {"width": int(width), "height": int(height)}
        
        response = requests.post(f"{API_URL}/resize", files=files, data=data, timeout=10)
        response.raise_for_status()
        result = response.json()
        return str(result.get("resized_dimensions"))
    except requests.exceptions.HTTPError as e:
        return f"Error: {response.json().get('detail', str(e))}"
    except Exception as e:
        return f"Error: {str(e)}"

# GUI created using Gradio with Tabs
with gr.Blocks() as iface:
    gr.Markdown("# Image Classifier and Resizer")
    
    with gr.Tab("Predict"):
        with gr.Row():
            img_input = gr.Image(type="pil", label="Upload Image")
        class_input = gr.Textbox(
            value="cardboard,paper,plastic,metal,trash,glass",
            label="Class Names (comma-separated)"
        )
        predict_btn = gr.Button("Predict")
        predict_output = gr.Textbox(label="Predicted Class")
        
        predict_btn.click(predict_image, inputs=[img_input, class_input], outputs=predict_output)
    
    with gr.Tab("Resize"):
        with gr.Row():
            img_resize = gr.Image(type="pil", label="Upload Image")
        with gr.Row():
            width_input = gr.Number(value=256, label="Width")
            height_input = gr.Number(value=256, label="Height")
        resize_btn = gr.Button("Resize")
        resize_output = gr.Textbox(label="New Dimensions")
        
        resize_btn.click(resize_image, inputs=[img_resize, width_input, height_input], outputs=resize_output)

# Launch the GUI
if __name__ == "__main__":
    iface.launch()