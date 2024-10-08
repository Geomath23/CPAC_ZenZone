"""
This demo records sound and - when music is detected - it estimates the
underlying mood (emotion) and based on that it generates a respective color.
If available, it can even set your Yeelight Bulb color
(again based on the detected musical mood)
"""
import sys
import numpy
import argparse
import scipy.io.wavfile as wavfile
from pyAudioAnalysis.MidTermFeatures import mid_feature_extraction as mF
from pyAudioAnalysis import audioTrainTest as aT
import datetime
import signal
import pyaudio
import struct
from yeelight import Bulb
import cv2
import color_map_2d

global fs
global all_data
global outstr
fs = 8000
FORMAT = pyaudio.paInt16

"""
Load 2D image of the valence-arousal representation and define coordinates
of emotions and respective colors
"""
img = cv2.cvtColor(cv2.imread("music_color_mood.png"),
                   cv2.COLOR_BGR2RGB)

"""
Color definition and emotion colormap definition
"""
colors = {
    "orange": [255, 165, 0],
    "blue": [0, 0, 255],
    "bluegreen": [0, 165, 255],
    "green": [0, 205, 0],
    "red": [255, 0, 0],
    "yellow": [255, 255, 0],
    "purple": [128, 0, 128],
    "neutral": [255, 241, 224]}

disgust_pos = [-0.9, 0]
angry_pos = [-0.5, 0.5]
alert_pos = [0, 0.6]
happy_pos = [0.5, 0.5]
calm_pos = [0.4, -0.4]
relaxed_pos = [0, -0.6]
sad_pos = [-0.5, -0.5]
neu_pos = [0.0, 0.0]

# Each point in the valence/energy map is represented with a static color based
# on the above mapping. All intermediate points of the emotion colormap
# are then computed using the color_map_2d.create_2d_color_map() function:

emo_map = color_map_2d.create_2d_color_map([disgust_pos,
                                            angry_pos,
                                            alert_pos,
                                            happy_pos,
                                            calm_pos,
                                            relaxed_pos,
                                            sad_pos,
                                            neu_pos],
                                           [colors["purple"],
                                            colors["red"],
                                            colors["orange"],
                                            colors["yellow"],
                                            colors["green"],
                                            colors["bluegreen"],
                                            colors["blue"],
                                            colors["neutral"]],
                                           img.shape[0], img.shape[1])
emo_map_img = cv2.addWeighted(img, 0.4, emo_map, 1, 0)


def signal_handler(signal, frame):
    """
    This function is called when Ctr + C is pressed and is used to output the
    final buffer into a WAV file
    """
    # write final buffer to wav file
    if len(all_data) > 1:
        wavfile.write(outstr + ".wav", fs, numpy.int16(all_data))
    sys.exit(0)


signal.signal(signal.SIGINT, signal_handler)


def record_audio(block_size, devices, use_yeelight_bulbs=False, fs=8000):
    # initialize the yeelight devices:
    bulbs = []
    if use_yeelight_bulbs:
        for d in devices:
            bulbs.append(Bulb(d))
    try:
        b = bulbs[-1]  # Assumi che 'b' sia l'ultima lampadina aggiunta
        b.start_music()  # Attiva la modalità musica
        b.turn_on()  # Accendi la lampadina (opzionale)
    except Exception as e:
        print(f"Errore nel collegamento con Yeelight: {e}")
        bulbs = []

    # initialize recording process
    mid_buf_size = int(fs * block_size)
    pa = pyaudio.PyAudio()
    stream = pa.open(format=FORMAT, channels=1, rate=fs,
                     input=True, frames_per_buffer=mid_buf_size)

    mid_buf = []
    count = 0
    global all_data
    global outstr
    all_data = []
    outstr = datetime.datetime.now().strftime("%Y_%m_%d_%I:%M%p")

    # load segment model
    [classifier, mu, std, class_names,
     mt_win, mt_step, st_win, st_step, _] = aT.load_model("model")

    [clf_energy, mu_energy, std_energy, class_names_energy,
     mt_win_en, mt_step_en, st_win_en, st_step_en, _] = \
        aT.load_model("model_energy")

    [clf_valence, mu_valence, std_valence, class_names_valence,
     mt_win_va, mt_step_va, st_win_va, st_step_va, _] = \
        aT.load_model("model_valence")
    
    print(class_names_energy)
    
    last_valid_color = [255, 255, 255]  # Inizializzazione a un colore neutrale
    last_valid_classifications = {
    "energy": "neutral",
    "valence": "neutral"
    }  # Inizializzazione a valori neutrali
    last_valid_position = (0, 0)  # Inizializza con una posizione neutra

    while 1:
        block = stream.read(mid_buf_size)
        count_b = len(block) / 2
        format = "%dh" % (count_b)
        shorts = struct.unpack(format, block)
        cur_win = list(shorts)
        mid_buf = mid_buf + cur_win
        del cur_win
        color=None
        if len(mid_buf) >= 5 * fs:
            # data-driven time
            x = numpy.int16(mid_buf)
            seg_len = len(x)

            # extract features
            [mt_f, _, _] = mF(x, fs, seg_len, seg_len, round(fs * st_win),
                              round(fs * st_step))
            fv = (mt_f[:, 0] - mu) / std

            # classify vector:
            [res, prob] = aT.classifier_wrapper(classifier, "svm_rbf", fv)
            win_class = class_names[int(res)]
            if prob[class_names.index("silence")] > 0.8:
                soft_valence = 0
                soft_energy = 0
                print("Silence") 
                color = last_valid_color  # Usa l'ultimo colore valido
                x, y = last_valid_position  # Usa l'ultima posizione valida
                win_class_energy = last_valid_classifications["energy"]
                win_class_valence = last_valid_classifications["valence"]
            else:
                # extract features for music mood
                [f_2, _, _] = mF(x, fs, round(fs * mt_win_en),
                                 round(fs * mt_step_en), round(fs * st_win_en),
                                 round(fs * st_step_en))
                [f_3, _, _] = mF(x, fs, round(fs * mt_win_va),
                                 round(fs * mt_step_va), round(fs * st_win_va),
                                 round(fs * st_step_va))
                # normalize feature vector
                fv_2 = (f_2[:, 0] - mu_energy) / std_energy
                fv_3 = (f_3[:, 0] - mu_valence) / std_valence

                [res_energy, p_en] = aT.classifier_wrapper(clf_energy,
                                                           "svm_rbf",
                                                           fv_2)
                win_class_energy = class_names_energy[int(res_energy)]

                [res_valence, p_val] = aT.classifier_wrapper(clf_valence,
                                                             "svm_rbf",
                                                             fv_3)
                win_class_valence = class_names_valence[int(res_valence)]

                # Adjusted Energy and Valence calculations to include 'neutral'
                soft_energy = p_en[class_names_energy.index("dataset/energy_high")] - \
                p_en[class_names_energy.index("dataset/energy_low")] + \
                p_en[class_names_energy.index("dataset/energy_neutral")]

                soft_valence = p_val[class_names_valence.index("dataset/valence_positive")] - \
                p_val[class_names_valence.index("dataset/valence_negative")] + \
                p_val[class_names_valence.index("dataset/valence_neutral")]
                
                print(win_class, win_class_energy, win_class_valence,
                      soft_valence, soft_energy)

            all_data += mid_buf
            mid_buf = []

            h, w, _ = img.shape
            y_center, x_center = int(h / 2), int(w / 2)
            x = x_center + int((w / 2) * soft_valence)
            y = y_center - int((h / 2) * soft_energy)

            radius = 20
            emo_map_img_2 = emo_map_img.copy()
            
            
            
            try:
                color = numpy.median(emo_map[y - 2:y + 2, x - 2:x + 2], axis=0).mean(axis=0)
            except:
                pass
           
        if color is None or numpy.isnan(color).any():
            #print("Nan",last_valid_classifications)
            color = last_valid_color  # Usa l'ultimo colore valido
            win_class_energy = last_valid_classifications["energy"]
            win_class_valence = last_valid_classifications["valence"]
            x, y = last_valid_position  # Usa l'ultima posizione valida
        else:
            last_valid_color = color  # Aggiorna l'ultimo colore valido
            last_valid_classifications["energy"] = win_class_energy
            last_valid_classifications["valence"] = win_class_valence
            last_valid_position = (x, y)  # Aggiorna l'ultima posizione valida
            emo_map_img_2 = cv2.circle(emo_map_img_2, (x, y),
                               radius,
                               (int(color[0]), int(color[1]),
                                int(color[2])), -1)
            emo_map_img_2 = cv2.circle(emo_map_img_2, (x, y),
                               radius, (255, 255, 255), 2)
            
            cv2.imshow('Emotion Color Map', emo_map_img_2)

            # set yeelight bulb colors
            # Assicurati che i valori di colore siano interi validi tra 0 e 255
            if color is not None:
                red = int(max(0, min(255, color[2])))  # Limita i valori tra [0, 255]
                green = int(max(0, min(255, color[1])))
                blue = int(max(0, min(255, color[0])))

            if use_yeelight_bulbs:
                for b in bulbs:
                    if b:
                        # Attenzione: il colore è in BGR quindi bisogna invertire:
                        b.set_rgb(red, green, blue)

            cv2.waitKey(10)
            count += 1


def parse_arguments():
    record_analyze = argparse.ArgumentParser(description="Real time "
                                                         "audio analysis")
    record_analyze.add_argument("-d", "--devices", nargs="+",
                                default=["192.168.1.222"],
                                help="192.168.1.222")
    record_analyze.add_argument("-bs", "--blocksize",
                                type=float,
                                choices=[0.25, 0.5, 0.75, 1,2],
                                default=1, help="Recording block size")
    record_analyze.add_argument("-fs", "--samplingrate", type=int,
                                choices=[4000, 8000, 16000, 32000, 44100],
                                default=8000, help="Recording block size")
    return record_analyze.parse_args()


if __name__ == "__main__":
    args = parse_arguments()
    fs = args.samplingrate
    if args.devices:
        devices = args.devices
    else:
        devices = []
    if fs != 8000:
        print("Warning! Segment classifiers have been trained on 8KHz samples."
              " Therefore results will be not optimal. ")
    record_audio(args.blocksize, devices, True, fs)

