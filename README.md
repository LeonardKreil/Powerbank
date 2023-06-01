{| width="99%"
 | style="vertical-align:top" |

__NOTOC__
<div style="border: 1px solid black; background-color:purple; font-size:1px; height:20px; border-bottom:1px solid 97BF87">
</div >
<div style="border: 1px solid black; background-color:whitesmoke; padding:7px;">
__NOEDITSECTION__
==''Fach''==
'''PMT2'''

==''Studenten''==
'''Leonard Kreil <br> Christoph Härdl <br> Michael Graml <br>'''

==''Betreuer''==
'''Prof. Dr. rer. nat. Roland Mandl'''

| width="80%" style="vertical-align:top" |
<br>

__INHALTSVERZEICHNIS__

<h2 style="font-size:200%; text-align:center;">Projektbeschreibung 📄</h2>

Das Projekt stellt eine batteriebetriebene Powerbank, die entweder über Solarpanelen oder USB-Mini Typ B Anschluss aufgeladen werden kann, dar. Dabei ist das Ziel die erzeugte Leistung für Kleingeräte zu verwenden. Außerdem kann per Smartphone App die Lade- sowie Entladeleistung und der aktuelle Ladestand der Batterie verfolgt und angezeigt werden. 

[[Datei:Hardware1.png|400px|center]]

<h2 style="font-size:200%; text-align:center;">Technischer Aufbau 🔧</h2>

Die in den angeschlossenen Solarpanelen erzeugte Spannung von bis zu 5 Volt wird zuerst vom Laderegler auf 3,7 Volt heruntergeregelt. Der auftretende Ladestrom wird anschließend in die Lithium Ionen Batterie eingespeist. Mithilfe eines angeschlossenen USB-Anschlusses kann die Leistung abgegriffen werden und zum Laden verwendet werden. Über ein Relais, das durch einen GPIO gesteuerten MOSFET geschalten wird, kann sowohl die Spannung auf der Eingangsseite als auch die Spannung auf der Ausgangsseite abgeschaltet werden. Dadurch kann man über einen Spannungsteiler die Leerlaufspannung der Batterie messen. Über die Leerlaufspannung kann dann der aktuelle Ladezustand der Batterie ermittelt werden.

[[Datei:Average-open-circuit-voltage-state-of-charge-OCV-SOC-relationship.png|600px|center]]

Unsere Messeinheit, bestehend aus einem ESP32 Microcontroller und zwei Analog-Digital Wandler, wird über eine weitere Batterie mit Spannung versorgt. Somit ist sichergestellt, dass bei geringer Ladekapazität der Hauptbatterie, die Messungen fortgeführt werden können. Zwischen Zweitbatterie und Microcontroller wurde ein DC-DC Converter eingebaut, der die Versorgungsspannung des ESP32 auf 3,3 Volt herunterregelt. Über die Analog-Digital-Wandler kann der Eingang- und Ausgangsstrom sowie die Leerlaufspannung der Batterie gemessen werden. Die beiden Ströme werden über einen Shunt Widerstand von 0,1 Ohm gemessen. Softwaretechnisch wird der ADC-Spannungs-Wert dann in einen Strom-Wert umgerechnet.


{| class="galleryTable noFloat"; align = "center"
| [[Datei:Schaltplan0.png|500px|left]]
| [[Datei:Unbenannt1.png|500px|right]]
|}


<h3 style="font-size:150%; text-align:center;">Stückliste</h3>
{|class="center" align="center" style="width: 50%; border-style: solid; border-width: 2px; border-radius: .5em"  

! Anzahl !! Bezeichnung
|-
| 1 ||Solar Panels 2.5W/5V
|-
| 1 || Laderegler TP4056 
|-
| 1 || 5V USB Voltage Converter
|-
| 2 || 0.1 Ohm Widerstand
|-
| 1 || 1 MOhm Widerstand
|-
| 1 || 100 KOhm Widerstand
|-
| 1 || 33 KOhm Widerstand
|-
| 1 || ESP32 NodeMCU
|-
| 2 || ADS1115
|-
| 2 || 18650 Lithium-Ionen Batterie
|-
| 2 || 18650 Batteriehalterung
|-
| 1 || Lochplatine
|-
| 1 || Diode
|-
|}


<h2 style="font-size:200%; text-align:center;">Visualisierung durch App 💻</h2>
[[Datei:Record-2022-06-16-11-53-52.gif|300px|center]]


<h2 style="font-size:200%; text-align:center;">Software 📏</h2>
<h3 style="font-size:150%; text-align:center;">Architektur</h3>
[[Datei:Architecture.png|700px|center]]

<h3 style="font-size:150%; text-align:center;">Spannungsmessung</h3>
Alle Spannungen werden über externe ADCs (ADS1115) gemessen. Da für das Messen der 3 Spannungen 6 Analog Eingänge benötigt werden, wurden 2 ADCs benötigt. Die Kommunikation erfolgt über I2C. Um die 2 ADCs softwaretechnisch unterscheiden zu können, müssen die Adressen für die Kommunikation festgelegt werden. Um kleine Spannungen intern nochmals zu verstärken, verfügen die ADCs über die Möglichkeit einen GAIN zu setzen. Durch einen höheren GAIN wird jedoch der Messbereich geringer.

{| class="galleryTable noFloat"; align = "center"
| [[Datei:ADC1.png|400px|left]]
| [[Datei:ADC2.png|400px|right]]
| [[Datei:ADC3.png|400px|right]]
|}

Zur Messung der Leerlaufspannung der Batterie müssen zuerst die Stromkreise unterbrochen werden. Dies geschieht durch HIGH setzen eines GPIO Pins. Dadurch wird der eingebaute MOSFET leitend und das Relais schaltet.
[[Datei:BatteryCapacity.png|500px|center]]

<h3 style="font-size:150%; text-align:center;">Ladezustandsberechnung</h3>
Um die Kapazität aus der Leerlaufspannung zu berechnen, wird der oben dargestellte Zusammenhang durch Geradengleichungen approximiert.
[[Datei:Kapazitätsberechnung.png|900px|center]]

<h3 style="font-size:150%; text-align:center;">Senden der Daten</h3>
Um die Daten für die App einfach zur Verfügung zu stellen, werden diese über MQTT an Amazon Web Services gesendet. Dort stellt der Service AWS IoT einen Dienst zur Verfügung, der immer die aktuellen Informationen des MQTT Topics über eine REST API zur Verfügung stellt.
[[Datei:Publishaws.png|700px|center]]

<h3 style="font-size:150%; text-align:center;">loop</h3>
Falls eine Last an der Powerbank hängt dürfen die Spannungen nicht gekappt werden. Deshalb wird vor dem Schalten des Relais überprüft, ob ein gewisser Schwellwert am Shuntwiderstand für den Ausgang übertroffen wurde. Um den Ladezustand  trotzdem ungefähr bestimmen zu können, wird über die Ein- und Ausgangsleistung die Differenz des Ladeszustandes ermittelt.
[[Datei:Mainloop.png|1000px|center]]


<big>Der komplette Code ist hier zu finden: https://gitlab.oth-regensburg.de/grm35372/pmt2</big>

<h2 style="font-size:200%; text-align:center;">Probleme ⛔</h2>

Während der Projektarbeit sind zahlreiche Probleme aufgetreten, welche unseren Zeitplan verzögert haben. Durch die Verwendung von Labor-Relais, welche einen zu hohen und unregeläßigen Schaltpunkt besitzen, konnte die Spannungsmessung nicht wie gewünscht durchgeführt werden. Aufgrund des geringen Ausgangsstroms, scheiterte der Versuch die Ausgangsspannung des ESP 32 mit DC-DC Step-Up Convertern hoch zu transformieren. Schließlich brachte die verwendung eines Mosfet und ein neues Relais mit niedrigerem Schalpunkt den gewünschten Erfolg.  

<h2 style="font-size:200%; text-align:center;">Fazit 🔭</h2>
Hintergrundgedanke bei diesem Projekt war die Minimalausführung einer Stromerzeugung mit erneuerbaren Energien. Mithilfe eines Batteriespeichers ist es möglich, gewonnene Energie zu speichern, und bei Gebrauch abzurufen. <br>
Obwohl wir manche Arbeitsschritte zeitlich unterschätzt haben konnten wir die Solarbetriebene Powerbank erfolgreich fertigstellen. Abschließend kann man sagen, dass das Projekt "Solarbetriebene Powerbank mit App" ein sehr lehrreiches und interessantes Projekt war. 


==Quellen==
https://datasheetspdf.com/pdf-file/1015118/EVER-WAYINDUSTRY/HK19F-DC3V/1 <br>
https://dlnmh9ip6v2uc.cloudfront.net/datasheets/Prototyping/TP4056.pdf <br>
https://www.espressif.com/sites/default/files/documentation/esp32_datasheet_en.pdf

