#!/usr/bin/env python3
"""
Генератор простых chiptune звуков без numpy
"""

import wave
import struct
import math
import os

SAMPLE_RATE = 44100

def generate_tone(frequency, duration, volume=0.5, wave_type='square'):
    """Генерирует звуковой тон"""
    num_samples = int(SAMPLE_RATE * duration)
    wave_data = []
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        
        if wave_type == 'square':
            sample = 1.0 if math.sin(2 * math.pi * frequency * t) >= 0 else -1.0
        elif wave_type == 'sawtooth':
            sample = 2.0 * (t * frequency - math.floor(0.5 + t * frequency))
        elif wave_type == 'triangle':
            sample = 2.0 * abs(2.0 * (t * frequency - math.floor(0.5 + t * frequency))) - 1.0
        else:  # sine
            sample = math.sin(2 * math.pi * frequency * t)
        
        # ADSR envelope
        attack = int(0.05 * SAMPLE_RATE)
        decay = int(0.1 * SAMPLE_RATE)
        sustain = int(0.5 * SAMPLE_RATE)
        release = int(0.35 * SAMPLE_RATE)
        
        if i < attack:
            envelope = i / attack
        elif i < attack + decay:
            envelope = 1.0 - (i - attack) / decay * 0.3
        elif i < attack + decay + sustain:
            envelope = 0.7
        else:
            envelope = max(0.0, 0.7 - (i - attack - decay - sustain) / release)
        
        sample = sample * envelope * volume
        
        # Конвертируем в 16-bit
        sample_int = int(sample * 32767)
        wave_data.append(struct.pack('<h', sample_int))
    
    return b''.join(wave_data)

def generate_click_sound():
    """Звук клика кнопки"""
    return generate_tone(800, 0.1, 0.3, 'square')

def generate_select_sound():
    """Звук выбора"""
    return generate_tone(1200, 0.15, 0.4, 'square')

def generate_alert_sound():
    """Звук предупреждения"""
    return generate_tone(400, 0.2, 0.5, 'sawtooth')

def generate_success_sound():
    """Звук успеха"""
    t1 = generate_tone(523, 0.1, 0.4, 'square')  # C5
    t2 = generate_tone(659, 0.1, 0.4, 'square')  # E5
    t3 = generate_tone(784, 0.15, 0.4, 'square')  # G5
    return t1 + t2 + t3

def generate_failure_sound():
    """Званк неудачи"""
    t1 = generate_tone(400, 0.15, 0.4, 'sawtooth')
    t2 = generate_tone(300, 0.2, 0.4, 'sawtooth')
    return t1 + t2

def generate_music_loop():
    """Простая музыкальная петля"""
    notes = [
        (262, 0.2),  # C4
        (294, 0.2),  # D4
        (330, 0.2),  # E4
        (349, 0.2),  # F4
        (392, 0.2),  # G4
        (440, 0.2),  # A4
        (494, 0.2),  # B4
        (523, 0.4),  # C5
    ]
    
    melody = b''
    for freq, dur in notes:
        melody += generate_tone(freq, dur, 0.3, 'square')
    
    return melody

def save_wav(wave_data, filename):
    """Сохраняет WAV файл"""
    dir_path = os.path.dirname(filename)
    os.makedirs(dir_path, exist_ok=True)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        wav_file.writeframes(wave_data)
    
    print(f"Generated: {filename}")

def main():
    print("Generating chiptune sounds...")
    
    # SFX
    save_wav(generate_click_sound(), "car_travelers/assets/audio/sfx/click.wav")
    save_wav(generate_select_sound(), "car_travelers/assets/audio/sfx/select.wav")
    save_wav(generate_alert_sound(), "car_travelers/assets/audio/sfx/alert.wav")
    save_wav(generate_success_sound(), "car_travelers/assets/audio/sfx/success.wav")
    save_wav(generate_failure_sound(), "car_travelers/assets/audio/sfx/failure.wav")
    
    # Music
    save_wav(generate_music_loop(), "car_travelers/assets/audio/music/menu_loop.wav")
    
    print("Done! All chiptune sounds generated.")

if __name__ == "__main__":
    main()
