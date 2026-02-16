# 🎲 PolyFakeApp - Swipe, Bet & Hardware Sync

PolyFakeApp est un projet interactif de paris fictifs reprenant les codes de navigation de Tinder (Swipe Right/Left). La particularité de ce projet est sa connectivité matérielle : le solde du joueur est envoyé en temps réel à une carte Arduino via un script relais en Python.

## 🏗️ Architecture du Projet

Le système repose sur trois composants principaux :

* **Frontend (Flutter) :** Application mobile (`main.dart`) gérant l'interface utilisateur, la logique des paris (cotes, probabilités, gains/pertes) et les animations de swipe fluides.
* **Middleware (Python) :** Un serveur socket local (`bridge.py`) qui écoute les connexions TCP de l'application mobile et agit comme un pont de communication.
* **Hardware (Arduino) :** Réceptionne les données du script Python via une liaison série (Serial) pour interagir physiquement avec la partie (par exemple, afficher le solde de pièces en temps réel).

## ✨ Fonctionnalités

* **Mécanique de Swipe :** Glissez à droite (OUI) ou à gauche (NON) pour parier sur divers événements (Sport, Crypto, Bourse, Météo, Espace, etc.).
* **Cotes Dynamiques :** Calcul automatique des cotes et des gains basés sur des probabilités de réussite prédéfinies.
* **Feedback Visuel :** Animations pop-up centrales et retours haptiques lors de la résolution immédiate du pari.
* **Synchronisation Matérielle :** Envoi direct du solde (`coins`) au réseau local à chaque mise à jour.

## 🛠️ Prérequis

* [Flutter SDK](https://flutter.dev/docs/get-started/install) pour compiler l'application mobile.
* [Python 3.x](https://www.python.org/downloads/)
* La librairie Python `pyserial` (à installer via `pip install pyserial`)
* Une carte Arduino branchée en USB.

## 🚀 Installation & Démarrage

### 1. Configuration de l'Arduino et du Pont Python
1. Branchez votre Arduino et téléversez votre code de réception série. **Fermez impérativement le moniteur série de l'IDE Arduino.**
2. Ouvrez `bridge.py` et vérifiez que le port COM correspond à votre Arduino :
   ```python
   ARDUINO_PORT = 'COM4' # Modifiez selon votre configuration (ex: /dev/ttyACM0 sur Linux/Mac)
