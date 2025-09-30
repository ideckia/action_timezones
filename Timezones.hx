package;

import datetime.Timezone;
import datetime.DateTime;

using api.IdeckiaApi;

typedef Props = {
	@:editable("prop_timezones_list", [
		{
			name: "utc",
			iana_id: "Etc/UTC"
		}
	])
	var timezones_list:Array<{name:String, iana_id:String}>;
	@:editable("prop_update_interval", 15)
	var update_interval:UInt;
}

@:name('timezones')
@:description('action_description')
@:localize
class Timezones extends IdeckiaAction {
	var timezoneIndex = 0;
	var timer:haxe.Timer;

	override public function init(initialState:ItemState):js.lib.Promise<ItemState> {
		return show(initialState);
	}

	override function deinit() {
		if (timer != null)
			timer.stop();
		timer = null;
	}

	override public function show(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			if (props.timezones_list.length == 0)
				timezoneIndex = -1;

			if (timer == null) {
				timer = new haxe.Timer(props.update_interval * 60 * 1000);
				timer.run = function() {
					applyCurrentTimezone(currentState, core.updateClientState, core.log.error);
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
				reject(Loc.no_timezone_defined.tr());

			applyCurrentTimezone(currentState, (newState) -> resolve(new ActionOutcome({state: newState})), reject);
		});
	}

	override public function onLongPress(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise((resolve, reject) -> {
			if (timezoneIndex == -1)
				reject(Loc.no_timezone_defined.tr());

			timezoneIndex = (timezoneIndex + 1) % props.timezones_list.length;
			applyCurrentTimezone(currentState, (newState) -> resolve(new ActionOutcome({state: newState})), reject);
		});
	}

	function applyCurrentTimezone(currentState:ItemState, resolve:ItemState->Void, reject:Any->Void) {
		var currentElement = props.timezones_list[timezoneIndex];
		var currentTimezone = Timezone.get(currentElement.iana_id);

		if (currentTimezone == null) {
			core.log.error('Could not found ${currentElement.iana_id} in timezones DB.');
			currentState.text = Loc.iana_not_found.tr([currentElement.iana_id]);
		} else {
			var tzTime = currentTimezone.at(DateTime.now());
			currentState.text = '${currentElement.name}\n${tzTime.format('%R')}';
		}

		resolve(currentState);
	}
}
