name = "Wave Fix"
author = "IvanX"
version = "1.2"
description = "NEVER AGAIN, shall you crash into the wave when the wave corner is correct!"

forumthread = ""
api_version = 6

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
  {
    name = "adjust_boost",
    label = "Adjust Boost",
    options =
    {
        {description = "On", data = true},
        {description = "Off", data = false},
    },
    default = true
  }
}
