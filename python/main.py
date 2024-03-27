import cv2
import numpy as np
from PIL import Image

def load_image(image_path):
    image = cv2.imread(image_path)
    
    if image is None:
        print("Nie można wczytać obrazu.")
        return None
    
    normalized_image = cv2.normalize(image, None, alpha=0, beta=255, norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_8U)
    
    return normalized_image

def show_img(img, title = ""):
    cv2.imshow(title, img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def apply_mask(img_BRG, mask):
    img_BRG[np.where((mask == 0).all(axis=2))] = [0, 0, 0]
    return img_BRG
     
def colorize_image(img_BRG, mask, colormap=cv2.COLORMAP_JET):
    gray_image = cv2.cvtColor(img_BRG, cv2.COLOR_BGR2GRAY)
    
    if colormap:
        colorized_image = cv2.applyColorMap(gray_image, colormap)
    else:
        colorized_image = cv2.merge([gray_image, gray_image, gray_image])
        
    colorized_image = apply_mask(colorized_image, mask)
    
    return colorized_image

def shift_img_values(img_gray, shift: int):
    shifted_image = np.mod(img_gray.astype(int) + shift, 256).astype(np.uint8)
    return shifted_image

def save_frames_as_gif(frames, filename, fps=10):
    height, width, _ = frames[0].shape
    fourcc = cv2.VideoWriter_fourcc(*'GIF ')
    out = cv2.VideoWriter(filename, fourcc, fps, (width, height))
    for frame in frames:
        out.write(frame)
    out.release()

def get_frames(img_gray, mask, colormap, value_range = 256, delta = 4):
    frames = []
    num_of_frames =  int(value_range/delta)
    for ii in range(num_of_frames):
        shift = ii*delta
        frame = colorize_image( shift_img_values(img_gray, shift) , mask, colormap)
        frames.append(frame)
        
    return frames   

def save_frames_as_gif(frames_cv, filename, duration=50):

    frames_pillow = [Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)) for frame in frames_cv]
    frames_pillow[0].save(filename, save_all=True, append_images=frames_pillow[1:], optimize=False, duration=duration, loop=0)

img_amp = load_image(r'materials\vortex_amp.png')
img_phase = load_image(r'materials\vortex_phase1.png')

img_phase_jet = colorize_image(img_phase, img_amp, cv2.COLORMAP_JET)
img_phase_twilight = colorize_image(img_phase, img_amp, cv2.COLORMAP_TWILIGHT)

#---------------------------------------
img_amp = load_image(r'materials\vortex_amp.png')
img_phase = load_image(r'materials\vortex_phase1.png')

frames = get_frames(img_phase, img_amp, [])
save_frames_as_gif(frames, r'python\anim_phase1_gray.gif')

frames = get_frames(img_phase, img_amp, cv2.COLORMAP_TWILIGHT)
save_frames_as_gif(frames, r'python\anim_phase1_twilight.gif')

frames = get_frames(img_phase, img_amp, cv2.COLORMAP_JET)
save_frames_as_gif(frames, r'python\anim_phase1_jet.gif')

#----------------------------------------------

img_amp = load_image(r'materials\vortex_amp.png')
img_phase = load_image(r'materials\vortex_phase2.png')

frames = get_frames(img_phase, img_amp, [])
save_frames_as_gif(frames, r'python\anim_phase2_gray.gif')

frames = get_frames(img_phase, img_amp, cv2.COLORMAP_TWILIGHT)
save_frames_as_gif(frames, r'python\anim_phase2_twilight.gif')

frames = get_frames(img_phase, img_amp, cv2.COLORMAP_JET)
save_frames_as_gif(frames, r'python\anim_phase2_jet.gif')

