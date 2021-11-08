package;

import datetime.Timezone;
import datetime.DateTime;

using api.IdeckiaApi;

typedef Props = {
	@:editable("A list with a name you want to see in the item and the [IANA timezone ID](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to show the time.",
		[
			{
				name: "utc",
				ianaId: "Etc/UTC"
			}
		])
	var timezonesList:Array<{name:String, ianaId:String}>;
	@:editable("Update interval in minutes", 15)
	var updateInterval:UInt;
}

@:name('timezones')
class Timezones extends IdeckiaAction {
	var timezoneIndex = 0;

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		if (props.timezonesList.length == 0)
			timezoneIndex = -1;

		var timer = new haxe.Timer(props.updateInterval * 60 * 1000);
		timer.run = function() {
			applyCurrentTimezone(initialState, server.updateClientState, server.log.error);
		};

		return execute(initialState);
	}

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			if (timezoneIndex == -1)
				reject('No timezones defined');

			applyCurrentTimezone(currentState, resolve, reject);
		});
	}

	override public function onLongPress(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			if (timezoneIndex == -1)
				reject('No timezones defined');

			timezoneIndex = (timezoneIndex + 1) % props.timezonesList.length;
			applyCurrentTimezone(currentState, resolve, reject);
		});
	}

	function applyCurrentTimezone(currentState:ItemState, resolve:ItemState->Void, reject:Any->Void) {
		var currentElement = props.timezonesList[timezoneIndex];
		var currentTimezone = Timezone.get(currentElement.ianaId);

		if (currentTimezone == null) {
			server.log.error('Could not found ${currentElement.ianaId} in timezones DB.');
			currentState.text = 'Not found\n${currentElement.ianaId}';
		} else {
			var tzTime = currentTimezone.at(DateTime.now());
			currentState.text = '${currentElement.name}\n${tzTime.format('%R')}';
		}

		resolve(currentState);
	}
}
