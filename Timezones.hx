package;

import datetime.Timezone;
import datetime.DateTime;

using api.IdeckiaApi;

typedef Props = {
	@:editable("A list with a name you want to see in the item and the [IANA timezone ID](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to show the time.",
		[
			{
				name: "utc",
				iana_id: "Etc/UTC"
			}
		])
	var timezones_list:Array<{name:String, iana_id:String}>;
	@:editable("Update interval in minutes", 15)
	var update_interval:UInt;
}

@:name('timezones')
@:description('Show the time in the configurated timezones.')
class Timezones extends IdeckiaAction {
	var timezoneIndex = 0;
	var timer:haxe.Timer;

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		return show(initialState);
	}

	override public function show(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			if (props.timezones_list.length == 0)
				timezoneIndex = -1;

			if (timer == null) {
				timer = new haxe.Timer(props.update_interval * 60 * 1000);
				timer.run = function() {
					applyCurrentTimezone(currentState, server.updateClientState, server.log.error);
				};
			}

			execute(currentState).then(outcome -> resolve(outcome.state)).catchError(reject);
		});
	}

	override public function hide() {
		if (timer != null) {
			timer.stop();
			timer = null;
		}
	}

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise((resolve, reject) -> {
			if (timezoneIndex == -1)
				reject('No timezones defined');

			applyCurrentTimezone(currentState, (newState) -> resolve(new ActionOutcome({state: newState})), reject);
		});
	}

	override public function onLongPress(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise((resolve, reject) -> {
			if (timezoneIndex == -1)
				reject('No timezones defined');

			timezoneIndex = (timezoneIndex + 1) % props.timezones_list.length;
			applyCurrentTimezone(currentState, (newState) -> resolve(new ActionOutcome({state: newState})), reject);
		});
	}

	function applyCurrentTimezone(currentState:ItemState, resolve:ItemState->Void, reject:Any->Void) {
		var currentElement = props.timezones_list[timezoneIndex];
		var currentTimezone = Timezone.get(currentElement.iana_id);

		if (currentTimezone == null) {
			server.log.error('Could not found ${currentElement.iana_id} in timezones DB.');
			currentState.text = 'Not found\n${currentElement.iana_id}';
		} else {
			var tzTime = currentTimezone.at(DateTime.now());
			currentState.text = '${currentElement.name}\n${tzTime.format('%R')}';
		}

		resolve(currentState);
	}
}
