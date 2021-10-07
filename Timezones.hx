package;

import datetime.Timezone;
import datetime.DateTime;

using api.IdeckiaApi;

typedef Props = {
	@:editable("IANA timezones list (from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)", ["Etc/UTC"])
	var timezonesList:Array<String>;
}

class Timezones extends IdeckiaAction {
	var timezoneIndex = 0;

	override public function init(initialState:ItemState) {}

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			resolve(applyCurrentTimezone(currentState));
		});
	}

	override public function onLongPress(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			timezoneIndex = (timezoneIndex + 1) % props.timezonesList.length;
			resolve(applyCurrentTimezone(currentState));
		});
	}

	function applyCurrentTimezone(currentState:ItemState) {
		var currentTimezoneName = props.timezonesList[timezoneIndex];
		var currentTimezone = Timezone.get(currentTimezoneName);

		if (currentTimezone == null) {
			server.log('Could not found $currentTimezoneName in timezones DB.');
			currentState.text = 'Not found\n$currentTimezoneName';
		} else {
			var tzTime = currentTimezone.at(DateTime.now());
			currentState.text = '$currentTimezoneName\n${tzTime.format('%R')}';
		}

		return currentState;
	}
}
