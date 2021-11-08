# Action for ideckia: Timezones

## Definition

Shows the timezone times defined in the array (one at a time) in the item.

* Single click updates the current timezone time.
* Long press shows the next timezone.

## Properties

| Name | Type | Default | Description | Possible values |
| ----- |----- | ----- | ----- | ----- |
| updateInterval | UInt | 15 | Update interval in minutes | null |
| timezonesList | Array&lt;{ name : String, ianaId : String }&gt; | [{ name : "utc", ianaId : "Etc/UTC" }] | A list with a name you want to see in the item and the [IANA timezone ID](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to show the time. | null |

## Example in layout file

```json 
{
    "text": "Timezones example",
    "bgColor": "00ff00",
    "actions": [
        {
            "name": "timezones",
            "props": {
                "updateInterval": 15,
                "timezonesList": [
                    {
                        "name" : "utc",
                        "ianaId" : "Etc/UTC"
                    }
                ]
            }
        }
    ]
}

```