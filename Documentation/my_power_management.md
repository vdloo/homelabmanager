# Power management

While having a bunch of rackservers in your living room is fun, it is also loud. For that reason (and power consumption) I figured it would be nice if these machines could be turned off and on remotely. I'm not talking Wake-on-LAN but really turning the power on and off. Physically being able to flip that switch means automatically being able to bring online extra computational capacity, doing that when I'm not at home to hear all the fans whirring, but also being able to power-cycle the machines for real when they are stuck.

## ESP866, 433MHz and KAKU

In the homelab I have [a bunch](https://twitter.com/vdloo_/status/1236939364229353472) of smart-plugs that can be controlled over 433MHz. The ones I use are of the brand [Klik aan Klik uit](https://klikaanklikuit.nl/), specifically the model [APC3-2300R](https://tweakers.net/pricewatch/1225973/klikaanklikuit-apc3-2300r.html). To communicate with them programmatically and without the remote I use [these 433Mhz RF Decoder and Transmitters](https://www.banggood.com/Geekcreit-433Mhz-RF-Decoder-Transmitter-With-Receiver-Module-Kit-For-ARM-MCU-Wireless-Geekcreit-for-Arduino-products-that-work-with-official-Arduino-boards-p-74102.html).

In order to emulate the remote control for these smart-plugs I wrote a small program that acts as an API in my network using [this NewRemoteSwitch Arduino library](https://github.com/1technophile/NewRemoteSwitch). With that I was able to read out the transmitter code for each remote control and emulate it. This API runs on an [ESP8266](https://en.wikipedia.org/wiki/ESP8266) which has the 433MHz transmitter connected to it using the GPIO pins.

## The web interface

While the ESP8266 can run a small web service just fine, for convenience I only use it for those API-endpoints for the actual power toggling but run a small static web page using NGINX on another server for the visual interface. For this I use a modified version of the [Ladda demo page](https://lab.hakim.se/ladda/). The page has some simple JavaScript triggers on the buttons that does XMLHttpRequests to the ESP8266 if you press them.

![knopjes](https://raw.githubusercontent.com/vdloo/homelabmanager/main/Documentation/images/knopjes.png)

## Monitoring power usage

Power usage was monitored using [Grafana, pytesseract and the Toon smart thermostat on my wall](https://twitter.com/vdloo_/status/1225327597363613698) until I fried my webcam doing that. One of these days I should get around to replacing that webcam or doing it the proper way with a P1 cable or something.
