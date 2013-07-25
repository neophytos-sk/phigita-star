
/* Generated data (by glib-mkenums) */

#define GWEATHER_I_KNOW_THIS_IS_UNSTABLE
#include "gweather-enum-types.h"
#include "gweather-location.h"
/* enumerations from "gweather-location.h" */
GType
gweather_location_level_get_type (void)
{
	static GType etype = 0;
	if (G_UNLIKELY (etype == 0)) {
		static const GEnumValue values[] = {
			{ GWEATHER_LOCATION_WORLD, "GWEATHER_LOCATION_WORLD", "world" },
			{ GWEATHER_LOCATION_REGION, "GWEATHER_LOCATION_REGION", "region" },
			{ GWEATHER_LOCATION_COUNTRY, "GWEATHER_LOCATION_COUNTRY", "country" },
			{ GWEATHER_LOCATION_ADM1, "GWEATHER_LOCATION_ADM1", "adm1" },
			{ GWEATHER_LOCATION_ADM2, "GWEATHER_LOCATION_ADM2", "adm2" },
			{ GWEATHER_LOCATION_CITY, "GWEATHER_LOCATION_CITY", "city" },
			{ GWEATHER_LOCATION_WEATHER_STATION, "GWEATHER_LOCATION_WEATHER_STATION", "weather-station" },
			{ 0, NULL, NULL }
		};
		etype = g_enum_register_static (g_intern_static_string ("GWeatherLocationLevel"), values);
	}
	return etype;
}


/* Generated data ends here */

