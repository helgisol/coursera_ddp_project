### Welcome to the Humidity calculator
This application calculates some humidity indicators, viz.,  

1) [relative humidity](https://en.wikipedia.org/wiki/Relative_humidity) (the ratio of the partial pressure of water vapor to the equilibrium vapor pressure of water at a given temperature),  
2) [absolute humidity](https://en.wikipedia.org/wiki/Humidity#Absolute_humidity) (the total mass of water vapor present in a given volume of air),  
3) [dew point temperature](https://en.wikipedia.org/wiki/Dew_point) (the temperature at which a given concentration of water vapor in air will form dew),  

on the base of the following input indicators:  

1) [dry-bulb temperature](https://en.wikipedia.org/wiki/Dry-bulb_temperature) (the temperature of air measured by a thermometer freely exposed to the air but shielded from radiation and moisture),  
2) [wet-bulb temperature](https://en.wikipedia.org/wiki/Wet-bulb_temperature) (the temperature a parcel of air would have if it were cooled to saturation (100% relative humidity) by the evaporation of water into it, with the latent heat being supplied by the parcel),  
3) altitude under sea level in meters for estination of atmospheric pressure.  
    
In the top of application you can see the sliders for input parameters. Below there is a tabbed panel with:  

1) a summary table with calculated humidity indicators,  
2) a plot of dependence of the relative humidity on the dry-bulb temperature,  
3) a plot of dependence of the relative humidity on the wet-bulb temperature,  
4) a plot of dependence of the dew point temperature on the dry-bulb temperature,  
5) a plot of dependence of the dew point temperature on the wet-bulb temperature.  

All output values and plots are updated automatically when you change the input.  

The relative humidity is calculated on the base of a formula for the equilibrium vapor pressure of water vapor, which is similar to [the Buck's formula](https://en.wikipedia.org/wiki/Relative_humidity#Measurement). More precisely the formula is derived from the Guide to Meteorological Instruments and Methods of Observation (2008).

Source code is available on the [GitHub](https://github.com/helgisol/coursera_ddp_project).

