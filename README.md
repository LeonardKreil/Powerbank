Fach::PMT2

Studenten::Leonard Kreil; Christoph Härdl; Michael Graml  

Betreuer::Prof. Dr. rer. nat. Roland Mandl

## Projektbeschreibung 📄

Das Projekt stellt eine batteriebetriebene Powerbank, die entweder über Solarpanelen oder USB-Mini Typ B Anschluss aufgeladen werden kann, dar. Dabei ist das Ziel die erzeugte Leistung für Kleingeräte zu verwenden. Außerdem kann per Smartphone App die Lade- sowie Entladeleistung und der aktuelle Ladestand der Batterie verfolgt und angezeigt werden. ![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/62cc3ec5-52fe-4520-8327-4983734a5881)

## Technischer Aufbau 🔧

Die in den angeschlossenen Solarpanelen erzeugte Spannung von bis zu 5 Volt wird zuerst vom Laderegler auf 3,7 Volt heruntergeregelt. Der auftretende Ladestrom wird anschließend in die Lithium Ionen Batterie eingespeist. Mithilfe eines angeschlossenen USB-Anschlusses kann die Leistung abgegriffen werden und zum Laden verwendet werden. Über ein Relais, das durch einen GPIO gesteuerten MOSFET geschalten wird, kann sowohl die Spannung auf der Eingangsseite als auch die Spannung auf der Ausgangsseite abgeschaltet werden. Dadurch kann man über einen Spannungsteiler die Leerlaufspannung der Batterie messen. Über die Leerlaufspannung kann dann der aktuelle Ladezustand der Batterie ermittelt werden.  ![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/c486ac8d-7286-49ab-b0d8-a08b0dbd3620)ei Analog-Digital Wandler, wird über eine weitere Batterie mit Spannung versorgt. Somit ist sichergestellt, dass bei geringer Ladekapazität der Hauptbatterie, die Messungen fortgeführt werden können. Zwischen Zweitbatterie und Microcontroller wurde ein DC-DC Converter eingebaut, der die Versorgungsspannung des ESP32 auf 3,3 Volt herunterregelt. Über die Analog-Digital-Wandler kann der Eingang- und Ausgangsstrom sowie die Leerlaufspannung der Batterie gemessen werden. Die beiden Ströme werden über einen Shunt Widerstand von 0,1 Ohm gemessen. Softwaretechnisch wird der ADC-Spannungs-Wert dann in einen Strom-Wert umgerechnet. ![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/4b9df60d-f861-4eda-8e38-3c019fca82ab) ![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/41f5cc8e-c083-467d-9763-e67212ba28e8)

### Stückliste

| 1 ||Solar Panels 2.5W/5V |- | 1 || Laderegler TP4056 |- | 1 || 5V USB Voltage Converter |- | 2 || 0.1 Ohm Widerstand |- | 1 || 1 MOhm Widerstand |- | 1 || 100 KOhm Widerstand |- | 1 || 33 KOhm Widerstand |- | 1 || ESP32 NodeMCU |- | 2 || ADS1115 |- | 2 || 18650 Lithium-Ionen Batterie |- | 2 || 18650 Batteriehalterung |- | 1 || Lochplatine |- | 1 || Diode |- |}

## Visualisierung durch App 💻

[[![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/ea3145a1-15d1-4ff2-a760-bda2c62ce854)]

## Software 📏

### Architektur

![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/73e134df-d8fc-4226-8314-60359f637af3)

### Spannungsmessung

Alle Spannungen werden über externe ADCs (ADS1115) gemessen. Da für das Messen der 3 Spannungen 6 Analog Eingänge benötigt werden, wurden 2 ADCs benötigt. Die Kommunikation erfolgt über I2C. Um die 2 ADCs softwaretechnisch unterscheiden zu können, müssen die Adressen für die Kommunikation festgelegt werden. Um kleine Spannungen intern nochmals zu verstärken, verfügen die ADCs über die Möglichkeit einen GAIN zu setzen. Durch einen höheren GAIN wird jedoch der Messbereich geringer. 

![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/578cd494-7b08-4a3f-af3f-284e838777f3)

![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/fb962db0-c5a4-4f3e-b1a7-80d167b8d420)

![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/2cffe34a-c1e9-42b2-aea0-c119917a217b)

Zur Messung der Leerlaufspannung der Batterie müssen zuerst die Stromkreise unterbrochen werden. Dies geschieht durch HIGH setzen eines GPIO Pins. Dadurch wird der eingebaute MOSFET leitend und das Relais schaltet. ![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/88d1839d-688d-4973-a3eb-f4b836d12e3f)

### Ladezustandsberechnung

Um die Kapazität aus der Leerlaufspannung zu berechnen, wird der oben dargestellte Zusammenhang durch Geradengleichungen approximiert. ![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/5812bbd1-0eb1-4097-b08e-820fdcf50380)

### Senden der Daten

Um die Daten für die App einfach zur Verfügung zu stellen, werden diese über MQTT an Amazon Web Services gesendet. Dort stellt der Service AWS IoT einen Dienst zur Verfügung, der immer die aktuellen Informationen des MQTT Topics über eine REST API zur Verfügung stellt. ![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/7eefcc50-1bb8-42c5-b9df-8b96137657b0)

### loop

Falls eine Last an der Powerbank hängt dürfen die Spannungen nicht gekappt werden. Deshalb wird vor dem Schalten des Relais überprüft, ob ein gewisser Schwellwert am Shuntwiderstand für den Ausgang übertroffen wurde. Um den Ladezustand trotzdem ungefähr bestimmen zu können, wird über die Ein- und Ausgangsleistung die Differenz des Ladeszustandes ermittelt. ![image](https://github.com/LeonardKreil/pmt_2/assets/119797039/ded5c922-3f97-4a18-870f-7cb725b1b4f4) <big>Der komplette 

## Probleme ⛔

Während der Projektarbeit sind zahlreiche Probleme aufgetreten, welche unseren Zeitplan verzögert haben. Durch die Verwendung von Labor-Relais, welche einen zu hohen und unregeläßigen Schaltpunkt besitzen, konnte die Spannungsmessung nicht wie gewünscht durchgeführt werden. Aufgrund des geringen Ausgangsstroms, scheiterte der Versuch die Ausgangsspannung des ESP 32 mit DC-DC Step-Up Convertern hoch zu transformieren. Schließlich brachte die verwendung eines Mosfet und ein neues Relais mit niedrigerem Schalpunkt den gewünschten Erfolg.

## Fazit 🔭

Hintergrundgedanke bei diesem Projekt war die Minimalausführung einer Stromerzeugung mit erneuerbaren Energien. Mithilfe eines Batteriespeichers ist es möglich, gewonnene Energie zu speichern, und bei Gebrauch abzurufen.  
Obwohl wir manche Arbeitsschritte zeitlich unterschätzt haben konnten wir die Solarbetriebene Powerbank erfolgreich fertigstellen. Abschließend kann man sagen, dass das Projekt "Solarbetriebene Powerbank mit App" ein sehr lehrreiches und interessantes Projekt war. 
## Quellen

https://datasheetspdf.com/pdf-file/1015118/EVER-WAYINDUSTRY/HK19F-DC3V/1  
https://dlnmh9ip6v2uc.cloudfront.net/datasheets/Prototyping/TP4056.pdf  
https://www.espressif.com/sites/default/files/documentation/esp32_datasheet_en.pdf 



