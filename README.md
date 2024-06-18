Benodigdheden:
Firebase database
Flutter app
Esp8266 wifi-controller
Deze led strip: www.amazon.co.uk/gp/product/B07TB198W5?ie=UTF8&psc=1&linkCode=sl1&tag=marz-21&linkId=d86047a94dd28aa90d55f8e45ed243f1&language=en_GB&ref_=as_li_ss_tl

Aanmaken Firebase database en Flutter app.

Stap 1:
Maak een Firebase database aan.

Stap 2: 
Links in de navigatiebalk onder build, kan je een realtime database aanmaken. Hierin sla je vervolgens de LED_STATUS op en die zet je naar 0. Als de lamp uit is, dan is de status 0. Als de lamp aan is, dan is de status 1.

Stap 3:
Ga terug naar de homepagina van de Firebase database en klik onder apps op het Flutter icoontje. Dit is het meest rechtse icoontje.


Stap 4:
Volg vervolgens de stappen bij Add a Flutter app.

Stap 5: 
Gebruik de code uit de Github repository.

Koppelen wifi-controller (Esp8266) met Firebase

Stap 1:
Installeer de Arduino IDE en koppel de Esp8266 met je laptop.

Stap 2:
Installeer deze libraries.


Stap 3:
Upload de onderstaande code.




Stap 4:
Upload de code naar de esp8266 en check of alles werkt. 


Mochten er bepaalde onderdelen nog niet werken, volg dan deze documentatie:
rushankshah65.medium.com/how-to-make-an-iot-app-using-flutter-firebase-and-nodemcu-esp8266-b7a0a8c390ee
