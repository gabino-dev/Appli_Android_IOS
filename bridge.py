import socket
import serial
import time

ARDUINO_PORT = 'COM4' 
BAUD_RATE = 9600

print(f"Connexion à l'Arduino sur {ARDUINO_PORT}...")
try:
    ser = serial.Serial(ARDUINO_PORT, BAUD_RATE, timeout=1)
    time.sleep(2) 
    print("Arduino connecté !")
except:
    print("Erreur : Vérifiez le port COM et ferme Arduino IDE.")
    exit()


server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(('0.0.0.0', 4545)) 
server.listen(1)

print("En attente de l'application Flutter...")

while True:
    conn, addr = server.accept()
    print(f"Appli connectée : {addr}")
    
    while True:
        try:
            data = conn.recv(1024)
            if not data: break
            
            message = data.decode('utf-8').strip()
            print(f"Reçu de Flutter : {message}")
            
            
            ser.write(bytes(message, 'utf-8'))
            
        except Exception as e:
            print("Erreur ou déconnexion")
            break
    conn.close()