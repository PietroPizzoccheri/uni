# Evaluation lab - Node-RED

## Group number: 12

## Group members

- Pietro Pizzoccheri       10797420
- Heitor Tanoue de Mello   11071263
- Enzo Serrano Conti       11071898

## Description of message flows
We get MQTT messages from neslabpolimi/smartcity/milan and neslabpolimi/nsds/eval24/k.
We also get a temperature in kelvin from OpenWeatherMap every minute, triggered by an inject node.
The "parse msg" node acts as a router for this info, putting every part of it in a right key in the msg.payload.
Then, the "filter message" node, using a context, stores a size-10 sliding window with the temperatures values, using the push and shift JS methods
Finally, we average the window temperatures and compare it to the openweather temperature, checking if the diff is greater than K, if it is, we send a MQTT message to neslabpolimi/nsds/eval24/alarm

## Extensions 
