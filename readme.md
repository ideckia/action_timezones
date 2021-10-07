# Action for ideckia: Timezones

## Definition

Shows the timezone times defined in the array (one at a time) in the item.

* Single click updates the current timezone time.
* Long press shows the next timezone.

## Properties

| Name | Type | Default | Description | Possible values |
| ----- |----- | ----- | ----- | ----- |
| timezonesList | Array&lt;String&gt; | ["Etc/UTC"] | IANA timezones list (from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | null |

## Example in layout file

```json 
{
    "text": "Timezones example",
    "bgColor": "00ff00",
    "actions": [
        {
            "name": "timezones",
            "props": {
                "timezonesList": [
                    "Etc/UTC"
                ]
            }
        }
    ]
}

```